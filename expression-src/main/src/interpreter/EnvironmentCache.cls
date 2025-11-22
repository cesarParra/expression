public with sharing class EnvironmentCache {
    private static Boolean isStandardFunctionCacheDisabled = false;

    private static final Map<Environment, Map<Expr.FunctionCall, Object>> functionCallCache =
        new Map<Environment, Map<Expr.FunctionCall, Object>>();
    private static final Map<Environment, Map<Expr.Query, Object>> queryCacheByEnvironment =
        new Map<Environment, Map<Expr.Query, Object>>();

    public static void disableCache() {
        isStandardFunctionCacheDisabled = true;
    }

    public static void cacheStandardFunctionCall(
        Environment env,
        Expr.FunctionCall function,
        Object result
    ) {
        cacheFunctionCall(isStandardFunctionCacheDisabled, env, function, result);
    }

    public static void cacheCustomMetadataFunctionCall(
        Boolean shouldCacheConfiguration,
        Environment env,
        Expr.FunctionCall function,
        Object result
    ) {
        cacheFunctionCall(shouldCacheConfiguration, env, function, result);
    }

    private static void cacheFunctionCall(
        Boolean shouldCache,
        Environment env,
        Expr.FunctionCall function,
        Object result
    ) {
        if (!shouldCache) {
            return;
        }

        Map<Expr.FunctionCall, Object> cachedFunctions = functionCallCache.get(env) ?? new Map<Expr.FunctionCall, Object>();
        cachedFunctions.put(function, result);
        functionCallCache.put(env, cachedFunctions);
    }

    public static Boolean isFunctionCallCached(
        Environment env,
        Expr.FunctionCall function
    ) {
        Map<Expr.FunctionCall, Object> cachedFunctions = functionCallCache.get(env);
        return cachedFunctions != null && cachedFunctions.containsKey(function);
    }

    public static Object getCachedFunctionCall(
        Environment env,
        Expr.FunctionCall function
    ) {
        Map<Expr.FunctionCall, Object> cachedFunctions = functionCallCache.get(env);
        if (cachedFunctions != null) {
            return cachedFunctions.get(function);
        }
        return null;
    }

    public static void cacheQueryResult(Environment env, Expr.Query query, Object result) {
        if (isStandardFunctionCacheDisabled) {
            return;
        }

        if (!queryCacheByEnvironment.containsKey(env)) {
            queryCacheByEnvironment.put(env, new Map<Expr.Query, Object>());
        }
        queryCacheByEnvironment.get(env).put(query, result);
    }

    public static Boolean isQueryResultCached(Environment env, Expr.Query query) {
        if (!queryCacheByEnvironment.containsKey(env)) {
            return false;
        }
        return queryCacheByEnvironment.get(env).containsKey(query);
    }

    public static Object getCachedQueryResult(Environment env, Expr.Query query) {
        if (!queryCacheByEnvironment.containsKey(env)) {
            return null;
        }
        return queryCacheByEnvironment.get(env).get(query);
    }
}
