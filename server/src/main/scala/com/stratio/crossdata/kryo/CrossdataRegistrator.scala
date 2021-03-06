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
package com.stratio.crossdata.kryo

import com.esotericsoftware.kryo.Kryo
import org.apache.spark.serializer.KryoRegistrator
import org.apache.spark.sql.Row
import org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema
import org.apache.spark.sql.types._

class CrossdataRegistrator extends KryoRegistrator{
  override def registerClasses(kryo: Kryo): Unit = {
    kryo.register(Nil.getClass)
    kryo.register(StringType.getClass)
    kryo.register(DoubleType.getClass)
    kryo.register(IntegerType.getClass)
    kryo.register(BooleanType.getClass)
    kryo.register(LongType.getClass)
    kryo.register(classOf[ArrayType])
    kryo.register(classOf[StructType])
    kryo.register(classOf[StructField])
    kryo.register(classOf[Metadata])
    kryo.register(classOf[GenericRowWithSchema])
    kryo.register(classOf[Array[Object]])
    kryo.register(classOf[Array[Row]])
    kryo.register(classOf[scala.collection.immutable.Map$EmptyMap$])
    kryo.register(classOf[scala.collection.immutable.$colon$colon[_]])
    kryo.register(classOf[Array[org.apache.spark.sql.types.StructField]])
  }
}
