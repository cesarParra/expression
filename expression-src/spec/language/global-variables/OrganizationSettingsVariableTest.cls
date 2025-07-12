@IsTest
private class OrganizationSettingsVariableTest {
    // ConnectApi methods are not supported in data siloed
    // tests, so we need to use SeeAllData=true.

    @IsTest(SeeAllData=true)
    static void canRetrieveOrganizationName() {
        String expression = '$OrganizationSettings.name';
        Object result = Evaluator.run(expression);
        Assert.isTrue(result instanceof String);
        Assert.isNotNull(result);
    }

    @IsTest(SeeAllData=true)
    static void canRetrieveOrganizationId() {
        String expression = '$OrganizationSettings.orgId';
        Object result = Evaluator.run(expression);
        Assert.isTrue(result instanceof String);
        Assert.isNotNull(result);
    }
}
