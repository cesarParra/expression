public with sharing class FormulaEvaluator {
    public static Object evaluate(String formula) {
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        Interpreter interpreter = new Interpreter();
        return interpreter.interpret(expression);
    }
}
