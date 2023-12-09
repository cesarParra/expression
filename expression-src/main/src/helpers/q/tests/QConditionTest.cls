/**
 * @description QConditionTest is used to test QCondition logic
 * @author Jean-Philippe Monette
 * @since 2017-04-21
 */
@IsTest
private class QConditionTest {
	@IsTest
	static void testEqualsString() {
		String segment = new QCondition('Name').equalsTo('Jean-Philippe Monette').build();
		System.assertEquals('Name = \'Jean-Philippe Monette\'', segment, 'It should output an equal condition.');
	}

	@IsTest
	static void testEqualsInteger() {
		String segment = new QCondition('Age').equalsTo(5).build();
		System.assertEquals('Age = 5', segment, 'It should output an equal integer condition.');
	}

	@IsTest
	static void testNotEquals() {
		String segment = new QCondition('Name').notEqualsTo('Jean-Philippe Monette').build();
		System.assertEquals('Name != \'Jean-Philippe Monette\'', segment, 'It should output a not equal condition.');
	}

	@isTest
	static void testIsLessThan() {
		String segment = new QCondition('Age').isLessThan(5).build();
		System.assertEquals('Age < 5', segment, 'It should output a less than condition.');
	}

	@IsTest
	static void testIsLessOrEquals() {
		String segment = new QCondition('Age').isLessOrEquals(5).build();
		System.assertEquals('Age <= 5', segment, 'It should output a less or equal condition.');
	}

	@IsTest
	static void testIsGreaterThan() {
		String segment = new QCondition('Age').isGreaterThan(5).build();
		System.assertEquals('Age > 5', segment, 'It should output a greather than condition.');
	}

	@IsTest
	static void testIsGreaterOrEquals() {
		String segment = new QCondition('Age').isGreaterOrEquals(5).build();
		System.assertEquals('Age >= 5', segment, 'It should output a greater or equal condition.');
	}

	@IsTest
	static void testIsLike() {
		String segment = new QCondition('Name').isLike('%Acme%').build();
		System.assertEquals('Name LIKE \'%Acme%\'', segment, 'It should output a LIKE condition.');
	}

	@isTest
	static void testIsIn() {
		List<String> names = new List<String>{'John', 'Jane'};
		String segment = new QCondition('Name').isIn(names).build();
		System.assertEquals('Name IN (\'John\', \'Jane\')', segment, 'It should output an IN condition.');
	}

	@IsTest
	static void testIsNotIn() {
		List<String> names = new List<String>{'John', 'Jane'};
		String segment = new QCondition('Name').isNotIn(names).build();
		System.assertEquals('Name NOT IN (\'John\', \'Jane\')', segment, 'It should output a NOT IN condition.');
	}

	@IsTest
	static void testIncludes() {
		List<String> markets = new List<String>{'APAC', 'EMEA'};
		String segment = new QCondition('Market').includes(markets).build();
		System.assertEquals('Market INCLUDES (\'APAC\', \'EMEA\')', segment, 'It should output an INCLUDES condition.');
	}

	@isTest
	static void testExcludes() {
		List<String> markets = new List<String>{'APAC', 'EMEA'};
		String segment = new QCondition('Market').excludes(markets).build();
		System.assertEquals('Market EXCLUDES (\'APAC\', \'EMEA\')', segment, 'It should output a EXCLUDES condition.');
	}

	@IsTest
	static void testIsNull() {
		String segment = new QCondition('Name').isNull().build();
		System.assertEquals('Name = null', segment, 'It should output an IS NULL condition.');
	}

	@IsTest
	static void testIsNotNull() {
		String segment = new QCondition('Name').isNotNull().build();
		System.assertEquals('Name != null', segment, 'It should output a IS NOT NULL condition.');
	}

}
