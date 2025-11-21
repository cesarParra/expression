@IsTest
private class ExprEqualityTest {
    @IsTest
    static void localExpressionsCanBeComparedForEquality() {
        // TODO
    }

    @IsTest
    static void binaryExpressionsCanBeComparedForEquality() {
        // TODO
    }

    @IsTest
    static void groupingExpressionsCanBeComparedForEquality() {
        // TODO
    }

    @IsTest
    static void functionCallExpressionsCanBeComparedForEquality() {
        // TODO
    }

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
}
