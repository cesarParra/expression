public with sharing class FormulaEvaluator {
    public static Object evaluate(String formula) {
        List<Token> tokens = new Scanner(formula).scanTokens();
        for (Token token : tokens) {
            System.debug(token);
        }
        return null;
    }
}
