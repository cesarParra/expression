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
    public static List<FunctionCategory> getCustomFunctions() {
        List<FunctionCategory> toReturn = new List<FunctionCategory>();

        List<Expression_Function__mdt> customFunctions = Expression_Function__mdt.getAll().values();
        FunctionCategory customCategory = new FunctionCategory();
        customCategory.name = 'Custom';
        customCategory.icon = 'utility:apex_plugin';

        List<Function> functions = new List<Function>();
        for (Expression_Function__mdt customFunctionRecord : customFunctions) {
            Function customFunction = new Function();
            customFunction.name = customFunctionRecord.DeveloperName;
            customFunction.autoCompleteValue = customFunctionRecord.DeveloperName + '(';
            functions.add(customFunction);
        }
        customCategory.functions = functions;
        toReturn.add(customCategory);

        return toReturn;
    }

    @AuraEnabled
    public static Result validate(String expr, String recordId) {
        Result toReturn = new Result();
        Configuration config = new Configuration().withDiagnostics().printAst();
        try {
            EvaluationResult evalResult;
            if (String.isNotBlank(recordId)) {
                evalResult = EvaluatorResolver.forId(recordId).evaluate(expr, config);
            } else {
                evalResult = EvaluatorResolver.withoutContext().evaluate(expr, config);
            }

            toReturn.result = evalResult.result;

            if (evalResult.additionalData.containsKey('diagnostics')) {
                EvaluationDiagnosticsListener.DiagnosticsResult diagnosticsResult =
                    (EvaluationDiagnosticsListener.DiagnosticsResult)evalResult.additionalData.get('diagnostics');
                toReturn.diagnostics = new Diagnostics(diagnosticsResult);
            }

            if (evalResult.additionalData.containsKey('ast')) {
                toReturn.ast = evalResult.additionalData.get('ast');
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
        } catch (Exception e) {
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

        @AuraEnabled
        public Diagnostics diagnostics;

        @AuraEnabled
        public Object ast;
    }

    public class Diagnostics {
        @AuraEnabled
        public Integer cpuTime;

        @AuraEnabled
        public Integer dmlStatements;

        @AuraEnabled
        public Integer queries;

        @AuraEnabled
        public Integer queryRows;

        public Diagnostics(EvaluationDiagnosticsListener.DiagnosticsResult result) {
            this.cpuTime = result?.cpuTime;
            this.dmlStatements = result?.dmlStatements;
            this.queries = result?.queries;
            this.queryRows = result?.queryRows;
        }
    }

    public class FunctionCategory {
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
