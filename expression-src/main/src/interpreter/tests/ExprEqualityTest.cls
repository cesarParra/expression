@IsTest
private class ExprEqualityTest {
    @IsTest
    static void logicalExpressionsCanBeComparedForEquality_equals() {
        Expr left = new Expr.Literal(true);
        Token operator = new Token(TokenType.AMPERSAND, 'AND', null, null);
        Expr right = new Expr.Literal(false);

        Expr.Logical aLogical = new Expr.Logical(left, operator, right);
        Expr.Logical anotherLogical = new Expr.Logical(left, operator, right);

        Assert.isTrue(aLogical == anotherLogical);
    }

    @IsTest
    static void logicalExpressionsCanBeComparedForEquality_notEquals() {
        Expr left = new Expr.Literal(true);
        Token operator = new Token(TokenType.AMPERSAND, 'AND', null, null);
        Expr right = new Expr.Literal(false);

        Expr.Logical aLogical = new Expr.Logical(left, operator, right);
        Expr.Logical anotherLogical = new Expr.Logical(left, operator, new Expr.Literal(true));

        Assert.isFalse(aLogical == anotherLogical);
    }

    @IsTest
    static void binaryExpressionsCanBeComparedForEquality() {
        // TODO
    }

    // TODO: Not equals

    @IsTest
    static void groupingExpressionsCanBeComparedForEquality() {
        // TODO
    }

    // TODO: Not equals

    @IsTest
    static void functionCallExpressionsCanBeComparedForEquality() {
        // TODO
    }

    // TODO: Not equals

    @IsTest
    static void literalExpressionsCanBeComparedForEquality_equals() {
        Expr.Literal aLiteral = new Expr.Literal(42);
        Expr.Literal anotherLiteral = new Expr.Literal(42);
        Assert.isTrue(aLiteral == anotherLiteral);
    }

    @IsTest
    static void literalExpressionsCanBeComparedForEquality_notEquals() {
        Expr.Literal aLiteral = new Expr.Literal(42);
        Expr.Literal anotherLiteral = new Expr.Literal(43);
        Assert.isFalse(aLiteral == anotherLiteral);
    }

    @IsTest
    static void stringLiteralsCanBeComparedForEquality_equals() {
        Expr.StringLiteral aLiteral = new Expr.StringLiteral(new List<Object> { 'h', 'e', 'l', 'l', 'o' });
        Expr.StringLiteral anotherLiteral = new Expr.StringLiteral(new List<Object> { 'h', 'e', 'l', 'l', 'o' });
        Assert.isTrue(aLiteral == anotherLiteral);
    }

    @IsTest
    static void stringLiteralsCanBeComparedForEquality_notEquals() {
        Expr.StringLiteral aLiteral = new Expr.StringLiteral(new List<Object> { 'h', 'e', 'l', 'l', 'o' });
        Expr.StringLiteral anotherLiteral = new Expr.StringLiteral(new List<Object> { 'w', 'o', 'r', 'l', 'd' });
        Assert.isFalse(aLiteral == anotherLiteral);
    }

    @IsTest
    static void variableExpressionsCanBeComparedForEquality_equals() {
        Expr.Variable aVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var1', null, null),
            Expr.VariableType.LOCAL
        );

        Expr.Variable anotherVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var1', null, null),
            Expr.VariableType.LOCAL
        );

        Assert.isTrue(aVariable == anotherVariable);
    }

    @IsTest
    static void variableExpressionsCanBeComparedForEquality_notEquals() {
        Expr.Variable aVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var1', null, null),
            Expr.VariableType.LOCAL
        );

        Expr.Variable anotherVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var2', null, null),
            Expr.VariableType.LOCAL
        );

        Assert.isFalse(aVariable == anotherVariable);
    }

    @IsTest
    static void mergeFieldOrScopeVariableExpressionsCanBeComparedForEquality_equals() {
        Expr.MergeFieldOrScopeVariable aMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field1', null, null)
        );

        Expr.MergeFieldOrScopeVariable anotherMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field1', null, null)
        );

        Assert.isTrue(aMergeField == anotherMergeField);
    }

    @IsTest
    static void mergeFieldOrScopeVariableExpressionsCanBeComparedForEquality_notEquals() {
        Expr.MergeFieldOrScopeVariable aMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field1', null, null)
        );

        Expr.MergeFieldOrScopeVariable anotherMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field2', null, null)
        );

        Assert.isFalse(aMergeField == anotherMergeField);
    }

    @IsTest
    static void getExpressionsCanBeComparedForEquality() {
        // TODO
    }

    // TODO: Unary expressions
    // TODO: List Literal expressions
    // TODO: Map literal expressions
    // TODO: Spread expressions
    // TODO: AddIfExpressions
    // TODO: QueryExpressions
}
