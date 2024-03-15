public with sharing class UserDefinedVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        List<Variable__mdt> variables = [SELECT Value__c FROM Variable__mdt WHERE DeveloperName = :referenceName];
        if (variables.isEmpty()) {
            throw new UserDefinedVariableResolverException('Variable not found: ' + referenceName);
        }

        return variables[0].Value__c;
    }

    public class UserDefinedVariableResolverException extends Exception {}
}
