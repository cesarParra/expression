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
    public static void execute(Map<String, Object> fnReference) {
        try {
            String className = (String)fnReference.get('class');
            Type t = Type.forName(className);
            IExpressionFunction f = (IExpressionFunction) t.newInstance();
            f.execute((List<Object>)fnReference.get('args'));
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}
