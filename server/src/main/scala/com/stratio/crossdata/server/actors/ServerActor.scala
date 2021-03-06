/*
 * Copyright (C) 2015 Stratio (http://stratio.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.stratio.crossdata.server.actors

import java.util.UUID

import akka.actor.SupervisorStrategy.Restart
import akka.actor._
import akka.cluster.Cluster
import akka.cluster.pubsub.DistributedPubSub
import akka.cluster.pubsub.DistributedPubSubMediator.{Publish, Subscribe, SubscribeAck}
import com.stratio.crossdata.common.result.{ErrorSQLResult, SuccessfulSQLResult}
import com.stratio.crossdata.common.security.Session
import com.stratio.crossdata.common.util.akka.keepalive.KeepAliveMaster.{DoCheck, HeartbeatLost}
import com.stratio.crossdata.common.{CommandEnvelope, SQLCommand, _}
import com.stratio.crossdata.server.actors.JobActor.Commands.{CancelJob, StartJob}
import com.stratio.crossdata.server.actors.JobActor.Events.{JobCompleted, JobFailed}
import com.stratio.crossdata.server.config.ServerConfig
import org.apache.log4j.Logger
import org.apache.spark.sql.crossdata.session.{HazelcastSessionProvider, XDSessionProvider}
import org.apache.spark.sql.types.StructType

import scala.collection.JavaConversions._
import scala.concurrent.duration._
import scala.util.{Failure, Success}


object ServerActor {
  val ManagementTopic: String = "jobsManagement"

  def props(cluster: Cluster, sessionProvider: XDSessionProvider, serverConfig: ServerConfig): Props =
    Props(new ServerActor(cluster, sessionProvider, serverConfig))

  case class JobId(sessionId: UUID, queryId: UUID)

  private case class ManagementEnvelope(command: ControlCommand, source: ActorRef)

  private object ManagementMessages {

    case class DelegateCommand(scommand: CommandEnvelope, broadcaster: ActorRef)

    case class FinishJob(jobActor: ActorRef)

  }

  private case class State(jobsById: Map[JobId, ActorRef])

}

// TODO it should only accept messages from known sessions
class ServerActor(cluster: Cluster, sessionProvider: XDSessionProvider, serverConfig: ServerConfig)
  extends Actor {

  import ServerActor.ManagementMessages._
  import ServerActor._

  lazy val logger = Logger.getLogger(classOf[ServerActor])

  lazy val mediator = DistributedPubSub(context.system).mediator

  override def preStart(): Unit = {
    super.preStart()

    // Subscribe to the management distributed topic
    mediator ! Subscribe(ManagementTopic, self)

  }

  // Actor behaviours

  override def receive: Actor.Receive = initial(Set(ManagementTopic))

  private def initial(pendingTopics: Set[String]): Receive = {
    case SubscribeAck(Subscribe(ManagementTopic, None, self)) =>
      val newPendingTopics = pendingTopics - ManagementTopic
      checkSubscriptions(newPendingTopics)
  }

  private def checkSubscriptions(pendingTopics: Set[String]): Unit =
    if (pendingTopics.isEmpty)
      context.become(ready(State(Map.empty)))
    else
      context.become(initial(pendingTopics))

  def actualRequester(rqActor: Option[ActorRef]): ActorRef = rqActor.getOrElse(sender)

  /**
    * If a `cmd` is passed to this method is because it has already been checked that this server can run it.
    *
    * @param cmd
    * @param st
    */

  private def executeAccepted(cmd: CommandEnvelope, requester: ActorRef)(st: State): Unit = cmd match {
    case CommandEnvelope(sqlCommand@SQLCommand(query, queryId, withColnames, timeout), session@Session(id, _)) =>
      logger.debug(s"Query received $queryId: $query. Actor ${self.path.toStringWithoutAddress}")
      logger.debug(s"Session identifier $session")
      sessionProvider.session(id) match {
        case Success(xdSession) =>
          val jobActor = context.actorOf(JobActor.props(xdSession, sqlCommand, requester, timeout))
          jobActor ! StartJob
          context.become(
            ready(st.copy(jobsById = st.jobsById + (JobId(id, sqlCommand.queryId) -> jobActor)))
          )

        case Failure(error) =>
          logger.warn(s"Received message with an unknown sessionId $id", error)
          requester ! SQLReply(
            sqlCommand.requestId,
            ErrorSQLResult(s"Unable to recover the session ${session.id}. Cause: ${error.getMessage}")
          )
      }


    case CommandEnvelope(addAppCommand@AddAppCommand(path, alias, clss, _), session@Session(id, requesterOpt)) =>
      if ( sessionProvider.session(id).map(_.addApp(path, clss, alias)).getOrElse(None).isDefined)// TODO improve addJar sessionManagement
        sender ! SQLReply(addAppCommand.requestId, SuccessfulSQLResult(Array.empty, new StructType()))
      else
        sender ! SQLReply(addAppCommand.requestId, ErrorSQLResult("App can't be stored in the catalog"))

    case CommandEnvelope(cc@CancelQueryExecution(queryId), session@Session(id, Some(cancellationRequester))) =>
      st.jobsById(JobId(id, queryId)) ! CancelJob(cancellationRequester, Some(cc.requestId))
  }


  // Receive functions:

  // Broadcast messages treatment
  def broadcastRequestsRec(st: State): Receive = {
    case DelegateCommand(_, broadcaster) if broadcaster == self => //Discards from this server broadcast delegated-commands

    case DelegateCommand(cmd, broadcaster) if broadcaster != self =>
      cmd match {
        // Inner pattern matching for future delegated command validations
        case sc@CommandEnvelope(CancelQueryExecution(queryId), Session(sid, requesterOpt)) =>
          val requester = actualRequester(requesterOpt)
          st.jobsById.get(JobId(sid, queryId)) foreach (_ => executeAccepted(sc, requester)(st))
        /* If it doesn't validate it won't be re-broadcast since the source server already distributed it to all
            servers through the topic. */
      }
  }

  // Commands reception: Checks whether the command can be run at this Server passing it to the execution method if so
  def commandMessagesRec(st: State): Receive = {

    case sc@CommandEnvelope(_: SQLCommand, session) =>
      executeAccepted(sc, actualRequester(session.clientRef))(st)

    /*case sc@CommandEnvelope(_: AddJARCommand, _, _) => //TODO Adapt Requester
      executeAccepted(sc)(st)

    case sc@CommandEnvelope(_: AddAppCommand, _, _) => //TODO: Adapt Requester
      executeAccepted(sc)(st)*/


    case sc@CommandEnvelope(cc: ControlCommand, session@Session(id, requesterOpt)) =>
        val requester = actualRequester(requesterOpt)
      st.jobsById.get(JobId(id, cc.requestId)) map { _ =>
        executeAccepted(sc, requester)(st) // Command validated to be executed by this server.
      } getOrElse {
        // If it can't run here it should be executed somewhere else
        mediator ! Publish(ManagementTopic, DelegateCommand(sc.copy(session = Session(id, Some(requester))), self))
      }

    case sc@CommandEnvelope(_: ClusterStateCommand, session) => {
      val members = if (sessionProvider.isInstanceOf[HazelcastSessionProvider]) {
        sessionProvider.asInstanceOf[HazelcastSessionProvider].getClusterState.getMembers map { m =>
          m.getAddress.toString
        }
      } else {
        Set.empty[String]
      }

      sender ! ClusterStateReply(sc.cmd.requestId, cluster.state, members)
    }

    case sc@CommandEnvelope(OpenSessionCommand(user), Session(sid,_)) =>
      val open = sessionProvider.newSession(sid, user) match {
        case Success(_) =>
          logger.info(s"new session with sessionID=${sid} has been created")
          true
        case Failure(error) =>
          logger.error(s"failure while creating the session with sessionID=${sid}")
          false
      }
      sender ! OpenSessionReply(sc.cmd.requestId, isOpen = open)


      context.actorSelection("/user/client-monitor") ! DoCheck(sid, serverConfig.expectedClientHeartbeatPeriod)

    case sc@CommandEnvelope(_: CloseSessionCommand, session )=>
      closeSessionTerminatingJobs(session.id)(st)
      /* Note that the client monitoring isn't explicitly stopped. It'll after the first miss
          is detected, right after the driver has ended its session. */

  }

  // Manages events from the `JobActor` which runs the task
  def eventsRec(st: State): Receive = {

    case JobFailed(e) =>
      logger.error(e.getMessage, e)
      sentenceToDeath(sender())

    case JobCompleted =>
      sentenceToDeath(sender())

    case FinishJob(who) =>
      context.become(ready(st.copy(jobsById = st.jobsById.filterNot(_._2 == who))))
      context.children.find(_ == who).foreach(gracefullyKill)
  }

  // Manages clients' heartbeats losses, closing their sessions and stopping all jobs related to them.
  def clientMonitoringEvents(st: State): Receive = {
    case HeartbeatLost(sessionId: UUID) =>
      closeSessionTerminatingJobs(sessionId)(st)
  }

  // Function composition to build the finally applied receive-function
  private def ready(st: State): Receive =
    broadcastRequestsRec(st) orElse
      commandMessagesRec(st) orElse
      eventsRec(st) orElse
      clientMonitoringEvents(st) orElse { case any =>
      logger.warn(s"Something is going wrong! Unknown message: $any")
    }

  private def closeSessionTerminatingJobs(sessionId: UUID)(st: State): Unit = {
    val newjobsmap = st.jobsById filter {
      case (JobId(`sessionId`, _), job) =>
        gracefullyKill(job) // WARNING! Side-effect within filter function
        false
      case _ => true
    }
    context.become(ready(st.copy(jobsById = newjobsmap)))
    sessionProvider.closeSession(sessionId)
  }

  private def sentenceToDeath(victim: ActorRef): Unit = serverConfig.completedJobTTL match {
    case finite: FiniteDuration =>
      context.system.scheduler.scheduleOnce(finite, self, FinishJob(victim))(context.dispatcher)
    case _ => // Reprieve by infinite limit
  }

  def gracefullyKill(victim: ActorRef): Unit = {
    victim ! CancelJob(self, None)
    victim ! PoisonPill
  }

  //TODO: Use number of tries and timeout configuration parameters
  override def supervisorStrategy: SupervisorStrategy = OneForOneStrategy(serverConfig.retryNoAttempts, serverConfig.retryCountWindow) {
    case _ => Restart //Crashed job gets restarted (or not, depending on `retryNoAttempts` and `retryCountWindow`)
  }
}

