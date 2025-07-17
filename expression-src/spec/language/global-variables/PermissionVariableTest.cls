@IsTest
private class PermissionVariableTest {
    @IsTest
    static void canCheckPermissionsForuser() {
        String expression = '$Permission.CustomPermissionName';
        try {
            Object result = Evaluator.run(expression);
            Assert.isNotNull(result, 'Permission check should not return null');
        } catch (Exception e) {
            Assert.fail('Permission check failed with exception: ' + e.getMessage());
        }
    }
}
