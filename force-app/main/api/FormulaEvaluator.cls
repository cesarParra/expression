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
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        if (printAst) {
            AstPrinter printer = new AstPrinter();
            printer.printAst(expression);
        }

        Interpreter interpreter = new Interpreter();
        return interpreter.interpret(expression);
    }
}
