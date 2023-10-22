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
    public static List<Functions> getCustomFunctions() {
        List<Functions> toReturn = new List<Functions>();

        List<Expression_Function__mdt> customFunctions = Expression_Function__mdt.getAll().values();
        Functions customCategory = new Functions();
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
    public static Result validate(String expr, Id recordId) {
        Result toReturn = new Result();
        Evaluator.Config config = new Evaluator.Config();
        config.withDiagnostics = true;
        try {
            if (String.isNotBlank(recordId)) {
                toReturn.result = Evaluator.run(expr, recordId, config);
            } else {
                toReturn.result = Evaluator.run(expr, config);
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

        toReturn.diagnostics = new Diagnostics(DiagnosticsDecorator.result);

        return toReturn;
    }

    public class Result {
        @AuraEnabled
        public EvaluationError error;

        @AuraEnabled
        public Object result;

        @AuraEnabled
        public Diagnostics diagnostics;
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

        public Diagnostics(DiagnosticsDecorator.DiagnosticsResult result) {
            this.cpuTime = result?.cpuTime;
            this.dmlStatements = result?.dmlStatements;
            this.queries = result?.queries;
            this.queryRows = result?.queryRows;
        }
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
