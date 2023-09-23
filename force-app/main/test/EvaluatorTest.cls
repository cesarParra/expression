@IsTest
private class EvaluatorTest {
    @IsTest
    private static void supportsNumberLiterals() {
        Assert.areEqual(100, Evaluator.run('100'));
    }

    @IsTest
    private static void supportsStringLiterals() {
        Assert.areEqual('abc', Evaluator.run('"abc"'));
    }

    @IsTest
    private static void supportsAddition_2Numbers() {
        Assert.areEqual(3, Evaluator.run('1 + 2'));
    }

    @IsTest
    private static void supportsAddition_3Numbers() {
        Assert.areEqual(6, Evaluator.run('1 + 2 + 3'));
    }

    @IsTest
    private static void supportsDecimalNumbers() {
        Assert.areEqual(1.5, Evaluator.run('1.5'));
    }

    @IsTest
    private static void supportsStringConcatenation_plus() {
        Assert.areEqual('abc', Evaluator.run('"a" + "b" + "c"'));
    }

    @IsTest
    private static void supportsStringConcatenation_ampersand() {
        Assert.areEqual('abc', Evaluator.run('"a" & "b" & "c"'));
    }

    @IsTest
    private static void supportsSubtraction() {
        Assert.areEqual(1, Evaluator.run('2 - 1'));
    }

    @IsTest
    private static void supportsMultiplication() {
        Assert.areEqual(6, Evaluator.run('2 * 3'));
    }

    @IsTest
    private static void supportsDivision() {
        Assert.areEqual(2, Evaluator.run('6 / 3'));
    }

    @IsTest
    private static void supportsExponentiation() {
        Assert.areEqual(8, Evaluator.run('2 ^ 3'));
    }

    @IsTest
    private static void supportsParentheses_toTheLeft() {
        Assert.areEqual(9, Evaluator.run('(1 + 2) * 3'));
    }

    @IsTest
    private static void supportsParentheses_toTheRight() {
        Assert.areEqual(9, Evaluator.run('3 * (1 + 2)'));
    }

    @IsTest
    private static void supportsEquality_singleEqualCharacter() {
        Assert.areEqual(true, Evaluator.run('1 = 1'));
    }

    @IsTest
    private static void supportsEquality_doubleEqualCharacter() {
        Assert.areEqual(true, Evaluator.run('1 == 1'));
    }

    @IsTest
    private static void supportsInequality_bangEqual() {
        Assert.areEqual(true, Evaluator.run('1 != 2'));
    }

    @IsTest
    private static void supportsInequality_lessThanGreaterThan() {
        Assert.areEqual(true, Evaluator.run('1 <> 2'));
    }

    @IsTest
    private static void supportsLessThan() {
        Assert.areEqual(true, Evaluator.run('1 < 2'));
    }

    @IsTest
    private static void supportsLessThanOrEqual() {
        Assert.areEqual(true, Evaluator.run('1 <= 2'));
    }

    @IsTest
    private static void supportsGreaterThan() {
        Assert.areEqual(true, Evaluator.run('2 > 1'));
    }

    @IsTest
    private static void supportsGreaterThanOrEqual() {
        Assert.areEqual(true, Evaluator.run('2 >= 1'));
    }

    @IsTest
    private static void supportsAnd() {
        Assert.areEqual(true, Evaluator.run('1 = 1 && (2 = 2)'));
    }

    @IsTest
    private static void supportsAnd_leftFalse() {
        Assert.areEqual(false, Evaluator.run('1 = 2 && 2 = 2'));
    }

    @IsTest
    private static void supportsAnd_rightFalse() {
        Assert.areEqual(false, Evaluator.run('1 = 1 && (2 = 3)'));
    }

    @IsTest
    private static void supportsAnd_withOr() {
        Assert.areEqual(true, Evaluator.run('((1 = 1) && (2 = 2)) || (3 = 3)'));
    }

    @IsTest
    private static void supportsOr() {
        Assert.areEqual(true, Evaluator.run('1 = 1 || (2 = 2)'));
    }

    @IsTest
    private static void supportsOr_leftFalse() {
        Assert.areEqual(true, Evaluator.run('1 = 2 || (2 = 2)'));
    }

    @IsTest
    private static void supportsOr_rightFalse() {
        Assert.areEqual(true, Evaluator.run('1 = 1 || (2 = 3)'));
    }

    @IsTest
    private static void supportsNegatingExpression() {
        Assert.areEqual(false, Evaluator.run('!(1=1)'));
    }

    @IsTest
    private static void supportsMinusBeforeNumber() {
        Assert.areEqual(-1, Evaluator.run('-1'));
    }

    @IsTest
    private static void supportsTrueLiterals() {
        Assert.areEqual(true, Evaluator.run('true'));
    }

