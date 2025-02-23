@IsTest
private class AstPrinterTest {
    static void buildsAnExpressionContaining(String expressionFormula, String expectedType) {
        EvaluationResult result = EvaluatorResolver.withoutContext().evaluate(expressionFormula,
            new Configuration().printAst());
        Object ast = result.additionalData.get('ast');

        Assert.isNotNull(ast, 'AST should not be null');
        List<Object> astList = (List<Object>) ast;
        Map<String, Object> astObject = (Map<String, Object>) astList[0];

        Assert.isTrue(astObject.containsKey('type'));
        Assert.areEqual(expectedType, astObject.get('type'));
        Assert.isTrue(astObject.containsKey('body'));
    }

    @IsTest
    static void buildsBinaryExpressions() {
        String expressionFormula = '1 + 1';
        buildsAnExpressionContaining(expressionFormula, 'Binary');
    }

    @IsTest
    static void buildsGroupingExpressions() {
        String expressionFormula = '(1 + 1)';
        buildsAnExpressionContaining(expressionFormula, 'Grouping');
    }

    @IsTest
    static void buildsLiteralExpressions() {
        String expressionFormula = '1';
        buildsAnExpressionContaining(expressionFormula, 'Literal');
    }

    @IsTest
    static void buildsStringLiteralExpressions() {
        String expressionFormula = '"Hello"';
        buildsAnExpressionContaining(expressionFormula, 'StringLiteral');
    }

    @IsTest
    static void buildsVariableExpressions() {
        String expressionFormula = '$User';
        buildsAnExpressionContaining(expressionFormula, 'Variable');
    }

    @IsTest
    static void buildsMergeFieldExpressions() {
        String expressionFormula = 'Name';
        Account recordContext = new Account(Name = 'Test');
        EvaluationResult result = EvaluatorResolver.forRecord(recordContext).evaluate(expressionFormula,
            new Configuration().printAst());
        Object ast = result.additionalData.get('ast');

        Assert.isNotNull(ast, 'AST should not be null');
        List<Object> astList = (List<Object>) ast;
        Map<String, Object> astObject = (Map<String, Object>) astList[0];

        Assert.isTrue(astObject.containsKey('type'));
        Assert.areEqual('MergeField', astObject.get('type'));
        Assert.isTrue(astObject.containsKey('body'));
    }

    @IsTest
    static void buildsUnaryExpressions() {
        String expressionFormula = '!true';
        buildsAnExpressionContaining(expressionFormula, 'Unary');
    }

    @IsTest
    static void buildGetExpressions() {
        String expressionFormula = '$User.Id';
        buildsAnExpressionContaining(expressionFormula, 'Get');
    }

    @IsTest
    static void buildFunctionExpressions() {
        String expressionFormula = 'BR()';
        buildsAnExpressionContaining(expressionFormula, 'FunctionCall');
    }

    @IsTest
    static void buildListExpressions() {
        String expressionFormula = '[...[]]';
        buildsAnExpressionContaining(expressionFormula, 'ListLiteral');
    }

    @IsTest
    static void buildMapExpressions() {
        String expressionFormula = '{}';
        buildsAnExpressionContaining(expressionFormula, 'MapLiteral');
    }

    @IsTest
    static void buildQueryExpressions() {
        String expressionFormula = 'QUERY(Account)';
        buildsAnExpressionContaining(expressionFormula, 'Query');
    }
}
