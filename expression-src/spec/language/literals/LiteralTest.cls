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
    private static void canBuildListLiterals() {
        Assert.areEqual(3, Evaluator.run('SIZE([1, 2, 3])'));
    }

    @IsTest
    private static void falseLiteralsAreCaseInsensitive() {
        Assert.areEqual(false, Evaluator.run('FALSE'));
    }

    @IsTest
    private static void supportsNullLiterals() {
        Assert.areEqual(null, Evaluator.run('null'));
    }

    @IsTest
    private static void mapLiteralCreatesAMap() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{"a": 1, "b": 2}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }
}
