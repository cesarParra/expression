/**
 * @description QTest is used to test Q logic
 * @author Jean-Philippe Monette
 * @since 2017-03-21
 */
@IsTest
private class QTest {

    @IsTest
    static void testConstructor() {
        String query =
            new Q(Account.SObjectType)
                .build();

        String expected = 'SELECT Id FROM Account';
        System.assertEquals(expected, query, 'It should output a default query.');
        Database.query(query);
    }

    @IsTest
    static void testAddSubQuery() {
        String query =
            new Q(Account.SObjectType)
                .addSubquery(new Q('Contacts'))
                .build();

        String expected = 'SELECT (SELECT Id FROM Contacts) FROM Account';
        System.assertEquals(expected, query, 'It should output a query with subquery.');
        Database.query(query);
    }

    @IsTest
    static void testSelectFieldsUsingSetString() {
        String query =
            new Q(Account.SObjectType)
                .selectFields(new Set<String>{
                    'CreatedById', 'Description', 'Owner.Email'
                })
                .build();

        String expected = 'SELECT CreatedById, Description, Owner.Email FROM Account';
        System.assertEquals(expected, query, 'It should output a query with a SELECT.');
        Database.query(query);
    }

    @IsTest
    static void testAddOrders() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.orderBy('Name').nullsLast())
                .add(Q.orderBy('BillingCountry').descending())
                .build();

        String expected = 'SELECT Id FROM Account ORDER BY Name ASC NULLS LAST, BillingCountry DESC';
        System.assertEquals(expected, query, 'It should output a query with orders.');
        Database.query(query);
    }

    @IsTest
    static void testAddCondition1() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.condition('BillingCountry').isNotNull())
                .build();

        String expected = 'SELECT Id FROM Account WHERE BillingCountry != null';
        System.assertEquals(expected, query, 'It should output a query with a condition.');
        Database.query(query);
    }

    @IsTest
    static void testAddCondition2() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.condition('Name').isLike('%Acme%'))
                .build();

        String expected = 'SELECT Id FROM Account WHERE Name LIKE \'%Acme%\'';
        System.assertEquals(expected, query, 'It should output a query with a condition.');
        Database.query(query);
    }

    @IsTest
    static void testAddLimit() {
        String query =
            new Q(Account.SObjectType)
                .addLimit(5)
                .build();

        String expected = 'SELECT Id FROM Account LIMIT 5';
        System.assertEquals(expected, query, 'It should output a query with a LIMIT.');
        Database.query(query);
    }

    @IsTest
    static void testAddOffset() {
        String query =
            new Q(Account.SObjectType)
                .addOffset(5)
                .build();

        String expected = 'SELECT Id FROM Account OFFSET 5';
        System.assertEquals(expected, query, 'It should output a query with an OFFSET.');
        Database.query(query);
    }

    @IsTest
    static void testOrGroup() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.orGroup()
                    .add(Q.condition('Name').equalsTo('test'))
                    .add(Q.condition('Name').equalsTo('test'))
                )
                .build();

        String expected = 'SELECT Id FROM Account WHERE (Name = \'test\' OR Name = \'test\')';
        System.assertEquals(expected, query, 'It should output a query with a condition group.');
        Database.query(query);

        List<QCondition> conditions = new List<QCondition>();
        conditions.add(Q.condition('Name').equalsTo('test'));
        conditions.add(Q.condition('Name').equalsTo('test'));
        QOrGroup sbOrGroup = new QOrGroup(conditions);
        query =
            new Q(Account.SObjectType)
                .add(sbOrGroup)
                .build();

        String expected2 = 'SELECT Id FROM Account WHERE (Name = \'test\' OR Name = \'test\')';
        System.assertEquals(expected2, query, 'It should output a query with a condition group.');
        Database.query(query);
    }

    @IsTest
    static void testAndGroup() {
        String query =
            new Q(Account.SObjectType)
                .add(Q.andGroup()
                    .add(Q.condition('Name').equalsTo('test'))
                    .add(Q.condition('Name').equalsTo('test'))
                )
                .build();

        String expected = 'SELECT Id FROM Account WHERE (Name = \'test\' AND Name = \'test\')';
        System.assertEquals(expected, query, 'It should output a query with a condition group.');
        Database.query(query);

        List<QCondition> conditions = new List<QCondition>();
        conditions.add(Q.condition('Name').equalsTo('test'));
        conditions.add(Q.condition('Name').equalsTo('test'));
        QAndGroup sbAndGroup = new QAndGroup(conditions);
        query =
            new Q(Account.SObjectType)
                .add(sbAndGroup)
                .build();

        String expected2 = 'SELECT Id FROM Account WHERE (Name = \'test\' AND Name = \'test\')';
        System.assertEquals(expected2, query, 'It should output a query with a condition group.');
        Database.query(query);
    }
}
