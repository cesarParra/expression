/**
 * @description Ui controller to evaluate formula expressions.
 */
public with sharing class FormulaEvaluatorUiController {
    @AuraEnabled(Cacheable=true)
    public static Object evaluate(Id recordId, String formula) {
        try {
            return Evaluator.run(formula, recordId);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}
