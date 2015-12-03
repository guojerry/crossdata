Feature: MongoSelectAnd
  Scenario: [CROSSDATA-74 : MONGO NATIVE] SELECT * FROM tabletest WHERE ident = 0 AND name='name_0';
    When I execute 'SELECT * FROM tabletest WHERE ident = 0 AND name='name_0''
    Then The result has to have '1' rows:
      | ident-integer | name-string   | money-double  |  new-boolean  | date-date  |
      |    1          | name_1        | 11.2          |  true         | 2001-01-01 |
      |    2          | name_2        | 12.2          |  true         | 2002-02-02 |
      |    3          | name_3        | 13.2          |  true         | 2003-03-03 |
      |    4          | name_4        | 14.2          |  true         | 2004-04-04 |
      |    5          | name_5        | 15.2          |  true         | 2005-05-05 |
      |    6          | name_6        | 16.2          |  true         | 2006-06-06 |
      |    7          | name_7        | 17.2          |  true         | 2007-07-07 |
      |    8          | name_8        | 18.2          |  true         | 2008-08-08 |
      |    9          | name_9        | 19.2          |  true         | 2009-09-09 |

  Scenario: [CROSSDATA-74 : MONGO NATIVE] SELECT * FROM tabletest WHERE ident = 0 AND name='name_8';
    When I execute 'SELECT * FROM tabletest WHERE ident = 0 AND name='name_8''
    Then The result has to have '0' rows:
      | ident-integer | name-string   | money-double  |  new-boolean  | date-date  |

  Scenario: [CROSSDATA-74 : MONGO NATIVE] SELECT * FROM tabletest WHERE ident = 0 AND name='name_0' AND money = 10.2;
    When I execute 'SELECT * FROM tabletest WHERE ident = 0 AND name='name_0' AND money = 10.2'
    Then The result has to have '1' rows:
      | ident-integer | name-string   | money-double  |  new-boolean  | date-date  |
      |    0          | name_0        | 10.2          |  true         | 1999-11-30 |

  Scenario: [CROSSDATA-74 : MONGO NATIVE] SELECT * FROM tabletest WHERE (ident = 0 AND name='name_0') AND money = 10.2;
    When I execute 'SELECT * FROM tabletest WHERE (ident = 0 AND name='name_0') AND money = 10.2'
    Then The result has to have '1' rows:
      | ident-integer | name-string   | money-double  |  new-boolean  | date-date  |
      |    0          | name_0        | 10.2          |  true         | 1999-11-30 |

  Scenario: [CROSSDATA-74 : MONGO NATIVE] SELECT * FROM tabletest WHERE ident = 0 AND name='name_0' AND money = 10.2 AND new = true;
    When I execute 'SELECT * FROM tabletest WHERE ident = 0 AND name='name_0' AND money = 10.2 AND new = true'
    Then The result has to have '1' rows:
      | ident-integer | name-string   | money-double  |  new-boolean  | date-date  |
      |    0          | name_0        | 10.2          |  true         | 1999-11-30 |

  Scenario: [CROSSDATA-74 : MONGO NATIVE] SELECT * FROM tabletest WHERE (ident = 0 AND name='name_0') AND (money = 10.2 AND new = true);
    When I execute 'SELECT * FROM tabletest WHERE (ident = 0 AND name='name_0') AND (money = 10.2 AND new = true)'
    Then The result has to have '1' rows:
      | ident-integer | name-string   | money-double  |  new-boolean  | date-date  |
      |    0          | name_0        | 10.2          |  true         | 1999-11-30 |

  Scenario: [MONGO NATIVE] SELECT * FROM tabletest WHERE (ident = 0 AND name='name_0') AND (money = 10.2 AND new = true);
    When I execute 'SELECT date FROM tabletest WHERE (ident = 0 AND name='name_0') AND (money = 10.2 AND new = true)'
    Then The result has to have '1' rows:
     | date-date  |
     | 1999-11-30 |