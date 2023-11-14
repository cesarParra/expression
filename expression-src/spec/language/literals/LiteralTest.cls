@IsTest
private class LiteralTest {
    @IsTest
    private static void supportsNumberLiterals() {
        Assert.areEqual(100, Evaluator.run('100'));
    }

    @IsTest
    private static void supportsStringLiterals() {
        Assert.areEqual('abc', Evaluator.run('"abc"'));
    }

    @IsTest
    private static void supportsDecimalNumbers() {
        Assert.areEqual(1.5, Evaluator.run('1.5'));
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
}
