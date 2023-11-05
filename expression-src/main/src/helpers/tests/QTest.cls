@IsTest
private class QTest {
    @IsTest
    static void testConstructor() {
        String query = new Q(Account.SObjectType).build();

        String expected = 'SELECT Id FROM Account';
        System.assertEquals(expected, query, 'It should output a default query.');
        Database.query(query);
    }

    @IsTest
    static void testAddSubQuery() {
        String query = new Q(Account.SObjectType).addSubquery(new Q('Contacts')).build();

        String expected = 'SELECT (SELECT Id FROM Contacts) FROM Account';
        System.assertEquals(expected, query, 'It should output a query with subquery.');
        Database.query(query);
    }


    @IsTest
    static void testSelectFieldsUsingSetString() {
        String query = new Q(Account.SObjectType)
            .selectFields(new Set<String>{ 'CreatedById', 'Description', 'Owner.Email' })
            .build();

        String expected = 'SELECT CreatedById, Description, Owner.Email FROM Account';
        System.assertEquals(expected.toLowerCase(), query.toLowerCase(), 'It should output a query with a SELECT.');
        Database.query(query);
    }
}