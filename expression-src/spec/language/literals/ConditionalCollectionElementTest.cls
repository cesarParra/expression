@IsTest
private class ConditionalCollectionElementTest {
    // Lists

    @IsTest
    static void canConditionallyAddAnElementToAList() {
        String expr = '[1, addif(true) 2]';

        List<Object> result = (List<Object>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(1, result.get(0));
        Assert.areEqual(2, result.get(1));
    }

    @IsTest
    static void canConditionallySkipAddingAnElementToAList() {
        String expr = '[1, addif(false) 2]';

        List<Object> result = (List<Object>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result.get(0));
    }

    @IsTest
    static void cannotAddAKeyValuePairToAList() {
        String expr = '[1, addif(true) "a": 2]';

        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('a "colon" was not expected'));
        }
    }

    // Maps

    @IsTest
    static void canConditionallyAddAKeyValuePairToAMap() {
        String expr = '{"a": 1, addif(true) "b": 2}';

        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }

    @IsTest
    static void canConditionallySkipAddingAKeyValuePairToAMap() {
        String expr = '{"a": 1, addif(false) "b": 2}';

        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result.get('a'));
    }

    @IsTest
    static void cannotAddAnElementToAMap() {
        String expr = '{"a": 1, addif(true) 2}';

        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('a "colon" was expected'));
        }
    }
}
