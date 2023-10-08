public with sharing class PlaygroundController {
    @AuraEnabled(Cacheable=true)
    public static List<String> getFunctions() {
        Set<String> builtInFunctionNames = ExpressionFunction.FUNCTIONS.keySet();
        Set<String> customFunctionNames = Expression_Function__mdt.getAll().keySet();
        Set<String> functionNames = new Set<String>();
        functionNames.addAll(builtInFunctionNames);
        functionNames.addAll(customFunctionNames);
        return new List<String>(
            functionNames
        );
    }

    @AuraEnabled
    public static Result validate(String expr, Id recordId) {
        Result toReturn = new Result();
        try {
            if (recordId != null) {
                toReturn.result = Evaluator.run(expr, recordId);
            } else {
                toReturn.result = Evaluator.run(expr);
            }
        } catch (Exception e) {
            toReturn.error = e.getMessage();
        }

        return toReturn;
    }

    public class Result {
        @AuraEnabled
        public String error;

        @AuraEnabled
        public Object result;
    }
}
