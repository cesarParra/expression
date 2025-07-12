@IsTest
private class UserSettingsVariableTest {
    // ConnectApi methods cannot be accessed in siloed tests, thus the need for SeeAllData=true.
    @IsTest(SeeAllData=true)
    static void canReferenceUserInformation() {
        // Catch all test to ensure that the $UserSettings global variable can be referenced.
        // Since everything else wraps ConnectApi.UserSettings, there is no need
        // to test each individual property, except for time zone, which has some additional
        // logic, and is tested separately.

        String expression = '$UserSettings.userLocale';
        Object result = Evaluator.run(expression);
        Assert.isNotNull(result, 'User locale should not be null');
        Assert.isTrue(result instanceof String, 'Expected a String result for user locale');
    }

    @IsTest(SeeAllData=true)
    static void canReferenceTimezone() {
        String expression = '$UserSettings.timeZone';
        Object result = Evaluator.run(expression);
        Assert.isNotNull(result, 'User locale should not be null');
        Assert.isTrue(result instanceof Map<String, Object>, 'Expected a Map result for time zone');

        Map<String, Object> timeZoneMap = (Map<String, Object>)result;
        Assert.isTrue(timeZoneMap.containsKey('name'), 'Time zone map should contain "name" key');
        Assert.isTrue(timeZoneMap.containsKey('gmtOffset'), 'Time zone map should contain "gmtOffset" key');
    }
}
