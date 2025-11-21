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
}
