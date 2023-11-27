---
title: Custom Functions
nextjs:
  metadata:
    title: Custom Functions
    description: Create your own custom functions.
---

You can create your own custom formula functions by implementing the `expression.IExpressionFunction` interface.
This interface has a single method, `Object run(List<Object> args)`, which receives the arguments passed to the
function (if any) and returns the result.

```apex
global class MyCustomFunction implements expression.IExpressionFunction {
    global Object run(List<Object> args) {
        // Do something with the arguments and return the result
    }
}
```

To register your custom function, you need to create a new Custom Metadata record of type `Expression Function`
and specify the name of the function and the Apex class that implements it:

* Go to `Setup > Custom Metadata Types` and click `Manage Records` next to `Expression Function`
* Click `New` and enter the name of your function and the Apex class that implements it
* Click `Save`
* Your function is now available to use in formulas using the name you specified
