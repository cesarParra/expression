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

    @IsTest
    static void standardFunctionCacheEnabled_respectsChangingCustomContextValues() {
        Configuration config1 = new Configuration();
        config1.cacheStandardFunctionResults = true;
        config1.customContext = new Map<String, Object>{
                'value' => 'first'
        };

        Configuration config2 = new Configuration();
        config2.cacheStandardFunctionResults = true;
        config2.customContext = new Map<String, Object>{
                'value' => 'second'
        };

        Test.startTest();
        Object firstResult = Evaluator.run('UPPER(@value)', config1);
        Object secondResult = Evaluator.run('UPPER(@value)', config2);
        Test.stopTest();

        System.assertEquals('FIRST', firstResult, 'First evaluation must use the first customContext.');
        System.assertEquals(
                'SECOND',
                secondResult,
                'Second evaluation must respect the updated context variable even when caching is enabled.'
        );
    }

    @IsTest
    static void queryCacheRespectsChangingCustomContextValues() {
        // Two records that the same query can match depending on the @name context variable.
        Account first = new Account(Name = 'CtxCacheFirst');
        Account second = new Account(Name = 'CtxCacheSecond');
        insert new List<Account>{ first, second };

        Configuration config1 = new Configuration();
        config1.cacheStandardFunctionResults = true;
        config1.customContext = new Map<String, Object>{
                'name' => 'CtxCacheFirst'
        };

        Configuration config2 = new Configuration();
        config2.cacheStandardFunctionResults = true;
        config2.customContext = new Map<String, Object>{
                'name' => 'CtxCacheSecond'
        };

        String expr = 'QUERY(Account(where: Name = @name) [Id, Name])';

        Test.startTest();
        List<Account> firstResult = (List<Account>) Evaluator.run(expr, config1);
        List<Account> secondResult = (List<Account>) Evaluator.run(expr, config2);
        Test.stopTest();

        System.assertEquals(1, firstResult.size(), 'First query should match exactly one Account.');
        System.assertEquals(
                'CtxCacheFirst',
                firstResult[0].Name,
                'First query must match the Account named by the first customContext.'
        );

        System.assertEquals(1, secondResult.size(), 'Second query should match exactly one Account.');
        System.assertEquals(
                'CtxCacheSecond',
                secondResult[0].Name,
                'Second query must respect the updated context variable, not return the cached result from the first run.'
        );
    }

}