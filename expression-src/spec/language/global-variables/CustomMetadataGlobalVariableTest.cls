@IsTest
private class CustomMetadataGlobalVariableTest {
    @IsTest
    private static void canReferenceCustomMetadataTypeRecords() {
        String formula = '$CustomMetadata.MyCustomMetadataType__mdt.MyRecord.MyField__c';
        try {
            Evaluator.run(formula);

            // Expecting an exception since the only way to test against a CMT
            // is having a record of that type in the org.
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }
}
