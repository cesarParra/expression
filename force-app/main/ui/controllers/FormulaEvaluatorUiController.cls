/**
 * @description Ui controller to evaluate formula expressions.
 */
public with sharing class FormulaEvaluatorUiController {
    @AuraEnabled(Cacheable=true)
    public static Object evaluate(Id recordId, String formula) {
        try {
            return FormulaEvaluator.evaluate(formula, recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
