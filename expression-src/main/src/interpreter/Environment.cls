public with sharing class Environment {
    private final SObject context;
    private final Map<String, Object> variables = new Map<String, Object>();

    private static final Map<String, Object> GLOBAL_VARIABLES = new Map<String, Object>();
    private static final Map<String, Expr.FunctionDeclaration> FUNCTIONS = new Map<String, Expr.FunctionDeclaration>();

    static {
        GLOBAL_VARIABLES.put('$label', new CustomLabelVariableResolver.CustomLabelResolverWrapper());
        GLOBAL_VARIABLES.put('$custommetadata', new CustomMetadataVariableResolver.CmtApiName());
        GLOBAL_VARIABLES.put('$resource', new StaticResourceVariableResolver());
        GLOBAL_VARIABLES.put('$action', new ActionVariableResolver());
        GLOBAL_VARIABLES.put('$user', new UserVariableResolver());

        // Placeholder value for whatever the called Action returned. Not used by language,
        // but can be used by the caller to get the return value of the Action.
        GLOBAL_VARIABLES.put('$returnvalue', '{!placeholder}');
    }

    public static void addGlobalVariable(String name, Object value) {
        // Check that the name has not already been declared
        if (GLOBAL_VARIABLES.containsKey(name.toLowerCase())) {
            throw new EnvironmentException('Variable with name ' + name + ' already exists');
        }

        GLOBAL_VARIABLES.put(name.toLowerCase(), value);
    }
    
    public static void addFunction(Expr.FunctionDeclaration function) {
        // Check that the name has not already been declared
        if (FUNCTIONS.containsKey(function.functionName.toUpperCase())) {
            throw new EnvironmentException('Function with name ' + function.functionName + ' already exists');
        }

        FUNCTIONS.put(function.functionName.toUpperCase(), function);
    }

    public static Boolean hasFunction(String functionName) {
        return FUNCTIONS.containsKey(functionName.toUpperCase());
    }

    public static Expr.FunctionDeclaration getFunction(String functionName) {
        return FUNCTIONS.get(functionName.toUpperCase());
    }

    /**
     * @description Adds a global context variable that can be accessed from any formula.
     * Prefixes the name with '@'.
     * @param name The name of the global context variable.
     * @param value The value to be stored in the global context variable.
     */
    public static void addGlobalContextVariable(String name, Object value) {
        String prefixedName = '@' + name;
        GLOBAL_VARIABLES.put(prefixedName.toLowerCase(), value);
    }

    public Environment(SObject context) {
        this.context = context;
    }

    public Boolean noRecordContext() {
        return context == null;
    }

    public void define(String name, Object value) {
        variables.put(name.toLowerCase(), value);
    }

    public Boolean contains(String field) {
        String lowerCaseField = field.toLowerCase();

        if (variables.containsKey(lowerCaseField) || GLOBAL_VARIABLES.containsKey(lowerCaseField)) {
            return true;
        }

        Set<String> fields = context?.getSObjectType().getDescribe().fields.getMap().keySet();
        if (fields == null) {
            return false;
        }
        if (fields.contains(lowerCaseField)) {
            return true;
        }

        // The name could also be a child relationship name, so add those as well
        for (ChildRelationship relationship : context.getSObjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == lowerCaseField) {
                return true;
            }
        }

        return false;
    }

    public Boolean containsAsParent(String fieldName) {
        try {
            context.getSObject(fieldName);
            return true;
        } catch (SObjectException ex) {
            return false;
        }
    }

    public Object get(String field) {
        String lowerCaseField = field.toLowerCase();

        // Try to get it from the variables first
        if (variables.containsKey(lowerCaseField)) {
            return variables.get(lowerCaseField);
        }

        // Look in global variables
        if (GLOBAL_VARIABLES.containsKey(lowerCaseField)) {
            return GLOBAL_VARIABLES.get(lowerCaseField);
        }

        if (context == null) {
            throw new EnvironmentException('No such field: ' + field);
        }

        if (context.getSObjectType().getDescribe().fields.getMap().keySet().contains(lowerCaseField)) {
            return context.get(field);
        }

        // The name could also be a child relationship name, so look in there next
        for (ChildRelationship relationship : context.getSObjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == lowerCaseField) {
                return context.getSObjects(relationship.getRelationshipName()) ?? new List<SObject>();
            }
        }

        throw new EnvironmentException('No such field: ' + field);
    }

    public String getSObjectTypeName() {
        return context.getSObjectType().getDescribe().getName();
    }

    public SObject getParentSObject(String fieldName) {
        return context.getSObject(fieldName);
    }

    public class EnvironmentException extends Exception {
    }
}
