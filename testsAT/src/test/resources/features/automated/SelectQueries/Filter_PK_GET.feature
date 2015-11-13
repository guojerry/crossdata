Feature: Basic Select queries with FILTEr_PK_GT

  Scenario: SELECT * FROM catalogTest.tableTest WHERE id >=6 ;
    When I execute a query: 'SELECT * FROM catalogTest.tableTest WHERE id >= 6;'
    Then the result has to be:
      | catalogTest.tableTest.id-id-Integer | catalogTest.tableTest.name-name-String | catalogTest.tableTest.age-age-Integer | catalogTest.tableTest.phone-phone-BigInteger | catalogTest.tableTest.salary-salary-Double | catalogTest.tableTest.reten-reten-Float | catalogTest.tableTest.new-new-Boolean |
      | 6                                   | name_6                                 | 60                                    | 60000000                                     | 6666.66                                    | 16.11                                   | false                                 |
      | 7                                   | name_7                                 | 70                                    | 70000000                                     | 7777.77                                    | 17.11                                   | true                                  |
      | 8                                   | name_8                                 | 80                                    | 80000000                                     | 8888.88                                    | 18.11                                   | false                                 |
      | 9                                   | name_9                                 | 90                                    | 90000000                                     | 9999.99                                    | 19.11                                   | true                                  |
      | 10                                  | name_10                                | 1                                     | 10000000                                     | 1111.11                                    | 20.11                                   | false                                 |

  Scenario: SELECT id FROM catalogTest.tableTest WHERE id >= 6;
    When I execute a query: 'SELECT id FROM catalogTest.tableTest WHERE id >= 6;'
    Then the result has to be:
      | catalogTest.tableTest.id-id-Integer |
      | 6                                   |
      | 7                                   |
      | 8                                   |
      | 9                                   |
      | 10                                  |

  Scenario: SELECT id AS identificador FROM catalogTest.tableTest WHERE identificador >=6 ;
    When I execute a query: 'SELECT id AS identificador FROM catalogTest.tableTest WHERE identificador >= 6;'
    Then the result has to be:
      | catalogTest.tableTest.id-identificador-Integer |
      | 6                                              |
      | 7                                              |
      | 8                                              |
      | 9                                              |
      | 10                                             |

  Scenario: SELECT id AS identificador FROM catalogTest.tableTest WHERE identificador >= 5.9;
    When I execute a query: 'SELECT id AS identificador FROM catalogTest.tableTest WHERE identificador >= 5.9;'
    Then the result has to be:
      | catalogTest.tableTest.id-identificador-Integer |
      | 6                                              |
      | 7                                              |
      | 8                                              |
      | 9                                              |
      | 10                                             |

  Scenario: SELECT id AS identificador FROM catalogTest.tableTest WHERE identificador >= 'Carlos';
    When I execute a query: 'SELECT id AS identificador FROM catalogTest.tableTest WHERE identificador >= 'Carlos';'
    Then an exception 'IS' thrown

  Scenario: SELECT * AS identificador FROM catalogTest.tab2 WHERE name >= 'Hugo';
    When I execute a query: 'SELECT * AS identificador FROM catalogTest.tab2 WHERE name >= 'Hugo';'
    Then the result has to be:
      | catalogTest.tab2.name-name-String | catalogTest.tab2.surname-surname-String |
      | Hugo                              | Dominguez                               |
      | Miguel                            | Fernandez                               |

  Scenario: SELECT * AS identificador FROM catalogTest.tab2 WHERE name >= 'AAAA';
    When I execute a query: 'SELECT * AS identificador FROM catalogTest.tab2 WHERE name >= 'AAAA';'
    Then the result has to be:
      | catalogTest.tab2.name-name-String | catalogTest.tab2.surname-surname-String |
      | Antonio                           | Alcocer                                 |
      | Hugo                              | Dominguez                               |
      | Carlos                            | Hernandez                               |
      | Miguel                            | Fernandez                               |

  Scenario: SELECT * AS identificador FROM catalogTest.tab2 WHERE name >= 25;
    When I execute a query: 'SELECT * AS identificador FROM catalogTest.tab2 WHERE name >= 25;'
    Then an exception 'IS' thrown

  Scenario: SELECT * FROM catalogTest.tab3 WHERE id >= 1;
    When I execute a query: 'SELECT * FROM catalogTest.tab3 WHERE id >= 1;'
    Then the result has to be:
      | catalogTest.tab3.id-id-BigInteger | catalogTest.tab3.age-age-BigInteger |
      | 1                                 | 10                                  |
      | 2                                 | 20                                  |
      | 3                                 | 30                                  |

  Scenario: SELECT * FROM catalogTest.tab3 WHERE id >= -10;
    When I execute a query: 'SELECT * FROM catalogTest.tab3 WHERE id >= -10;'
    Then the result has to be:
      | catalogTest.tab3.id-id-BigInteger | catalogTest.tab3.age-age-BigInteger |
      | -4                                | -40                                 |
      | 1                                 | 10                                  |
      | 2                                 | 20                                  |
      | 3                                 | 30                                  |

  Scenario: SELECT * FROM catalogTest.tab3 WHERE id >= 10;
    When I execute a query: 'SELECT * FROM catalogTest.tab3 WHERE id >= 10;'
    Then the result has to be:
      | catalogTest.tab3.id-id-BigInteger | catalogTest.tab3.age-age-BigInteger |

  Scenario: SELECT * FROM catalogTest.tab3 WHERE id >= -4.4;
    When I execute a query: 'SELECT * FROM catalogTest.tab3 WHERE id >= -4.4;'
    Then the result has to be:
      | catalogTest.tab3.id-id-BigInteger | catalogTest.tab3.age-age-BigInteger |
      | -4                                | -40                                 |
      | 1                                 | 10                                  |
      | 2                                 | 20                                  |
      | 3                                 | 30                                  |

  Scenario: SELECT * FROM catalogTest.tab3 WHERE id > 'Hugo';
    When I execute a query: 'SELECT * FROM catalogTest.tab3 WHERE money >= 'Hugo';'
    Then an exception 'IS' thrown

  Scenario: SELECT * FROM catalogTest.tab4 WHERE money >= 1.1;
    When I execute a query: 'SELECT * FROM catalogTest.tab4 WHERE money >= 1.1;'
    Then the result has to be:
      | catalogTest.tab4.money-money-Double | catalogTest.tab4.reten-reten-Double |
      | 1.1                                 | 10.10                               |
      | 2.2                                 | 20.20                               |
      | 3.3                                 | 30.30                               |

  Scenario: SELECT * FROM catalogTest.tab4 WHERE money >= 0;
    When I execute a query: 'SELECT * FROM catalogTest.tab4 WHERE money >= 0;'
    Then the result has to be:
      | catalogTest.tab4.money-money-Double | catalogTest.tab4.reten-reten-Double |
      | 1.1                                 | 10.10                               |
      | 2.2                                 | 20.20                               |
      | 3.3                                 | 30.30                               |

  Scenario: SELECT * FROM catalogTest.tab4 WHERE money >= 10;
    When I execute a query: 'SELECT * FROM catalogTest.tab4 WHERE money >= 10;'
    Then the result has to be:
      | catalogTest.tab4.money-money-Double | catalogTest.tab4.reten-reten-Double |

  Scenario: SELECT * FROM catalogTest.tab4 WHERE money >= -4.5;
    When I execute a query: 'SELECT * FROM catalogTest.tab4 WHERE money >= -4.5;'
    Then the result has to be:
      | catalogTest.tab4.money-money-Double | catalogTest.tab4.reten-reten-Double |
      | -4.4                                | -40.40                          |
      | 1.1                                 | 10.10                           |
      | 2.2                                 | 20.20                           |
      | 3.3                                 | 30.30                           |

  Scenario: SELECT * FROM catalogTest.tab4 WHERE money >= 'Hugo';
    When I execute a query: 'SELECT * FROM catalogTest.tab4 WHERE money >= 'Hugo';'
    Then an exception 'IS' thrown
    
  
   Scenario: SELECT * FROM catalogTest.tab5 WHERE money >= 0.0;
    When I execute a query: 'SELECT * FROM catalogTest.tab5 WHERE money >= 0.0;'
    Then the result has to be:
      | catalogTest.tab5.money-money-Double | catalogTest.tab5.reten-reten-Double |
      | 1.1                                 | 10.10                               |
      | 2.2                                 | 20.20                               |
      | 3.3                                 | 30.30                               |

  Scenario: SELECT * FROM catalogTest.tab5 WHERE money >= 0;
    When I execute a query: 'SELECT * FROM catalogTest.tab5 WHERE money >= 0;'
    Then the result has to be:
      | catalogTest.tab5.money-money-Double | catalogTest.tab5.reten-reten-Double |
      | 1.1                                 | 10.10                               |
      | 2.2                                 | 20.20                               |
      | 3.3                                 | 30.30                               |

  Scenario: SELECT * FROM catalogTest.tab5 WHERE money >= 10;
    When I execute a query: 'SELECT * FROM catalogTest.tab5 WHERE money >= 10;'
    Then the result has to be:
      | catalogTest.tab5.money-money-Double | catalogTest.tab5.reten-reten-Double |

  Scenario: SELECT * FROM catalogTest.tab5 WHERE money >= -4.5;
    When I execute a query: 'SELECT * FROM catalogTest.tab5 WHERE money >= -4.5;'
    Then the result has to be:
      | catalogTest.tab5.money-money-Double | catalogTest.tab5.reten-reten-Double |
      | -4.4                                | -40.40                          |
      | 1.1                                 | 10.10                           |
      | 2.2                                 | 20.20                           |
      | 3.3                                 | 30.30                           |

  Scenario: SELECT * FROM catalogTest.tab5 WHERE money >= 'Hugo';
    When I execute a query: 'SELECT * FROM catalogTest.tab5 WHERE money >= 'Hugo';'
    Then an exception 'IS' thrown
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   