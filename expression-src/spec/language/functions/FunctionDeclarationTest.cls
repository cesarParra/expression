@IsTest
private class FunctionDeclarationTest {
    @IsTest
    static void onlyOneMainExpressionIsAllowed() {
        String expression = 'fun foo() => 5 + 3;\n' +
            '\n' +
            'foo()\n' +
            'foo()';

        try {
            Evaluator.run(expression);
            Assert.fail('Expected an error');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('one main expression is allowed'), e.getMessage());
        }
    }

    @IsTest
    static void functionsCanBeDeclared() {
        String expression = 'fun foo() => 5 + 3;\n' +
            '\n' +
            'foo()';

        Object result = Evaluator.run(expression);

        System.assertEquals(8, result);
    }

    @IsTest
    static void functionsCanReceiveArguments() {
        String expression = 'fun foo(a, b) => a + b;\n' +
            '\n' +
            'foo(5, 3)';

        Object result = Evaluator.run(expression);

        System.assertEquals(8, result);
    }

    @IsTest
    static void functionsCanCallOtherFunctions() {
        String expression = 'fun foo() => 5 + 3;\n' +
            'fun bar() => foo() + 2;\n' +
            '\n' +
            'bar()';

        Object result = Evaluator.run(expression);

        System.assertEquals(10, result);
    }

    @IsTest
    static void functionsCanBeCalledRecursively() {
        String expression = '' +
            'fun factorial(n) =>\n' +
            '    IF(\n' +
            '        n = 0 || n = 1,\n' +
            '        1,\n' +
            '        n * factorial(n - 1)\n' +
            '    );\n' +
            '\n' +
            'factorial(5)';

        Object result = Evaluator.run(expression);

        System.assertEquals(120, result);
    }

    @IsTest
    static void functionsCannotBeDeclaredWithinAnotherExpression() {
        String expression = 'IF(fun foo() => 5;, 1, 2)';

        try {
            Evaluator.run(expression);
            Assert.fail('Expected an error');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('declarations can only be declared at the top level of an expression'), e.getMessage());
        }
    }

    @IsTest
    static void functionsCanBePassedAsArguments() {
        String expression = 'fun foo(a, b) => a + b;\n' +
            'fun bar(fn, a, b) => fn(a, b);\n' +
            '\n' +
            'bar(foo, 5, 3)';

        Object result = Evaluator.run(expression);

        System.assertEquals(8, result);
    }

    @IsTest
    static void canPassRecordContextFromTheOuterScope() {
        Account record = new Account(Name = 'Alice');
        insert record;

        String expression = '' +
            'fun greet(n) => "Hello, " + n + "!";\n' +
            '\n' +
            'greet(Name)';

        Object result = Evaluator.run(expression, record.Id);

        System.assertEquals('Hello, Alice!', result);
    }

    @IsTest
    static void haveAccessToRecordContextFromTheOuterScope() {
        Account record = new Account(Name = 'Alice');
        insert record;

        String expression = '' +
            'fun greet() => "Hello, " + Name + "!";\n' +
            '\n' +
            'greet()';

        Object result = Evaluator.run(expression, record.Id);

        System.assertEquals('Hello, Alice!', result);
    }

    @IsTest
    static void shadowsOuterRecordScopeVariables() {
        Account record = new Account(Name = 'Alice');
        insert record;

        String expression = '' +
            'fun greet(Name) => "Hello, " + Name + "!";\n' +
            '\n' +
            'greet("Bob")';

        Object result = Evaluator.run(expression, record.Id);

        System.assertEquals('Hello, Bob!', result);
    }

    @IsTest
    static void disallowMultipleParametersWithTheSameName() {
        String expression = 'fun foo(a, a) => a + a;';

        try {
            Evaluator.run(expression);
            Assert.fail('Expected an error');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('is already defined'), e.getMessage());
        }
    }

    @IsTest
    static void functionsCanBeAnonymous() {
        String expression = 'fun foo(f) => f();\n' +
            '\n' +
            'foo(() => (5 + 5))';

        Object result = Evaluator.run(expression);

        Assert.areEqual(10, result);
    }

    @IsTest
    static void functionsAreCachedWhenTheyAreCalledWithTheSameEnvironment() {
        insert new Account(Name = 'ACME');

        Test.startTest();
        String expression = 'fun foo(n) => Query(Account(where: Name = n));\n' +
            '\n' +
            '[...foo("ACME"), ...foo("ACME")]';
        Test.stopTest();

        Evaluator.run(expression);

        Assert.areEqual(1, Limits.getQueries(), 'Only one query should have been consumed, ' +
            'since the function was called with the same argument');
    }

    @IsTest
    static void functionsAreNotCachedWhenTheyAreCalledWithDifferentEnvironments() {
        insert new Account(Name = 'ACME');

        Test.startTest();
        String expression = 'fun foo(n) => Query(Account(where: Name = n));\n' +
            '\n' +
            '[...foo("ACME"), ...foo("Salesforce")]';
        Test.stopTest();

        Evaluator.run(expression);

        Assert.areEqual(2, Limits.getQueries(), 'Two queries should have been consumed, ' +
            'since the function was called with different arguments');
    }

    @IsTest
    static void functionsAreNotCachedWhenTheNoCacheKeywordIsUsed() {
        insert new Account(Name = 'ACME');

        Test.startTest();
        String expression = 'fun nocache foo(n) => Query(Account(where: Name = n));\n' +
            '\n' +
            '[...foo("ACME"), ...foo("ACME")]';
        Test.stopTest();

        Evaluator.run(expression, new Configuration().disableStandardFunctionResultCaching());

        Assert.areEqual(2, Limits.getQueries(), 'Two queries should have been consumed, ' +
            'since the function was called with the "nocache" keyword');
    }

    @IsTest
    static void canRunEvaluatorMultipleTimesWhenUsingFunctions() {
        insert new Account(Name = 'ACME');

        String expression = 'fun foo(n) => Query(Account(where: Name = n));\n' +
            '\n' +
            '[...foo("ACME"), ...foo("Salesforce")]';

        try {
            Evaluator.run(expression);
            Evaluator.run(expression);
        } catch (Exception e) {
            Assert.fail('Should be able to run the evaluator multiple times: ' + e.getMessage());
        }
    }

    @IsTest
    static void canUseGlobalVariablesWhenRunningEvaluatorMultipleTimes() {
        insert new Account(Name = 'ACME');

        String expression = '$User.name';

        try {
            Evaluator.run(expression);
            Evaluator.run(expression);
        } catch (Exception e) {
            Assert.fail('Should be able to run the evaluator multiple times: ' + e.getMessage());
        }
    }
}
