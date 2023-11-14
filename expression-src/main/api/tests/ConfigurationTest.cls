@IsTest
private class ConfigurationTest {
    @IsTest
    static void hasAnEmptyCustomContextByDefault() {
        Configuration config = new Configuration();
        Assert.isTrue(config.customContext.isEmpty());
    }

    @IsTest
    static void canBuildWithCustomContext() {
        Configuration config = new Configuration().withCustomContext(new Map<String, Object>{
            'foo' => 'bar'
        });

        Assert.isTrue(config.customContext.containsKey('foo'));
    }
}
