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
    
    // Functions can call other functions
    // Functions can be recursive
    // Inner expressions cannot have function declarations
}
