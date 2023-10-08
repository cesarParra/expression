/**
 * Created by cesar on 10/2/2023.
 */

public with sharing class PlaygroundController {
    @AuraEnabled(Cacheable=true)
    public static List<String> getFunctions() {
        // TODO: Also add custom functions configured through CMTs
        return new List<String>(
            ExpressionFunction.FUNCTIONS.keySet()
        );
    }

    @AuraEnabled
    public static Result validate(String expr) {
        Result toReturn = new Result();
        try {
            toReturn.result = Evaluator.run(expr);
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
