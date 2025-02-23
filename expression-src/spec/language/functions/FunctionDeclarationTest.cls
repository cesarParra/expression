@IsTest
private class FunctionDeclarationTest {
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
}