    @IsTest
    private static void trueLiteralsAreCaseInsensitive() {
        Assert.areEqual(true, Evaluator.run('TRUE'));
    }

    @IsTest
    private static void supportsFalseLiterals() {
        Assert.areEqual(false, Evaluator.run('false'));
    }

    @IsTest
    private static void falseLiteralsAreCaseInsensitive() {
        Assert.areEqual(false, Evaluator.run('FALSE'));
    }

    @IsTest
    private static void supportsNullLiterals() {
        Assert.areEqual(null, Evaluator.run('null'));
    }

    @IsTest
    private static void canEvaluateAndFunctionWith2Arguments() {
        Assert.areEqual(true, Evaluator.run('AND(true, true)'));
    }

    @IsTest
    private static void canEvaluateAndFunctionWithMoreThan2Arguments() {
        Assert.areEqual(true, Evaluator.run('AND(true, true, true)'));
    }

    @IsTest
    private static void andFunctionWithAnyFalseReturnsFalse() {
        Assert.areEqual(false, Evaluator.run('AND(true, false, true)'));
    }

    @IsTest
    private static void ifFunctionEvaluatesFirstArgumentWhenTrue() {
        Assert.areEqual(1, Evaluator.run('IF(true, 1, 2)'));
    }

    @IsTest
    private static void ifFunctionEvaluatesSecondArgumentWhenFalse() {
        Assert.areEqual(2, Evaluator.run('IF(false, 1, 2)'));
    }

    @IsTest
    private static void notFunctionNegatesATrueExpression() {
        Assert.areEqual(false, Evaluator.run('NOT(1=1)'));
    }

    @IsTest
    private static void notFunctionNegatesAFalseExpression() {
        Assert.areEqual(true, Evaluator.run('NOT(1=2)'));
    }

    @IsTest
    private static void orFunctionReturnsTrueIfAllArgumentsAreTrue() {
        Assert.areEqual(true, Evaluator.run('OR(true, true, true)'));
    }

    @IsTest
    private static void orFunctionReturnsTrueIfAnyArgumentIsTrue() {
        Assert.areEqual(true, Evaluator.run('OR(true, false, false)'));
    }

    @IsTest
    private static void orFunctionReturnsFalseIfAllArgumentsAreFalse() {
        Assert.areEqual(false, Evaluator.run('OR(false, false, false)'));
    }

    @IsTest
    private static void beginsFunctionReturnsTrueIfFirstArgumentBeginsWithSecondArgument() {
        Assert.areEqual(true, Evaluator.run('BEGINS("Hello World", "Hello")'));
    }

    @IsTest
    private static void beginsFunctionReturnsFalseIfFirstArgumentDoesNotBeginWithSecondArgument() {
        Assert.areEqual(false, Evaluator.run('BEGINS("Hello World", "World")'));
    }

    @IsTest
    private static void containsFunctionReturnsTrueIfFirstArgumentContainsSecondArgument() {
        Assert.areEqual(true, Evaluator.run('CONTAINS("Hello World", "llo Wo")'));
    }

    @IsTest
    private static void containsFunctionReturnsFalseIfFirstArgumentDoesNotContainSecondArgument() {
        Assert.areEqual(false, Evaluator.run('CONTAINS("Hello World", "Goodbye")'));
    }

    @IsTest
    private static void lowerFunctionReturnsLowercaseString() {
        Assert.areEqual('hello world', Evaluator.run('LOWER("Hello World")'));
    }

