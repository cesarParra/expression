public with sharing class SchemaUtils {
    /**
     * @description Returns the valid relationship name (accounting for casing) for a child relationship on an SObject.
     * @param potentiallyInvalidName The potentially invalid relationship name.
     * @param sType The SObjectType to check the relationship name against.
     * @return The valid relationship name.
     * @throws InvalidRelationshipException If the relationship name is not valid for the SObjectType.
     */
    public static String getValidChildRelationshipName(String potentiallyInvalidName, SObjectType sType) {
        for (ChildRelationship relationship : sType.getDescribe().getChildRelationships()) {
            if (potentiallyInvalidName.equalsIgnoreCase(relationship.getRelationshipName())) {
                return relationship.getRelationshipName();
            }
        }

        throw new InvalidRelationshipException(
            'The relationship name "' + potentiallyInvalidName + '" is not a valid relationship name for the ' + sType.getDescribe().getName() + ' object.'
        );
    }

    public class InvalidRelationshipException extends Exception {}
}
