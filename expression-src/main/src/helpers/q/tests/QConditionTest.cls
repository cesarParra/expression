/**
 * @description Tests QCondition logic building logic.
 * @author Jean-Philippe Monette
 */
@IsTest
private class QConditionTest {
    @IsTest
    static void testEqualsString() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').equalsTo('Jean-Philippe Monette'));
        System.assertEquals('Name = \'Jean-Philippe Monette\'', segment, 'It should output an equal condition.');
    }

    @IsTest
    static void testEqualsInteger() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Age').equalsTo(5));
        System.assertEquals('Age = 5', segment, 'It should output an equal integer condition.');
    }

    @IsTest
    static void testNotEquals() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').notEqualsTo('Jean-Philippe Monette'));
        System.assertEquals('Name != \'Jean-Philippe Monette\'', segment, 'It should output a not equal condition.');
    }

    @IsTest
    static void testIsLessThan() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Age').isLessThan(5));
        System.assertEquals('Age < 5', segment, 'It should output a less than condition.');
    }

    @IsTest
    static void testIsLessOrEquals() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Age').isLessOrEquals(5));
        System.assertEquals('Age <= 5', segment, 'It should output a less or equal condition.');
    }

    @IsTest
    static void testIsGreaterThan() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Age').isGreaterThan(5));
        System.assertEquals('Age > 5', segment, 'It should output a greather than condition.');
    }

    @IsTest
    static void testIsGreaterOrEquals() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Age').isGreaterOrEquals(5));
        System.assertEquals('Age >= 5', segment, 'It should output a greater or equal condition.');
    }

    @IsTest
    static void testIsLike() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').isLike('%Acme%'));
        System.assertEquals('Name LIKE \'%Acme%\'', segment, 'It should output a LIKE condition.');
    }

    @IsTest
    static void testIsIn() {
        List<String> names = new List<String>{
            'John', 'Jane'
        };
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').isIn(names));
        System.assertEquals('Name IN (\'John\', \'Jane\')', segment, 'It should output an IN condition.');
    }

    @IsTest
    static void testIsNotIn() {
        List<String> names = new List<String>{
            'John', 'Jane'
        };
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').isNotIn(names));
        System.assertEquals('Name NOT IN (\'John\', \'Jane\')', segment, 'It should output a NOT IN condition.');
    }

    @IsTest
    static void testIsNull() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').isNull());
        System.assertEquals('Name = null', segment, 'It should output an IS NULL condition.');
    }

    @IsTest
    static void testIsNotNull() {
        String segment = new QSalesforceDatabase.QCOnditionBuilder().build(new QCondition('Name').isNotNull());
        System.assertEquals('Name != null', segment, 'It should output a IS NOT NULL condition.');
    }
}
