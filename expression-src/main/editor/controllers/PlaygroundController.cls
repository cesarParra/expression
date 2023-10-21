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
        } catch (Exceptions.PositionAwareException e) {
            EvaluationError error = new EvaluationError();
            error.message = e.getMessage();
            error.summary = e.message;
            error.startLineNumber = e.position.lineStart;
            error.endLineNumber = e.position.lineStart;
            error.startColumnNumber = e.position.columnStart;
            error.endColumnNumber = e.position.columnEnd;
            toReturn.error = error;
        }
        catch (Exception e) {
            EvaluationError error = new EvaluationError();
            error.summary = e.getMessage();
            error.message = e.getMessage();
            toReturn.error = error;
        }

        return toReturn;
    }

    public class Result {
        @AuraEnabled
        public EvaluationError error;

        @AuraEnabled
        public Object result;
    }

    public class EvaluationError {
        @AuraEnabled
        public String summary;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public Integer startLineNumber;

        @AuraEnabled
        public Integer endLineNumber;

        @AuraEnabled
        public Integer startColumnNumber;

        @AuraEnabled
        public Integer endColumnNumber;
    }
}
