@IsTest
private class ArityTest {
    @IsTest
    static void supportsBetween() {
        Arity betweenArity = Arity.between(1, 3);
        Assert.isTrue(betweenArity.isSatisfiedBy(1));
        Assert.isTrue(betweenArity.isSatisfiedBy(2));
        Assert.isTrue(betweenArity.isSatisfiedBy(3));
        Assert.isFalse(betweenArity.isSatisfiedBy(0));
        Assert.isFalse(betweenArity.isSatisfiedBy(4));
    }

    @IsTest
    static void supportsAtLeast() {
        Arity atLeastArity = Arity.atLeast(2);
        Assert.isTrue(atLeastArity.isSatisfiedBy(2));
        Assert.isTrue(atLeastArity.isSatisfiedBy(3));
        Assert.isTrue(atLeastArity.isSatisfiedBy(4));
        Assert.isFalse(atLeastArity.isSatisfiedBy(1));
    }

    @IsTest
    static void supportsExactly() {
        Arity exactlyArity = Arity.exactly(2);
        Assert.isTrue(exactlyArity.isSatisfiedBy(2));
        Assert.isFalse(exactlyArity.isSatisfiedBy(1));
        Assert.isFalse(exactlyArity.isSatisfiedBy(3));
    }
}
