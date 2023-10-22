public with sharing class PlaygroundController {
    @AuraEnabled(Cacheable=true)
    public static List<String> getFunctionNames() {
        Set<String> builtInFunctionNames = ExpressionFunction.getStandardFunctionNames();
        Set<String> customFunctionNames = Expression_Function__mdt.getAll().keySet();
        Set<String> functionNames = new Set<String>();
        functionNames.addAll(builtInFunctionNames);
        functionNames.addAll(customFunctionNames);
        return new List<String>(
            functionNames
        );
    }

    @AuraEnabled(Cacheable=true)
    public static List<Functions> getFunctions() {
        List<Functions> toReturn = new List<Functions>();
        for (FunctionProvider provider : ExpressionFunction.FUNCTION_PROVIDERS) {
            Functions forProvider = new Functions();
            forProvider.name = provider.getCategory();
            forProvider.icon = provider.getIcon();
            List<Function> functions = new List<Function>();
            for (String functionName : provider.getFunctions().keySet()) {
                ExpressionFunction fn = provider.getFunctions().get(functionName);

                Function toAdd = new Function();
                toAdd.name = functionName;
                toAdd.autoCompleteValue = functionName + '(';
                toAdd.description = fn.getDescription();
                toAdd.example = fn.getExample();
                functions.add(toAdd);
            }
            forProvider.functions = functions;
            toReturn.add(forProvider);
        }

        return toReturn;
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
            error.endLineNumber = e.position.lineEnd;
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

    public class Functions {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String icon;

        @AuraEnabled
        public List<Function> functions;
    }

    public class Function {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String autoCompleteValue;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public String example;
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
