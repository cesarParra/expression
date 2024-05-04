@IsTest
private class QSalesforceDatabaseTest {
    @IsTest
    static void testConstructor() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType));

        String expected = 'SELECT Id FROM Account';
        Assert.areEqual(expected, query, 'It should output a default query.');
    }

    @IsTest
    static void testSelectFieldsUsingSetString() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .selectFields(new Set<String>{
                    'CreatedById', 'Description', 'Owner.Email'
                }));

        String expected = 'SELECT CreatedById, Description, Owner.Email FROM Account';
        System.assertEquals(expected, query, 'It should output a query with a SELECT.');
    }

    @IsTest
    static void testAddOrders() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(Q.orderBy('Name').nullsLast())
                .add(Q.orderBy('BillingCountry').descending()));

        String expected = 'SELECT Id FROM Account ORDER BY Name ASC NULLS LAST, BillingCountry DESC';
        System.assertEquals(expected, query, 'It should output a query with orders.');
    }

    @IsTest
    static void testAddCondition1() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(Q.condition('BillingCountry').isNotNull()));

        String expected = 'SELECT Id FROM Account WHERE BillingCountry != null';
        System.assertEquals(expected, query, 'It should output a query with a condition.');
    }

    @IsTest
    static void testAddCondition2() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(Q.condition('Name').isLike('%Acme%')));

        String expected = 'SELECT Id FROM Account WHERE Name LIKE \'%Acme%\'';
        System.assertEquals(expected, query, 'It should output a query with a condition.');
    }

    @IsTest
    static void testAddLimit() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .addLimit(5));

        String expected = 'SELECT Id FROM Account LIMIT 5';
        System.assertEquals(expected, query, 'It should output a query with a LIMIT.');
    }

    @IsTest
    static void testAddOffset() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .addOffset(5));

        String expected = 'SELECT Id FROM Account OFFSET 5';
        System.assertEquals(expected, query, 'It should output a query with an OFFSET.');
    }

    @IsTest
    static void testOrGroup() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(Q.orGroup()
                    .add(Q.condition('Name').equalsTo('test'))
                    .add(Q.condition('Name').equalsTo('test'))
                ));

        String expected = 'SELECT Id FROM Account WHERE (Name = \'test\' OR Name = \'test\')';
        System.assertEquals(expected, query, 'It should output a query with a condition group.');

        List<QCondition> conditions = new List<QCondition>();
        conditions.add(Q.condition('Name').equalsTo('test'));
        conditions.add(Q.condition('Name').equalsTo('test'));
        QOrGroup sbOrGroup = new QOrGroup(conditions);
        query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(sbOrGroup));

        String expected2 = 'SELECT Id FROM Account WHERE (Name = \'test\' OR Name = \'test\')';
        System.assertEquals(expected2, query, 'It should output a query with a condition group.');
    }

    @IsTest
    static void testAndGroup() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(Q.andGroup()
                    .add(Q.condition('Name').equalsTo('test'))
                    .add(Q.condition('Name').equalsTo('test'))
                ));

        String expected = 'SELECT Id FROM Account WHERE (Name = \'test\' AND Name = \'test\')';
        System.assertEquals(expected, query, 'It should output a query with a condition group.');

        List<QCondition> conditions = new List<QCondition>();
        conditions.add(Q.condition('Name').equalsTo('test'));
        conditions.add(Q.condition('Name').equalsTo('test'));
        QAndGroup sbAndGroup = new QAndGroup(conditions);
        query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .add(sbAndGroup));

        String expected2 = 'SELECT Id FROM Account WHERE (Name = \'test\' AND Name = \'test\')';
        System.assertEquals(expected2, query, 'It should output a query with a condition group.');
    }

    @IsTest
    static void testAddSubQuery() {
        String query =
            QSalesforceDatabase.getInstance().build(new Q(Account.SObjectType)
                .addSubquery(new Q('Contacts')));

        String expected = 'SELECT (SELECT Id FROM Contacts) FROM Account';
        System.assertEquals(expected, query, 'It should output a query with subquery.');
        Database.query(query);
    }
}
