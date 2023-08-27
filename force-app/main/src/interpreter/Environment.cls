public with sharing class Environment {
    private final SObject context;

    public Environment(SObject context) {
        this.context = context;
    }

    public Boolean containsField(String field) {
        String lowerCaseField = field.toLowerCase();

        Set<String> fields = context.getSObjectType().getDescribe().fields.getMap().keySet();
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
