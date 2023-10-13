/**
 * @description Ui controller to evaluate formula expressions.
 */
public with sharing class FormulaEvaluatorUiController {
    /**
     * @description Evaluates an Expression.
     * @param recordId Record Id to use for context. Optional.
     * @param formula The Expression to evaluate.
     * @param respectSharing If true, the expression will be evaluated in the
     *        context of the current user. If false, the expression will be
     *        evaluated "without sharing".
     * @return The result of the evaluation.
     */
    @AuraEnabled(Cacheable=true)
    public static Object evaluate(String recordId, String formula, Boolean respectSharing) {
        try {
            Evaluator.Config config = new Evaluator.Config();
            config.sharing = respectSharing ? Evaluator.SharingMode.WITH : Evaluator.SharingMode.WITHOUT;
            System.debug('config.sharing: ' + config.sharing);
            if (String.isBlank(recordId)) {
                return Evaluator.run(formula, config);
            } else {
                return Evaluator.run(formula, recordId, config);
            }
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    /**
     * @description Executes a function reference.
     * @param fnReference Representation of a "function" to execute. A function
     *        is map with two keys: "class" and "args". The "class" key is the
     *        name of the class to execute and must implement IExpressionFunction.
     *        The "args" key is a list of arguments to pass to the function.
     * @return The result of the function execution.
     */
    @AuraEnabled
    public static Object execute(Map<String, Object> fnReference) {
        try {
            String className = (String) fnReference.get('class');
            Type t = Type.forName(className);

            if (t == null) {
                AuraHandledException ex = new AuraHandledException('Class not found: ' + className);
                ex.setMessage('Class not found: ' + className);
                throw ex;
            }

            IExpressionFunction f = (IExpressionFunction) t.newInstance();
            List<Object> args = (List<Object>) fnReference.get('args');
            if (args == null) {
                args = new List<Object>();
            }
            return f.execute(args);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}
