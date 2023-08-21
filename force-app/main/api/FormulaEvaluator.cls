/**
 * @description Evaluates a formula and returns the result.
 */
public with sharing class FormulaEvaluator {
    public static Boolean printAst = false;

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @return The result of the formula.
     */
    public static Object evaluate(String formula) {
        return evaluate(formula, (SObject)null);
    }

    /**
     * @param formula Evaluates a formula and returns the result.
     * @param context An SObject that will act as the context for the formula.
     *        Providing this allows you to reference fields on the SObject in
     *        the formula.
     * @return The result of the formula.
     */
    public static Object evaluate(String formula, SObject context) {
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        if (printAst) {
            AstPrinter printer = new AstPrinter();
            printer.printAst(expression);
        }

        Interpreter interpreter = new Interpreter(context);
        return interpreter.interpret(expression);
    }

    public static Object evaluate(String formula, Id recordId) {
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        if (printAst) {
            AstPrinter printer = new AstPrinter();
            printer.printAst(expression);
        }

        ContextResolver ctxInterpreter = new ContextResolver(recordId);
        SObject record = ctxInterpreter.build(expression);

        Interpreter interpreter = new Interpreter(record);
        return interpreter.interpret(expression);
    }

    public class NotImplementedException extends Exception {}
}
