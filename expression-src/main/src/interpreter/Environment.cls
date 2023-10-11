public with sharing class Environment {
    private final SObject context;
    private final Map<String, Object> variables = new Map<String, Object>();

    public Environment(SObject context) {
        this.context = context;

        // Define global variables
        define('$label', new CustomLabelVariableResolver.CustomLabelResolverWrapper());
        define('$custommetadata', new CustomMetadataVariableResolver.CmtApiName());
        define('$resource', new StaticResourceVariableResolver());
        define('$action', new ActionVariableResolver());
    }

    public Boolean noRecordContext() {
        return context == null;
    }

    public void define(String name, Object value) {
        variables.put(name.toLowerCase(), value);
    }

    public Boolean contains(String field) {
        String lowerCaseField = field.toLowerCase();

        if (variables.containsKey(lowerCaseField)) {
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

    public Boolean containsAsParent(String fieldName){
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

        if (context.getSObjectType().getDescribe().fields.getMap().keySet().contains(lowerCaseField)) {
            return context.get(field);
        }

        // The name could also be a child relationship name, so look in there next
        for (ChildRelationship relationship : context.getSObjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == lowerCaseField) {
                List<SObject> returnValue = context.getSObjects(relationship.getRelationshipName());
                if (returnValue == null) {
                    return new List<SObject>();
                } else {
                    return returnValue;
                }
            }
        }

        throw new Interpreter.InterpreterException('No such field: ' + field);
    }

    public String getSObjectTypeName() {
        return context.getSObjectType().getDescribe().getName();
    }

    public SObject getParentSObject(String fieldName) {
        return context.getSObject(fieldName);
    }
}
