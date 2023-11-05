@IsTest
private class EvaluatorTest {
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
    private static void dateEvaluatesToADate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATE(2015, 1, 1)'));
    }

    @IsTest
    private static void absFunctionReturnsAbsoluteValue() {
        Assert.areEqual(1, Evaluator.run('ABS(-1)'));
    }

    @IsTest
    private static void addMonthsFunctionAddsMonths() {
        Assert.areEqual(Date.newInstance(2015, 2, 1), Evaluator.run('ADDMONTHS(DATE(2015, 1, 1), 1)'));
    }

    @IsTest
    private static void ceilingFunctionReturnsCeiling() {
        Assert.areEqual(2, Evaluator.run('CEILING(1.5)'));
    }

    @IsTest
    private static void dayFunctionReturnsDay() {
        Assert.areEqual(1, Evaluator.run('DAY(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void floorFunctionReturnsFloor() {
        Assert.areEqual(1, Evaluator.run('FLOOR(1.5)'));
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
    private static void minFunctionReturnsTheMinimumValue() {
        Assert.areEqual(1, Evaluator.run('MIN(1, 2)'));
    }

    @IsTest
    private static void minFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(1, Evaluator.run('MIN(1, 2, 3)'));
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
    private static void canUseARecordIdAsContext() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Object result = Evaluator.run('Name', accountRecord.Id);

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void canUseARecordIdAsContext_runningWithoutSharing() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Object result = Evaluator.run('Name', accountRecord.Id, new Configuration().respectSharing(false));

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
    private static void canPipeFunctionCalls() {
        Assert.areEqual(3, Evaluator.run('LIST(1, 2, 3) -> SIZE()'));
    }

    @IsTest
    private static void canPipeFunctionCalls_pipeHasPrecedenceWhenPairedWithOtherExpressions() {
        Assert.areEqual(8, Evaluator.run('LIST(1, 2, 3) -> SIZE() + 5'));
    }

    @IsTest
    private static void canPipeFunctionCallsMultipleTimes() {
        Object result = Evaluator.run('[1, 2, 3, 4, 5, 6] -> WHERE($current > 2) -> WHERE($current < 5)');
        Assert.areEqual(2, ((List<Object>) result).size());
        Assert.areEqual(3, ((List<Object>) result)[0]);
        Assert.areEqual(4, ((List<Object>) result)[1]);
    }

    @IsTest
    private static void canUseCustomFunctions() {
        CustomFunctionRepository mockRepository = new MockFunctionRepository();
        CustomFunctionRepository.mockInstance = mockRepository;

        // This custom function concatenates the arguments.
        Object result = Evaluator.run('CUSTOMFUNCION("TestFormula", 1, 2)');
        Assert.areEqual('TestFormula12', result);
    }

    private class MockFunctionRepository extends CustomFunctionRepository {
        public override IExpressionFunction getByName(String functionName) {
            return new MockFunction();
        }
    }

    private class MockFunction implements IExpressionFunction {
        public Object execute(List<Object> args) {
            String concatenated = '';
            for (Object arg : args) {
                concatenated += String.valueOf(arg);
            }
            return concatenated;
        }
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_hoursDifference() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:00:00"), TIMEVALUE("02:00:00"))';
        Assert.areEqual('01:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_minutesDifference() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:30:00"), TIMEVALUE("02:00:00"))';
        Assert.areEqual('00:30:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_secondsDifference() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:30:00"), TIMEVALUE("01:30:45"))';
        Assert.areEqual('00:00:45', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_multipleDifferences() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:45:00"), TIMEVALUE("09:00:01"))';
        Assert.areEqual('07:15:01', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_firstTimeGreaterThanSecond() {
        String formula = 'FORMATDURATION(TIMEVALUE("02:00:00"), TIMEVALUE("01:00:00"))';
        Assert.areEqual('01:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_daysDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 00:00:00"), DATETIMEVALUE("2015-01-02 00:00:00"))';
        Assert.areEqual('24:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_hoursDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:00:00"), DATETIMEVALUE("2015-01-01 02:00:00"))';
        Assert.areEqual('01:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_minutesDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:30:00"), DATETIMEVALUE("2015-01-01 02:00:00"))';
        Assert.areEqual('00:30:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_secondsDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:30:00"), DATETIMEVALUE("2015-01-01 01:30:45"))';
        Assert.areEqual('00:00:45', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_multipleDifferences() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:45:00"), DATETIMEVALUE("2015-01-01 09:00:01"))';
        Assert.areEqual('07:15:01', Evaluator.run(formula));
    }

    @IsTest
    private static void monthReturnsANumberBetween1And12ForTheSpecifiedDate() {
        Assert.areEqual(1, Evaluator.run('MONTH(DATE(2015, 1, 1))'));
        Assert.areEqual(12, Evaluator.run('MONTH(DATE(2015, 12, 1))'));
    }

    @IsTest
    private static void modFunctionReturnsTheRemainderOfTheDivision() {
        Assert.areEqual(1, Evaluator.run('MOD(5, 2)'));
    }

    @IsTest
    private static void canEvaluateCustomLabels() {
        LabelWrapper.mockLabel = new DummyLabel();
        String formula = '$Label.c.MyLabelName';
        Assert.areEqual('Value', Evaluator.run(formula));
    }

    private class DummyLabel implements LabelWrapper.ILabel {
        public String get(String namespace, String label, String language) {
            return 'Value';
        }
    }

    @IsTest
    private static void canAccessMapKeysUsingDotNotation() {
        String formula = 'MAP([{"keyName": "A"}, {"keyName": "B"}], $current.keyName)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(2, ((List<Object>) result).size());
        Assert.areEqual('A', ((List<Object>) result)[0]);
        Assert.areEqual('B', ((List<Object>) result)[1]);
    }

    @IsTest
    private static void transformFunctionCanConvertFromOneObjectToAnyOther() {
        String formula = 'TRANSFORM("a", UPPER($source))';
        Object result = Evaluator.run(formula);
        Assert.areEqual('A', result);
    }

    @IsTest
    private static void dateTimeFormatFormatsADateTimeToTheSpecifiedStringFormat() {
        String formula = 'DATETIMEFORMAT(DATETIMEVALUE("2015-01-01 01:00:00"), "yyyy-MM-dd HH:mm:ss")';
        Object result = Evaluator.run(formula);
        Assert.areEqual('2015-01-01 01:00:00', result);
    }

    @IsTest
    private static void dateToDateTimeConvertsADateToADateTime() {
        String formula = 'DATETODATETIME(DATEVALUE("2015-01-01"))';
        Object result = Evaluator.run(formula);
        Assert.areEqual(Datetime.newInstance(2015, 1, 1, 0, 0, 0), result);
    }

    @IsTest
    private static void letFunctionAllowsForVariablesToBeDefined() {
        String formula = 'LET({"$a": 1, "$b": 2},  $a + $b)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(3, result);
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenPassingArgumentToSObjectGetExpr() {
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        try {
            Evaluator.run('FETCH("Account", []) -> FIRST().Name("Test")',
                testRecord.Id);
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenPassingArgumentToMapGetExpr() {
        try {
            Evaluator.run('{"Name": "Test"}.Name("Test")');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenGettingFieldThatDoesNotExist() {
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        try {
            Evaluator.run('FETCH("Account", []) -> FIRST().NonExistentField',
                testRecord.Id);
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenGettingKeyThatDoesNotExist() {
        try {
            Evaluator.run('{"Name": "Test"}.NonExistentKey');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenBubblingErrorsFromGlobalVariableResolvers() {
        try {
            Evaluator.run('$Action.Apex.NonExistentClass');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenUsingGetExpressionInAnInvalidWay() {
        try {
            Evaluator.run('$DoesNotExist.DoSomething');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void commentsAreIgnored() {
        Assert.areEqual(1, Evaluator.run('1 # comment'));
    }

    @IsTest
    private static void daysBetweenReturnsTheNumberOfDaysBetweenTwoDates() {
        String formula = 'DAYSBETWEEN(DATEVALUE("2020-01-01"), DATEVALUE("2020-01-02"))';
        Object result = Evaluator.run(formula);
        Assert.areEqual(1, result);
    }

    @IsTest
    private static void daysBetweenReturnsTheNumberOfDaysBetweenTwoDates_higherDateAsFirstArgument_resultsInNegative() {
        String formula = 'DAYSBETWEEN(DATEVALUE("2020-01-02"), DATEVALUE("2020-01-01"))';
        Object result = Evaluator.run(formula);
        Assert.areEqual(-1, result);
    }

    @IsTest
    private static void canReferenceCustomMetadataTypeRecords() {
        String formula = '$CustomMetadata.MyCustomMetadataType__mdt.MyRecord.MyField__c';
        try {
            Evaluator.run(formula);

            // Expecting an exception since the only way to test against a CMT
            // is having a record of that type in the org.
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canReferenceStaticResources() {
        String formula = '$Resource.MyStaticResource';
        try {
            Evaluator.run(formula);

            // Expecting an exception since that static resource
            // doesn't exist.
            // This test is essentially for coverage.
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canInvokeCustomFunctions() {
        QRunner.mockRunner = new FakeExpressionFunctionRunner();
        String formula = 'CUSTOMFUNCTION()';
        Object result = Evaluator.run(formula);
        Assert.areEqual('Test', result);
    }

    private class FakeExpressionFunctionRunner extends QRunner {
        public override List<SObject> run(Q query) {
            return new List<Expression_Function__mdt>{
                new Expression_Function__mdt(
                    Apex_Class__c = EvaluatorTest.FakeFunction.class.getName()
                )
            };
        }
    }

    public class FakeFunction implements IExpressionFunction {
        public Object execute(List<Object> args) {
            return 'Test';
        }
    }

    @IsTest
    private static void throwsExceptionIfThereAreMoreTokensAfterTheEndOfACompleteExpression() {
        try {
            Evaluator.run('1 + 1 1');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.ParsingException.class);
        }
    }
}
