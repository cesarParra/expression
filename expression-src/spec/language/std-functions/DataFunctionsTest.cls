@IsTest
private class DataFunctionsTest {
    @IsTest
    private static void transformFunctionCanConvertFromOneObjectToAnyOther() {
        String formula = 'TRANSFORM("a", UPPER($source))';
        Object result = Evaluator.run(formula);
        Assert.areEqual('A', result);
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
        
        acc = [SELECT Id, Description FROM Account WHERE Id = :acc.Id LIMIT 1];
        
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
        
        acc = [SELECT Id, Description FROM Account WHERE Id = :acc.Id LIMIT 1];
        
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
        
        acc = [SELECT Id, Description FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        String formula = 'PARSEJSON(Description)';
        Object result = Evaluator.run(formula, acc.Id);
        
        Map<Object, Object> resultMap = (Map<Object, Object>) result;
        List<Object> skills = (List<Object>) resultMap.get('skills');
        Assert.areEqual('Apex', skills[0]);
        Assert.areEqual('JavaScript', skills[1]);
        Assert.areEqual('HTML', skills[2]);
    }

}