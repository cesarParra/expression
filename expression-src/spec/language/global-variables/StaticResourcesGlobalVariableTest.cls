@IsTest
private class StaticResourcesGlobalVariableTest {
    @IsTest
    private static void canReferenceStaticResources() {
        String formula = '$Resource.MyStaticResource';
        try {
            Evaluator.run(formula);

            // Expecting an exception since that static resource
            // doesn't exist.
            // This test is essentially for coverage.
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }
}
