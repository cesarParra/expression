@IsTest
private class DataFunctionsTest {
    @IsTest
    private static void transformFunctionCanConvertFromOneObjectToAnyOther() {
        String formula = 'TRANSFORM("a", UPPER($source))';
        Object result = Evaluator.run(formula);
        Assert.areEqual('A', result);
    }

    @IsTest
    private static void transformCanAccessTheParentEnvironment() {
        Account someRecord = new Account(Name = 'Test Account');

        String formula = '"Test Account" -> TRANSFORM($source = Name)';
        Object result = Evaluator.run(formula, someRecord);

        Assert.isTrue((Boolean) result, 'The transform function should return true when the source matches the expected value.');
    }

    @IsTest
    private static void letFunctionAllowsForVariablesToBeDefined() {
        String formula = 'LET({"$a": 1, "$b": 2},  $a + $b)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(3, result);
    }

    @IsTest
    private static void canRunARawSoqlQueryThroughTheRawQueryFunction() {
        String formula = 'RAWQUERY("SELECT Id FROM Account LIMIT 1")';
        Object result = Evaluator.run(formula);
        Assert.isNotNull(result);
    }

    @IsTest
    private static void parseJsonWithAccount() {
        Account acc = new Account(
            Name = 'Test Account',
            Description = '{"name":"John","age":30}'
        );
        insert acc;

        String formula = 'PARSEJSON(Description)';
        Object result = Evaluator.run(formula, acc.Id);

        Map<Object, Object> resultMap = (Map<Object, Object>) result;
        Assert.areEqual('John', resultMap.get('name'));
        Assert.areEqual(30, resultMap.get('age'));
    }

    @IsTest
    private static void parseJsonWithNestedObject() {
        Account acc = new Account(
            Name = 'Test Account',
            Description = '{"name":"John","age":30,"address":{"city":"New York","zip":10001}}'
        );
        insert acc;

        String formula = 'PARSEJSON(Description)';
        Object result = Evaluator.run(formula, acc.Id);

        Map<Object, Object> resultMap = (Map<Object, Object>) result;
        Map<Object, Object> address = (Map<Object, Object>) resultMap.get('address');
        Assert.areEqual('New York', address.get('city'));
        Assert.areEqual(10001, address.get('zip'));
    }

    @IsTest
    private static void parseJsonWithList() {
        Account acc = new Account(
            Name = 'Test Account',
            Description = '{"name":"John","age":30,"skills":["Apex","JavaScript","HTML"]}'
        );
        insert acc;

        String formula = 'PARSEJSON(Description)';
        Object result = Evaluator.run(formula, acc.Id);

        Map<Object, Object> resultMap = (Map<Object, Object>) result;
        List<Object> skills = (List<Object>) resultMap.get('skills');
        Assert.areEqual('Apex', skills[0]);
        Assert.areEqual('JavaScript', skills[1]);
        Assert.areEqual('HTML', skills[2]);
    }

    @IsTest
    private static void toJsonSerializesAList() {
        String formula = 'TOJSON([1, "two", true])';
        Object result = Evaluator.run(formula);
        Assert.areEqual('[1,"two",true]', result);
    }

    @IsTest
    private static void toJsonSerializesAListOfListsBuiltByMap() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'First', NumberOfEmployees = 1),
            new Account(Name = 'Second', NumberOfEmployees = 2)
        };
        insert accounts;

        String formula = 'QUERY(Account(orderBy: Name)[Name, NumberOfEmployees]) -> MAP([Name, NumberOfEmployees]) -> TOJSON()';
        Object result = Evaluator.run(formula);

        Assert.areEqual('[["First",1],["Second",2]]', result);
    }

    @IsTest
    private static void toJsonSerializesAnEmptyList() {
        String formula = '[] -> TOJSON()';
        Object result = Evaluator.run(formula);
        Assert.areEqual('[]', result);
    }

    @IsTest
    private static void toJsonRoundTripsThroughParseJson() {
        String formula = 'GET(PARSEJSON(TOJSON({"name": "John"})), "name")';
        Object result = Evaluator.run(formula);
        Assert.areEqual('John', result);
    }

    @IsTest
    private static void displayFormatsACurrencyFieldWithItsSymbolAndScale() {
        System.runAs(usUser()) {
            Object result = Evaluator.run('DISPLAY(Amount)', new Opportunity(Amount = 1234.5));
            Assert.areEqual('$1,234.50', result);
        }
    }

    @IsTest
    private static void displayFormatsAPercentFieldWithItsSign() {
        System.runAs(usUser()) {
            Object result = Evaluator.run('DISPLAY(Probability)', new Opportunity(Probability = 30));
            Assert.areEqual('30%', result);
        }
    }

    @IsTest
    private static void displayFormatsADateFieldInTheUsersLocale() {
        System.runAs(usUser()) {
            Date closeDate = Date.newInstance(2027, 3, 17);
            Object result = Evaluator.run('DISPLAY(CloseDate)', new Opportunity(CloseDate = closeDate));
            Assert.areEqual(closeDate.format(), result);
        }
    }

    @IsTest
    private static void displayFormatsADatetimeFieldInTheUsersTimeZone() {
        System.runAs(usUser()) {
            Datetime startsAt = Datetime.newInstanceGmt(2027, 3, 17, 0, 0, 0);
            Object result = Evaluator.run('DISPLAY(ActivityDateTime)', new Event(ActivityDateTime = startsAt));
            Assert.areEqual(startsAt.format(), result);
            Assert.isTrue(((String) result).startsWith('3/16/2027'), 'Expected the Los Angeles date, got: ' + result);
        }
    }

    @IsTest
    private static void displayFormatsAFieldReachedThroughARelationship() {
        System.runAs(usUser()) {
            Opportunity record = new Opportunity(Account = new Account(AnnualRevenue = 5000));
            Object result = Evaluator.run('DISPLAY(Account.AnnualRevenue)', record);
            Assert.areEqual('$5,000', result);
        }
    }

    @IsTest
    private static void displayReturnsAValueThatIsNotAFieldUnchanged() {
        Assert.areEqual(141.4, Evaluator.run('DISPLAY(141.4)'));
    }

    @IsTest
    private static void displayReturnsNullForABlankField() {
        Assert.isNull(Evaluator.run('DISPLAY(Amount)', new Opportunity()));
    }

    @IsTest
    private static void displayFormatsChildRecordFieldsQueriedByRecordId() {
        Account parent = new Account(Name = 'Acme');
        insert parent;
        insert new Opportunity(AccountId = parent.Id, Name = 'Deal', StageName = 'Prospecting',
            CloseDate = Date.today(), Amount = 0.3);

        Object result = Evaluator.run('Opportunities -> MAP(DISPLAY(Amount))', parent.Id);

        Assert.areEqual(new List<Object>{ '$0.30' }, result);
    }

    private static User usUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        return new User(Alias = 'display', Email = 'display@testorg.com',
            EmailEncodingKey = 'UTF-8', FirstName = 'Dee', LastName = 'Display',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'display' + Datetime.now().getTime() + '@testorg.com');
    }
}
