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

    // Functions can be declared
    // Functions can receive arguments
    // Functions can call other functions
    // Functions can be recursive
    // Inner expressions cannot have function declarations
}
