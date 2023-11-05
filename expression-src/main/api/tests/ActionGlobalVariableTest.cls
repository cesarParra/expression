@IsTest
private class ActionGlobalVariableTest {
    @IsTest
    private static void canReferenceExecutableApex() {
        String formula = '$Action.Apex.FakeApexAction';
        Object result = Evaluator.run(formula);

        // Expect a map with a key of "class" containing the class name
        Assert.areEqual('FakeApexAction', ((Map<String, Object>) result).get('class'));
    }

    @IsTest
    private static void canPassArgumentsToApexActions() {
        String formula = '$Action.Apex.FakeApexAction("a", "b")';
        Object result = Evaluator.run(formula);

        // Expect a map with a key of "class" containing the class name
        Map<String, Object> castResult = (Map<String, Object>) result;
        Assert.areEqual('FakeApexAction', castResult.get('class'));

        Assert.areEqual(2, ((List<Object>) castResult.get('args')).size());
        Assert.areEqual('a', ((List<Object>) castResult.get('args'))[0]);
        Assert.areEqual('b', ((List<Object>) castResult.get('args'))[1]);
    }

    @IsTest
    private static void canReferenceExecutableLwcActions_namedPage() {
        String formula = '$Action.LWC.GoToNamedPage({"name": "pageName"})';
        Object result = Evaluator.run(formula);

        // Expect a map with keys: type, name, args
        Map<String, Object> castResult = (Map<String, Object>) result;
        Assert.areEqual('navigate__namedPage', castResult.get('type'));
        Assert.areEqual('pageName', castResult.get('name'));
        Assert.isTrue(((Map<Object, Object>) castResult.get('args')).isEmpty());
    }

    @IsTest
    private static void referencingAUnknownClassNameThrowsAnException() {
        String formula = '$Action.Apex.WhateverNameHere';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void referencingAFlowActionThrowsAnException() {
        String formula = '$Action.Flow.FlowName';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void referencingAnUnknownActionThrowsAnException() {
        String formula = '$Action.Unknown.ActionName';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }
}