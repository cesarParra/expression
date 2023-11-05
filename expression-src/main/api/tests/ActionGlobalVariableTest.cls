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
    private static void canReferenceExecutableLwcActions_namedPage_canPassExtraArgs() {
        String formula = '$Action.LWC.GoToNamedPage({"name": "pageName", "extra": "extra"})';
        Object result = Evaluator.run(formula);

        Map<String, Object> castResult = (Map<String, Object>) result;
        Assert.isFalse(((Map<Object, Object>) castResult.get('args')).isEmpty());
        Assert.areEqual('extra', ((Map<Object, Object>) castResult.get('args')).get('extra'));
    }

    @IsTest
    private static void canReferenceExecutableLwcActions_throwsExceptionWhenNoNameIsProvided() {
        String formula = '$Action.LWC.GoToNamedPage({"noname": "pageName"})';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canReferenceExecutableLwcActions_url() {
        String formula = '$Action.LWC.GoToUrl({"name": "https://www.salesforce.com"})';
        Object result = Evaluator.run(formula);

        // Expect a map with keys: type, name, args
        Map<String, Object> castResult = (Map<String, Object>) result;
        Assert.areEqual('navigate__url', castResult.get('type'));
        Assert.areEqual('https://www.salesforce.com', castResult.get('name'));
        Assert.isTrue(((Map<Object, Object>) castResult.get('args')).isEmpty());
    }

    @IsTest
    private static void canReferenceExecutableLwcActions_reload() {
        String formula = '$Action.LWC.Reload';
        Object result = Evaluator.run(formula);

        // Expect a map with keys: type, name, args
        Map<String, Object> castResult = (Map<String, Object>) result;
        Assert.areEqual('reload', castResult.get('type'));
    }

    @IsTest
    private static void canReferenceExecutableLwcActions_refresh() {
        String formula = '$Action.LWC.Refresh';
        Object result = Evaluator.run(formula);

        // Expect a map with keys: type, name, args
        Map<String, Object> castResult = (Map<String, Object>) result;
        Assert.areEqual('refresh', castResult.get('type'));
    }

    @IsTest
    private static void referencingAnUnknownClassNameThrowsAnException() {
        String formula = '$Action.Apex.WhateverNameHere';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void referencingAnInvalidClassNameThrowsAnException() {
        String formula = '$Action.Apex.Interpreter';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void referencingAnInvalidLwcActonThrowsAnException() {
        String formula = '$Action.LWC.Whatever';
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