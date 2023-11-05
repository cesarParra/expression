@IsTest
private class AstPrinterTest {
    static void buildsCorrectExpression(String expressionFormula, String expectedType) {
        EvaluationResult result = EvaluatorResolver.withoutContext().evaluate(expressionFormula,
            new Configuration().printAst());
        Object ast = result.additionalData.get('ast');

        Assert.isNotNull(ast, 'AST should not be null');
        Map<String, Object> astObject = (Map<String, Object>)ast;

        Assert.isTrue(astObject.containsKey('type'));
        Assert.areEqual(expectedType, astObject.get('type'));
        Assert.isTrue(astObject.containsKey('body'));
    }

    @IsTest
    static void buildsBinaryExpressions() {
        String expressionFormula = '1 + 1';
        buildsCorrectExpression(expressionFormula, 'Binary');
    }

    @IsTest
    static void buildsGroupingExpressions() {
        String expressionFormula = '(1 + 1)';
        buildsCorrectExpression(expressionFormula, 'Grouping');
    }

    @IsTest
    static void buildsLiteralExpressions() {
        String expressionFormula = '1';
        buildsCorrectExpression(expressionFormula, 'Literal');
    }

    @IsTest
    static void buildsStringLiteralExpressions() {
        String expressionFormula = '"Hello"';
        buildsCorrectExpression(expressionFormula, 'StringLiteral');
    }

    @IsTest
    static void buildsVariableExpressions() {
        String expressionFormula = '$User';
        buildsCorrectExpression(expressionFormula, 'Variable');
    }

    @IsTest
    static void buildsMergeFieldExpressions() {
        String expressionFormula = 'Name';
        Account recordContext = new Account(Name = 'Test');
        EvaluationResult result = EvaluatorResolver.forRecord(recordContext).evaluate(expressionFormula,
            new Configuration().printAst());
        Object ast = result.additionalData.get('ast');

        Assert.isNotNull(ast, 'AST should not be null');
        Map<String, Object> astObject = (Map<String, Object>)ast;

        Assert.isTrue(astObject.containsKey('type'));
        Assert.areEqual('MergeField', astObject.get('type'));
        Assert.isTrue(astObject.containsKey('body'));
    }

    @IsTest
    static void buildsUnaryExpressions() {
        String expressionFormula = '!true';
        buildsCorrectExpression(expressionFormula, 'Unary');
    }
}