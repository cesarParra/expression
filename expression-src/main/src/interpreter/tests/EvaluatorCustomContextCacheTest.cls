@IsTest
private class EvaluatorCustomContextCacheTest {

    @IsTest
    static void standardFunctionCacheDisabled_doesNotReuseFirstCustomContext() {
        Configuration config1 = new Configuration();
        config1.cacheStandardFunctionResults = false;
        config1.customContext = new Map<String, Object>{
                'value' => 'first'
        };

        Configuration config2 = new Configuration();
        config2.cacheStandardFunctionResults = false;
        config2.customContext = new Map<String, Object>{
                'value' => 'second'
        };

        Test.startTest();
        Object firstResult = Evaluator.run('UPPER(@value)', config1);
        Object secondResult = Evaluator.run('UPPER(@value)', config2);
        Test.stopTest();

        System.assertEquals(
                'FIRST',
                firstResult,
                'First evaluation must use the first customContext, not cached result from first run.'
        );
        System.assertEquals(
                'SECOND',
                secondResult,
                'Second evaluation must use the second customContext, not cached result from first run.'
        );
    }

}