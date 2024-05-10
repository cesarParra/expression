@IsTest
private class SchemaUtilsTest {
    @IsTest
    static void getValidChildRelationshipNameReturnsTheValidNameForAnExistingRelationship() {
        String potentialRelationship = 'contacts';
        SObjectType typeToCheck = Account.SObjectType;

        String validRelationship = SchemaUtils.getValidChildRelationshipName(potentialRelationship, typeToCheck);

        System.assertEquals('Contacts', validRelationship);
    }

    @IsTest
    static void getValidChildRelationshipNameThrowsAnExceptionForAnInvalidRelationship() {
        String potentialRelationship = 'invalidRelationship';
        SObjectType typeToCheck = Account.SObjectType;

        try {
            SchemaUtils.getValidChildRelationshipName(potentialRelationship, typeToCheck);
            System.assert(false, 'An exception should have been thrown.');
        } catch (SchemaUtils.InvalidRelationshipException e) {
            System.assertEquals(
                'The relationship name "invalidRelationship" is not a valid relationship name for the Account object.',
                e.getMessage()
            );
        }
    }
}
