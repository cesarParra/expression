/**
 * @description Evaluates a formula and returns the result.
 */
global with sharing class Evaluator {
    global static Boolean printAst = false;

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @return The result of the formula.
     */
    global static Object run(String formula) {
        return run(formula, (SObject)null);
    }

    /**
     * @param formula Evaluates a formula and returns the result.
     * @param context An SObject that will act as the context for the formula.
     *        Providing this allows you to reference fields on the SObject in
     *        the formula.
     * @return The result of the formula.
     */
    global static Object run(String formula, SObject context) {
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        if (printAst) {
            AstPrinter printer = new AstPrinter();
            printer.printAst(expression);
        }

        Environment env = new Environment(context);
        Interpreter interpreter = new Interpreter(env);
        return interpreter.interpret(expression);
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param formula The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @return The result of the formula.
     */
    global static Object run(String formula, Id recordId) {
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        if (printAst) {
            AstPrinter printer = new AstPrinter();
            printer.printAst(expression);
        }

        ContextResolver2 ctxInterpreter = new ContextResolver2(recordId);
        SObject record = ctxInterpreter.build(expression);

        Environment env = new Environment(record);
        Interpreter interpreter = new Interpreter(env);
        return interpreter.interpret(expression);
    }
}
