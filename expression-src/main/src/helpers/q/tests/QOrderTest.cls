/**
 * @description QOrderTest is used to test QOrder logic
 * @author Jean-Philippe Monette
 */
@IsTest
private class QOrderTest {
    @IsTest
    static void testConstructor() {
        String segment = new QSalesforceDatabase.QOrderBuilder().build(new QOrder('Name'));
        System.assertEquals('Name ASC', segment, 'It should output an ASC order by default.');
    }

    @IsTest
    static void testAscending() {
        String segment = new QSalesforceDatabase.QOrderBuilder().build(new QOrder('Name').ascending());
        System.assertEquals('Name ASC', segment, 'It should output an ASC order.');
    }

    @IsTest
    static void testDescending() {
        String segment = new QSalesforceDatabase.QOrderBuilder().build(new QOrder('Name').descending());
        System.assertEquals('Name DESC', segment, 'It should output a DESC order.');
    }

    @IsTest
    static void testNullsFirst() {
        String segment = new QSalesforceDatabase.QOrderBuilder().build(new QOrder('Name').nullsFirst());
        System.assertEquals('Name ASC NULLS FIRST', segment, 'It should output an ASC NULLS FIRST order.');
    }

    @IsTest
    static void testNullsLast() {
        String segment = new QSalesforceDatabase.QOrderBuilder().build(new QOrder('Name').nullsLast());
        System.assertEquals('Name ASC NULLS LAST', segment, 'It should output an ASC NULLS LAST order.');
    }
}