    @IsTest
    private static void dateEvaluatesToADate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATE(2015, 1, 1)'));
    }

    @IsTest
    private static void absFunctionReturnsAbsoluteValue() {
        Assert.areEqual(1, Evaluator.run('ABS(-1)'));
    }

    @IsTest
    private static void findFunctionReturnsIndexOfSubstring() {
        Assert.areEqual(1, Evaluator.run('FIND("ello", "Hello")'));
    }

    @IsTest
    private static void findFunctionReturnsTheCorrectIndexWhenAStartingPositionIsSpecified() {
        Assert.areEqual(4, Evaluator.run('FIND("ab", "abcdabcd", 1)'));
    }

    @IsTest
    private static void findFunctionReturnsMinusOneWhenSubstringIsNotFound() {
        Assert.areEqual(-1, Evaluator.run('FIND("ab", "abcdabcd", 5)'));
    }

    @IsTest
    private static void addMonthsFunctionAddsMonths() {
        Assert.areEqual(Date.newInstance(2015, 2, 1), Evaluator.run('ADDMONTHS(DATE(2015, 1, 1), 1)'));
    }

    @IsTest
    private static void blankValueReturnsFallbackIfValueIsNull() {
        Assert.areEqual('fallback', Evaluator.run('BLANKVALUE(null, "fallback")'));
    }

    @IsTest
    private static void blankValueReturnsValueIfValueIsNotNull() {
        Assert.areEqual('value', Evaluator.run('BLANKVALUE("value", "fallback")'));
    }

    @IsTest
    private static void blankValueReturnsFallbackIfStringIsBlank() {
        Assert.areEqual('fallback', Evaluator.run('BLANKVALUE("", "fallback")'));
    }

    @IsTest
    private static void ceilingFunctionReturnsCeiling() {
        Assert.areEqual(2, Evaluator.run('CEILING(1.5)'));
    }

    @IsTest
    private static void leftFunctionReturnsLeftSubstring() {
        Assert.areEqual('Hello', Evaluator.run('LEFT("Hello World", 5)'));
    }

    @IsTest
    private static void dayFunctionReturnsDay() {
        Assert.areEqual(1, Evaluator.run('DAY(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void isBlankReturnsTrueForAnEmptyString() {
        Assert.areEqual(true, Evaluator.run('ISBLANK("")'));
    }

    @IsTest
    private static void isBlankReturnsTrueForNull() {
        Assert.areEqual(true, Evaluator.run('ISBLANK(null)'));
    }

    @IsTest
    private static void floorFunctionReturnsFloor() {
        Assert.areEqual(1, Evaluator.run('FLOOR(1.5)'));
    }

    @IsTest
    private static void lenFunctionReturnsLength() {
        Assert.areEqual(5, Evaluator.run('LEN("Hello")'));
    }

    @IsTest
    private static void dayOfYearFunctionReturnsDayOfYear() {
        Assert.areEqual(1, Evaluator.run('DAYOFYEAR(DATE(2015, 1, 1))'));
        Assert.areEqual(365, Evaluator.run('DAYOFYEAR(DATE(2015, 12, 31))'));
    }

    @IsTest
    private static void fromUnixTimeFunctionReturnsADatetimeFromUnixTime() {
        Assert.areEqual(Datetime.newInstanceGmt(2015, 1, 1, 0, 0, 0), Evaluator.run('FROMUNIXTIME(1420070400)'));
    }

    @IsTest
    private static void lpadFunctionReturnsLeftPaddedStringWhenTheDesiredLengthIsGreaterThanTheStringLength() {
        Assert.areEqual('0001', Evaluator.run('LPAD("1", 4, "0")'));
    }

    @IsTest
    private static void lpadFunctionReturnsTheStringWhenTheDesiredLengthIsLessThanTheStringLength() {
        Assert.areEqual('1234', Evaluator.run('LPAD("1234", 2, "0")'));
    }

    @IsTest
    private static void lpadFunctionPadsWithABlankStringWhenNo3rdArgumentIsSpecified() {
        Assert.areEqual('   1', Evaluator.run('LPAD("1", 4)'));
    }

    @IsTest
    private static void rpadFunctionReturnsRightPaddedStringWhenTheDesiredLengthIsGreaterThanTheStringLength() {
        Assert.areEqual('1000', Evaluator.run('RPAD("1", 4, "0")'));
    }

    @IsTest
    private static void rpadFunctionReturnsTheStringWhenTheDesiredLengthIsLessThanTheStringLength() {
        Assert.areEqual('1234', Evaluator.run('RPAD("1234", 2, "0")'));
    }

    @IsTest
    private static void rpadFunctionPadsWithABlankStringWhenNo3rdArgumentIsSpecified() {
        Assert.areEqual('1   ', Evaluator.run('RPAD("1", 4)'));
    }

    @IsTest
    private static void nowFunctionReturnsAValue() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(Evaluator.run('NOW()'));
    }

    @IsTest
    private static void dateValueFunctionConvertsAStringToDate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATEVALUE("2015-01-01")'));
    }

    @IsTest
    private static void dateValueFunctionConvertsADatetimeToDate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATEVALUE(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void datetimeValueFunctionConvertsAStringToADatetime() {
        Assert.areEqual(Datetime.newInstance(2015, 1, 1, 0, 0, 0), Evaluator.run('DATETIMEVALUE("2015-01-01 00:00:00")'));
    }

    @IsTest
    private static void canReferenceAMergeField() {
        Account account = new Account(Name = 'Test');
        Assert.areEqual('Test', Evaluator.run('Name', account));
    }

    @IsTest
    private static void todayFunctionReturnsToday() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(Evaluator.run('TODAY()'));
    }

    @IsTest
    private static void isNumberReturnsTrueForANumber() {
        Assert.areEqual(true, Evaluator.run('ISNUMBER(1)'));
    }

    @IsTest
    private static void isNumberReturnsFalseForANonNumber() {
        Assert.areEqual(false, Evaluator.run('ISNUMBER("1")'));
    }

    @IsTest
    private static void isNumberReturnsTrueForNumberMergeField() {
        Account account = new Account(NumberOfEmployees = 1);
        Assert.areEqual(true, Evaluator.run('ISNUMBER(NumberOfEmployees)', account));
    }

    @IsTest
    private static void maxFunctionReturnsTheMaximumValue() {
        Assert.areEqual(2, Evaluator.run('MAX(1, 2)'));
    }

    @IsTest
    private static void maxFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(3, Evaluator.run('MAX(1, 2, 3)'));
    }

    @IsTest
    private static void maxFunctionAcceptsAListAsAsArgument() {
        Assert.areEqual(3, Evaluator.run('MAX(LIST(1, 2, 3))'));
    }

    @IsTest
    private static void minFunctionReturnsTheMinimumValue() {
        Assert.areEqual(1, Evaluator.run('MIN(1, 2)'));
    }

    @IsTest
    private static void minFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(1, Evaluator.run('MIN(1, 2, 3)'));
    }

    @IsTest
    private static void reverseFunctionReversesAString() {
        Assert.areEqual('cba', Evaluator.run('REVERSE("abc")'));
    }

    @IsTest
    private static void roundFunctionRoundsUp() {
        Assert.areEqual(2, Evaluator.run('ROUND(1.5)'));
    }

    @IsTest
    private static void roundFunctionRoundsDown() {
        Assert.areEqual(1, Evaluator.run('ROUND(1.4)'));
    }

    @IsTest
    private static void roundFunctionAcceptsAnOptionalSecondArgument() {
        Assert.areEqual(1.5, Evaluator.run('ROUND(1.45, 1)'));
    }

    @IsTest
    private static void timeValueFunctionReturnsTheTimeValueOfADateTime() {
        Assert.areEqual(Time.newInstance(2, 0, 0, 0), Evaluator.run('TIMEVALUE(DATETIMEVALUE("2015-01-01 02:00:00"))'));
    }

    @IsTest
    private static void timeValueFunctionReturnsTheTimeValueOfADateTimeString() {
        Assert.areEqual(Time.newInstance(17, 30, 45, 125), Evaluator.run('TIMEVALUE("17:30:45.125")'));
    }

    @IsTest
    private static void truncFunctionTruncatesToTheSpecifiedNumberOfDigits() {
        Assert.areEqual(1.234, Evaluator.run('TRUNC(1.2345, 3)'));
    }

    @IsTest
    private static void truncFunctionTruncatesToZeroDigits() {
        Assert.areEqual(1, Evaluator.run('TRUNC(1.2345, 0)'));
    }

    @IsTest
    private static void truncReturnsTheIntegerPartOfANumberWhenNo2ndArgumentIsSpecified() {
        Assert.areEqual(1, Evaluator.run('TRUNC(1.2345)'));
    }

    @IsTest
    private static void midFunctionCanReturnsFromTheBeginningOfTheStringWhenTheFirstArgumentIs1() {
        Assert.areEqual('abc', Evaluator.run('MID("abc", 1, 3)'));
    }

    @IsTest
    private static void midFunctionReturnsASubstringBeginningAtTheSpecifiedPosition() {
        Assert.areEqual('b', Evaluator.run('MID("abc", 2, 1)'));
    }

    @IsTest
    private static void substringFunctionReturnsASubstringBeginningAtTheSpecifiedPosition() {
        Assert.areEqual('bc', Evaluator.run('SUBSTRING("abc", 2, 2)'));
    }

    @IsTest
    private static void substringFunctionReturnsASubstringBeginningAtTheSpecifiedPositionWhenTheFirstArgumentIs1() {
        Assert.areEqual('abc', Evaluator.run('SUBSTRING("abc", 1, 3)'));
    }

    @IsTest
    private static void substringFunctionReturnsTheEntireStringBeginningAtTheSpecifiedPositionWhenTheThirdArgumentIsOmitted() {
        Assert.areEqual('bc', Evaluator.run('SUBSTRING("abc", 2)'));
    }

    @IsTest
    private static void timenowFunctionReturnsTheCurrentTime() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(Evaluator.run('TIMENOW()'));
    }

    @IsTest
    private static void isoweekFunctionReturnsTheIsoWeek() {
        Assert.areEqual(1, Evaluator.run('ISOWEEK(DATE(2015, 1, 1))'));
        Assert.areEqual(52, Evaluator.run('ISOWEEK(DATE(2015, 12, 27))'));
    }

    @IsTest
    private static void rightFunctionReturnsRightSubstring() {
        Assert.areEqual('World', Evaluator.run('RIGHT("Hello World", 5)'));
    }

    @IsTest
    private static void rightFunctionWith0LengthReturnsAnEmptyString() {
        Assert.areEqual('', Evaluator.run('RIGHT("Hello World", 0)'));
    }

    @IsTest
    private static void rightFunctionWithLessThanZeroLengthReturnsAnEmptyString() {
        Assert.areEqual('', Evaluator.run('RIGHT("Hello World", -1)'));
    }

    @IsTest
    private static void isoyearFunctionReturnsTheIsoYear() {
        Assert.areEqual(2015, Evaluator.run('ISOYEAR(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void yearFunctionReturnsTheYear() {
        Assert.areEqual(2015, Evaluator.run('YEAR(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void millisecondFunctionReturnsTheMillisecond() {
        Assert.areEqual(123, Evaluator.run('MILLISECOND(TIMEVALUE("12:00:00.123"))'));
    }

    @IsTest
    private static void minuteFunctionReturnsTheMinute() {
        Assert.areEqual(30, Evaluator.run('MINUTE(TIMEVALUE("12:30:00"))'));
    }

    @IsTest
    private static void secondFunctionReturnsTheSecond() {
        Assert.areEqual(45, Evaluator.run('SECOND(TIMEVALUE("12:00:45"))'));
    }

    @IsTest
    private static void hourFunctionReturnsTheHour() {
        Assert.areEqual(12, Evaluator.run('HOUR(TIMEVALUE("12:00:00"))'));
    }

    @IsTest
    private static void listFunctionReturnsAListContainingAllArguments() {
        Object result = Evaluator.run('LIST(1, 2, 3)');
        Assert.isTrue(result instanceof List<Object>);
        Assert.areEqual(1, ((List<Object>) result)[0]);
        Assert.areEqual(2, ((List<Object>) result)[1]);
        Assert.areEqual(3, ((List<Object>) result)[2]);
    }

    @IsTest
    private static void averageFunctionReturnsTheAverage() {
        Assert.areEqual(2, Evaluator.run('AVERAGE(LIST(1, 2, 3))'));
    }

    @IsTest
    private static void mapFunctionReturnsGivenAChildRelationshipAndAFieldName() {
        Account account = new Account(Name = 'Test');
        insert account;
        Contact contact1 = new Contact(LastName = 'Test1', AccountId = account.Id);
        Contact contact2 = new Contact(LastName = 'Test2', AccountId = account.Id);
        insert new List<SObject>{
            contact1, contact2
        };
        Account accountWithContacts = [SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account WHERE Id = :account.Id];

        List<Object> result = (List<Object>) Evaluator.run('MAP(Contacts, LastName)', accountWithContacts);

        Assert.areEqual(2, result.size());
        Assert.areEqual('Test1', result[0]);
        Assert.areEqual('Test2', result[1]);
    }

    @IsTest
    private static void canCombineListFunctionsWithMap() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        Decimal result = (Decimal) Evaluator.run('AVERAGE(MAP(ChildAccounts, NumberOfEmployees))', parentAccountWithChildren);

        Assert.areEqual(15, result);
    }

    @IsTest
    private static void canUseARecordIdAsContext() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Object result = Evaluator.run('Name', accountRecord.Id);

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void usingARecordIdAsTheContextConsumesAQuery() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Integer queriesConsumedBefore = Limits.getQueries();
        Evaluator.run('Name', accountRecord.Id);
        Integer queriesConsumedAfter = Limits.getQueries();

        Assert.areEqual(1, queriesConsumedAfter - queriesConsumedBefore);
    }

    @IsTest
    private static void doesNotConsumeAQueryWhenThereAreNoMergeFieldsInTheFormula() {
        Integer queriesConsumedBefore = Limits.getQueries();
        Evaluator.run('1 + 1', IdGenerator.generate(Account.SObjectType));
        Integer queriesConsumedAfter = Limits.getQueries();

        Assert.areEqual(0, queriesConsumedAfter - queriesConsumedBefore);
    }

    @IsTest
    private static void canUseARecordIdAsContextToGetAggregateInformationFromChildren() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Object revenueByEmployee = Evaluator.run('AVERAGE(MAP(ChildAccounts, AnnualRevenue)) / AVERAGE(MAP(ChildAccounts, NumberOfEmployees))',
            parentAccount.Id);

        Assert.areEqual(10, revenueByEmployee);
    }

    @IsTest
    private static void canUseARecordIdAsContextToGetAggregateInformationFromChildren_withNullValues() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = null);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Decimal revenueByEmployee = (Decimal) Evaluator.run('AVERAGE(MAP(ChildAccounts, AnnualRevenue)) / AVERAGE(MAP(ChildAccounts, NumberOfEmployees))',
            parentAccount.Id);
        revenueByEmployee = revenueByEmployee.setScale(2);

        Assert.areEqual(13.33, revenueByEmployee);
    }

    @IsTest
    private static void dotNotationGetsRelatedData() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Name FROM Contact WHERE Id = :childContact.Id];

        Evaluator.run('Account.Name', queriedContact);
    }

    @IsTest
    private static void dotNotationThroughMultipleLevels() {
        Account greatGrandParent = new Account(Name = 'GreatGrandParent');
        insert greatGrandParent;

        Account grandParentAccount = new Account(Name = 'GrandParent', ParentId = greatGrandParent.Id);
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Parent.Parent.Name FROM Contact WHERE Id = :childContact.Id];

        Object result = Evaluator.run('Account.Parent.Parent.Name', queriedContact);

        Assert.areEqual('GreatGrandParent', result);
    }

    @IsTest
    private static void dotNotationThroughMultipleLevelsUsingId() {
        Account greatGrandParent = new Account(Name = 'GreatGrandParent');
        insert greatGrandParent;

        Account grandParentAccount = new Account(Name = 'GrandParent', ParentId = greatGrandParent.Id);
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Object result = Evaluator.run('Account.Parent.Parent.Name', childContact.Id);

        Assert.areEqual('GreatGrandParent', result);
    }

    @IsTest
    private static void brFunAdds1LineBreakWhenNoArgumentsArePassed() {
        Assert.areEqual('a\nb', Evaluator.run('"a" + BR() + "b"'));
    }

    @IsTest
    private static void brFunAdds1LineBreakWhen1ArgumentIsPassed() {
        Assert.areEqual('a\n\nb', Evaluator.run('"a" + BR(2) + "b"'));
    }

    @IsTest
    private static void caseFunctionReturnsTheCorrectValueWhenThereIsAMatch() {
        Account testAccount = new Account(Rating = 'Hot');

        Object result = Evaluator.run('CASE(Rating, "Hot", "🔥", "Cold", "🧊", "🤷")', testAccount);

        Assert.areEqual('🔥', result);
    }

    @IsTest
    private static void caseFunctionReturnsElseValueWhenThereIsNoMatch() {
        Account testAccount = new Account(Rating = 'Warm');

        Object result = Evaluator.run('CASE(Rating, "Hot", "🔥", "Cold", "🧊", "🤷")', testAccount);

        Assert.areEqual('🤷', result);
    }

    @IsTest
    private static void sizeFunctionReturnsAListSize() {
        Assert.areEqual(3, Evaluator.run('SIZE(LIST(1, 2, 3))'));
    }

    @IsTest
    private static void sizeFunctionReturnsAMapSize() {
        Assert.areEqual(2, Evaluator.run('SIZE({"a": 1, "b": 2})'));
    }

    @IsTest
    private static void canBuildListLiterals() {
        Assert.areEqual(3, Evaluator.run('SIZE([1, 2, 3])'));
    }

    @IsTest
    private static void spreadOperatorExpandsAList() {
        Assert.areEqual(3, Evaluator.run('SIZE([...LIST(1, 2, 3)])'));
    }

    @IsTest
    private static void spreadOperatorCanBeUsedInsideOfAListFunction() {
        Assert.areEqual(3, Evaluator.run('SIZE(LIST(...LIST(1, 2, 3)))'));
        Assert.areEqual(6, Evaluator.run('SIZE(LIST(1, 2, 3, ...[4, 5, 6]))'));
    }

    @IsTest
    private static void unixTimeStampReturnsTheCorrectNumberOfSecondsForADate() {
        // Uses GMT
        Assert.areEqual(1420070400, Evaluator.run('UNIXTIMESTAMP(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void unixTimeStampReturnsTheCorrectNumberForADateTime() {
        // Uses GMT
        Assert.areEqual(1420070400, Evaluator.run('UNIXTIMESTAMP(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void unixTimeStampReturnsTheNumberOfSecondsTheDayWhenReceivingATime() {
        Assert.areEqual(3600, Evaluator.run('UNIXTIMESTAMP(TIMEVALUE("01:00:00"))'), 'Expect the number of seconds for a given time');
    }

    @IsTest
    private static void weekDayReturnsTheDayOfTheWeek() {
        Assert.isNotNull(Evaluator.run('WEEKDAY(DATE(2015, 1, 5))'));
    }

    @IsTest
    private static void hyperlinkBuildsAnAnchorTag() {
        Assert.areEqual('<a href="https://www.google.com">Google</a>', Evaluator.run('HYPERLINK("https://www.google.com", "Google")'));
    }

    @IsTest
    private static void hyperLinkCanReceiveTheTargetAsAThirdParameters() {
        Assert.areEqual('<a href="https://www.google.com" target="_blank">Google</a>', Evaluator.run('HYPERLINK("https://www.google.com", "Google", "_blank")'));
    }

    @IsTest
    private static void substituteReplacesAllOccurrencesOfTheFirstArgumentWithTheSecondArgument() {
        Assert.areEqual('Heyo World', Evaluator.run('SUBSTITUTE("Hello World", "ll", "y")'));
    }

    @IsTest
    private static void textConvertsNumbersToString() {
        Assert.areEqual('1', Evaluator.run('TEXT(1)'));
    }

    @IsTest
    private static void textConvertsDateValues() {
        Assert.areEqual('1/1/2015', Evaluator.run('TEXT(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void textConvertsDateTimeValues() {
        Assert.areEqual('1/1/2015, 12:00 AM', Evaluator.run('TEXT(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void textConvertsFalseValues() {
        Assert.areEqual('false', Evaluator.run('TEXT(false)'));
    }

    @IsTest
    private static void textConvertsTrueValues() {
        Assert.areEqual('true', Evaluator.run('TEXT(true)'));
    }

    @IsTest
    private static void textConvertsTimeValues() {
        Assert.areEqual('12:00:00 AM', Evaluator.run('TEXT(TIMEVALUE("00:00:00"))'));
    }

    @IsTest
    private static void trimFunctionRemovesLeadingAndTrailingWhitespace() {
        Assert.areEqual('Hello World', Evaluator.run('TRIM("  Hello World  ")'));
    }

    @IsTest
    private static void upperFunctionConvertsToUppercase() {
        Assert.areEqual('HELLO WORLD', Evaluator.run('UPPER("Hello World")'));
    }

    @IsTest
    private static void mapLiteralCreatesAMap() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{"a": 1, "b": 2}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }

    @IsTest
    private static void mapsSupportTheSpreadOperator() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{...{"a": 1, "b": 2}}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }

    @IsTest
    private static void spreadOperatorInMapRespectTheRightmostValue() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{...{"a": 1, "b": 2}, "b": 3}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(3, result.get('b'));
    }

    @IsTest
    private static void canMapARegularListToASingleValue() {
        List<Object> result = (List<Object>) Evaluator.run('MAP(LIST("a", "b", "c"), upper($current))');
        Assert.areEqual('A', result[0]);
        Assert.areEqual('B', result[1]);
        Assert.areEqual('C', result[2]);
    }

    @IsTest
    private static void canMapToAnObjectLiteral() {
        List<Object> result = (List<Object>) Evaluator.run('MAP(LIST("a", "b", "c"), {$index: $current})');
        Assert.areEqual('a', ((Map<Object, Object>) result[0]).get(0));
        Assert.areEqual('b', ((Map<Object, Object>) result[1]).get(1));
        Assert.areEqual('c', ((Map<Object, Object>) result[2]).get(2));
    }

    @IsTest
    private static void shouldBeAbleToAccessDataFromParentWhenMappingAChildRelationshipList_recordAsContext() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees, Parent.Name FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        List<Object> result = (List<Object>) Evaluator.run('MAP(ChildAccounts, {"parentName": Parent.Name, "numberOfEmployees": NumberOfEmployees})', parentAccountWithChildren);

        Assert.areEqual('Parent', ((Map<Object, Object>) result[0]).get('parentName'));
        Assert.areEqual(10, ((Map<Object, Object>) result[0]).get('numberOfEmployees'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[1]).get('parentName'));
        Assert.areEqual(20, ((Map<Object, Object>) result[1]).get('numberOfEmployees'));
    }

    @IsTest
    private static void canExtractDataDirectlyFromChildren() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Object result = Evaluator.run('SIZE(ChildAccounts)', parentAccount.Id);

        Assert.areEqual(2, result);
    }

    @IsTest
    private static void shouldBeAbleToAccessDataFromParentWhenMappingAChildRelationshipList_idAsContext() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run(
            'MAP(ChildAccounts, {"parentName": Parent.Name, "numberOfEmployees": NumberOfEmployees})',
            parentAccount.Id
        );

        Assert.areEqual('Parent', ((Map<Object, Object>) result[0]).get('parentName'));
        Assert.areEqual(10, ((Map<Object, Object>) result[0]).get('numberOfEmployees'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[1]).get('parentName'));
        Assert.areEqual(20, ((Map<Object, Object>) result[1]).get('numberOfEmployees'));
    }

    @IsTest
    private static void theIdIsNotReferencedTwiceInTheQueryWhenReferenced() {
        Account parentAccount = new Account(Name = 'ACME');
        insert parentAccount;

        Account childAccount = new Account(Name = 'ACME Child', ParentId = parentAccount.Id);
        insert childAccount;

        Object result = Evaluator.run('map(ChildAccounts, Id)', parentAccount.Id);

        Assert.areEqual(childAccount.Id, ((List<Object>) result)[0]);
    }

    @IsTest
    private static void isEmptyReturnsTrueForAnEmptyList() {
        Assert.areEqual(true, Evaluator.run('ISEMPTY([])'));
    }

    @IsTest
    private static void isEmptyReturnsFalseForANonEmptyList() {
        Assert.areEqual(false, Evaluator.run('ISEMPTY([1])'));
    }

    @IsTest
    private static void isEmptyReturnsTrueForAnEmptyMap() {
        Assert.areEqual(true, Evaluator.run('ISEMPTY({})'));
    }

    @IsTest
    private static void isEmptyReturnsFalseForANonEmptyMap() {
        Assert.areEqual(false, Evaluator.run('ISEMPTY({"a": 1})'));
    }

    @IsTest
    private static void appendFunctionAppendsToAList() {
        List<Object> result = (List<Object>) Evaluator.run('APPEND([1, 2], 3)');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
    }

    @IsTest
    private static void sortFunctionSortsAList() {
        List<Object> result = (List<Object>) Evaluator.run('SORT([3, 2, 1])');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
    }

    @IsTest
    private static void reverseFunctionReversesAList() {
        List<Object> result = (List<Object>) Evaluator.run('REVERSE([1, 2, 3])');
        Assert.areEqual(3, result.size());
        Assert.areEqual(3, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(1, result[2]);
    }

    @IsTest
    private static void distinctFunctionReturnsDistinctValues() {
        List<Object> result = (List<Object>) Evaluator.run('DISTINCT([1, 2, 1, 3, 2, 4])');
        Assert.areEqual(4, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
        Assert.areEqual(4, result[3]);
    }

    @IsTest
    private static void keysFunctionReturnsTheKeysOfAMap() {
        List<Object> result = (List<Object>) Evaluator.run('KEYS({"a": 1, "b": 2})');
        Assert.areEqual(2, result.size());
        Assert.areEqual('a', result[0]);
        Assert.areEqual('b', result[1]);
    }

    @IsTest
    private static void getFunctionReturnsAMapValue() {
        Assert.areEqual(1, Evaluator.run('GET({"a": 1, "b": 2}, "a")'));
    }

    @IsTest
    private static void valuesFunctionReturnsTheValuesOfAMap() {
        List<Object> result = (List<Object>) Evaluator.run('VALUES({"a": 1, "b": 2})');
        Assert.areEqual(2, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
    }

    @IsTest
    private static void whereFunctionAllowsForValuesToBeFiltered() {
        List<Object> result = (List<Object>) Evaluator.run('WHERE([1, 2, 3, 4], $current > 2)');
        Assert.areEqual(2, result.size());
        Assert.areEqual(3, result[0]);
        Assert.areEqual(4, result[1]);
    }

    @IsTest
    private static void whereFunctionAllowsToFilterByFieldsOnChildRecords_usingRecord() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees, Parent.Name FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        List<Object> result = (List<Object>) Evaluator.run('WHERE(ChildAccounts, NumberOfEmployees > 10)', parentAccountWithChildren);

        Assert.areEqual(1, result.size());
        Assert.areEqual(20, ((Account) result[0]).NumberOfEmployees);
    }

    @IsTest
    private static void whereFunctionAllowsToFilterByFieldsOnChildRecords_usingId() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run('WHERE(ChildAccounts, NumberOfEmployees > 10)', parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual(20, ((Account) result[0]).NumberOfEmployees);
    }

    @IsTest
    private static void combiningWhereAndMap() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run('MAP(WHERE(ChildAccounts, NumberOfEmployees > 10), Name)', parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Child2', result[0]);
    }

    @IsTest
    private static void nestingWheres() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        Account childAccount3 = new Account(Name = 'Child3', ParentId = parentAccount.Id, NumberOfEmployees = 30, AnnualRevenue = 300);
        insert new List<SObject>{
            childAccount1, childAccount2, childAccount3
        };

        List<Object> result = (List<Object>) Evaluator.run('MAP(WHERE(WHERE(ChildAccounts, NumberOfEmployees > 10), AnnualRevenue > 200), Name)', parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Child3', result[0]);
    }

    @IsTest
    private static void canPipeFunctionCalls() {
        Assert.areEqual(3, Evaluator.run('LIST(1, 2, 3) -> SIZE()'));
    }

    @IsTest
    private static void canPipeFunctionCallsMultipleTimes() {
        Object result = Evaluator.run('[1, 2, 3, 4, 5, 6] -> WHERE($current > 2) -> WHERE($current < 5)');
        Assert.areEqual(2, ((List<Object>) result).size());
        Assert.areEqual(3, ((List<Object>) result)[0]);
        Assert.areEqual(4, ((List<Object>) result)[1]);
    }
}
