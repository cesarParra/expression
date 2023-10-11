/**
 * @description Ui controller to evaluate formula expressions.
 */
public with sharing class FormulaEvaluatorUiController {
    @AuraEnabled(Cacheable=true)
    public static Object evaluate(String recordId, String formula) {
        try {
            if (String.isBlank(recordId)) {
                return Evaluator.run(formula);
            } else {
                return Evaluator.run(formula, recordId);
            }
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static void execute(String className) {
        try {
            Type t = Type.forName(className);
            IExpressionFunction f = (IExpressionFunction) t.newInstance();
            f.execute(new List<Object>());
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}
