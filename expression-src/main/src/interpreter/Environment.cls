public with sharing class Environment {
    private final Environment parentEnvironment;
    private final SObject context;

    private SObject getContext() {
        return context ?? parentEnvironment?.getContext();
    }

    private final Map<String, Object> variables = new Map<String, Object>();

    private Map<String, Object> getVariables() {
        Map<String, Object> allVariables = parentEnvironment?.getVariables() ?? new Map<String, Object>();
        allVariables.putAll(variables);
        return allVariables;
    }

    private static final Map<String, Object> GLOBAL_VARIABLES = new Map<String, Object>();

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
            throw new EnvironmentException('Variable or function with name ' + name + ' already exists');
        }

        GLOBAL_VARIABLES.put(name.toLowerCase(), value);
    }

    public Boolean hasFunction(String functionName) {
        return getFunction(functionName) != null;
    }

    public Expr.FunctionDeclaration getFunction(String functionName) {
        String lowercasedName = functionName.toLowerCase();
        // First try and find it locally
        Object possibleFunction = getVariables().get(lowercasedName);
        if (possibleFunction != null && possibleFunction instanceof Expr.FunctionDeclaration) {
            return (Expr.FunctionDeclaration) possibleFunction;
        }

        // Otherwise, look in the global variables
        return (Expr.FunctionDeclaration) GLOBAL_VARIABLES.get(functionName.toLowerCase());
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

    public Environment() {}

    public Environment(Environment parentEnvironment) {
        this.parentEnvironment = parentEnvironment;
    }

    public Environment(SObject context) {
        this.context = context;
    }

    public void define(String name, Object value) {
        variables.put(name.toLowerCase(), value);
    }

    public Boolean contains(String field) {
        String lowerCaseField = field.toLowerCase();

        if (getVariables().containsKey(lowerCaseField) || GLOBAL_VARIABLES.containsKey(lowerCaseField)) {
            return true;
        }

        Set<String> fields = getContext()?.getSObjectType().getDescribe().fields.getMap().keySet();
        if (fields == null) {
            return false;
        }
        if (fields.contains(lowerCaseField)) {
            return true;
        }

        // The name could also be a child relationship name, so add those as well
        for (ChildRelationship relationship : getContext().getSObjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == lowerCaseField) {
                return true;
            }
        }

        return false;
    }

    public Boolean containsAsParent(String fieldName) {
        try {
            Object result = getContext()?.getSObject(fieldName);
            return result != null;
        } catch (SObjectException ex) {
            return false;
        }
    }

    public Object get(String field) {
        String lowerCaseField = field.toLowerCase();

        // Try to get it from the variables first
        if (getVariables().containsKey(lowerCaseField)) {
            return getVariables().get(lowerCaseField);
        }

        // Look in global variables
        if (GLOBAL_VARIABLES.containsKey(lowerCaseField)) {
            return GLOBAL_VARIABLES.get(lowerCaseField);
        }

        if (getContext() == null) {
            throw new EnvironmentException('No such field: ' + field);
        }

        if (getContext().getSObjectType().getDescribe().fields.getMap().keySet().contains(lowerCaseField)) {
            return getContext().get(field);
        }

        // The name could also be a child relationship name, so look in there next
        for (ChildRelationship relationship : getContext().getSObjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == lowerCaseField) {
                return getContext().getSObjects(relationship.getRelationshipName()) ?? new List<SObject>();
            }
        }

        throw new EnvironmentException('No such field: ' + field);
    }

    public String getSObjectTypeName() {
        return getContext()?.getSObjectType().getDescribe().getName();
    }

    public SObject getParentSObject(String fieldName) {
        return getContext()?.getSObject(fieldName);
    }

    public class EnvironmentException extends Exception {
    }

    public Boolean equals(Object obj) {
        Environment other = (Environment) obj;
        return parentEnvironment == other.parentEnvironment && context == other.context && variables.equals(other.variables);
    }

    public override Integer hashCode() {
        return (parentEnvironment != null ? parentEnvironment.hashCode() : 0) ^ (context != null ? context.hashCode() : 0) ^ variables.hashCode();
    }
}
