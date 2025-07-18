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

    @IsTest
    static void customContextIsNeverNull() {
        Configuration config = new Configuration().withCustomContext(null);
        Assert.isTrue(config.customContext.isEmpty());
    }

    @IsTest
    static void suppressErrorsDefaultsToFalse() {
        Configuration config = new Configuration();
        Assert.isFalse(config.suppressErrors);
    }

    @IsTest
    static void canEnableSuppressErrors() {
        Configuration config = new Configuration().suppressErrors();
        Assert.isTrue(config.suppressErrors);
    }
}
