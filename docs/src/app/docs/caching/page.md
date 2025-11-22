---
title: Caching
nextjs:
  metadata:
    title: Caching
    description: Learn how caching works and how to control it.
---

By default, all calls to Expression built-in functions are cached for performance.
This means that if you call the same function with the same arguments multiple times,
the result will be retrieved from the cache instead of being recalculated.

For example, if you have an Expression that for a given reason executes the same `Query`
twice with the same parameters, the second execution will return the cached result of the first execution,
preventing the Salesforce governor limits from being hit.

This aggressive caching is generally safe, because all Expression functions are pure (give the same
output for the same input, without side effects). Caching is also contextual, meaning that if you
call the `expression.Evaluator.run` method multiple times with different contexts, the caches will not
interfere with each other, even if you have the same function calls in different expressions.

But there are situations where you might want to disable caching, for example, if you have a custom
function that performs non-deterministic operations (like generating random numbers) or side effects, like
DML operations. For these cases, you can control the caching behavior in the following ways:

## Global Caching

Global caching is enabled by default for all Expression built-in (standard) functions. You can
disable it by calling the `disableStandardFunctionResultCaching` method of the `Configuration` object:

```apex
expression.Configuration config = new expression.Configuration()
    .disableStandardFunctionResultCaching();
expression.Evaluator.run('your expression here', config);
```

## User-defined Function Caching

You can control cache independently for any function you declare yourself, by using the `nocache` keyword.
See [Declaring Functions](./declaring-functions) for more information.

But be aware that if global caching is enabled, the `nocache` keyword will have no effect on built-in functions
called from within your custom function. These will still be cached.

## Custom Metadata Type Functions

If you are using [Custom Metadata Type Functions](./custom-functions), you can control caching by setting
the `Cache Result` field on the Custom Metadata record to `false`. This flag is independent of the global caching
setting,
so regardless of whether global caching is enabled or disabled, setting this flag will enable/disable caching for that
specific function.
