# expression.IExpressionFunction

Allows you to define your own custom functions for use in expressions.

## Methods
### `global Object execute(List<Object> args)`

Implement this method to execute your custom function.

#### Parameters

|Param|Description|
|---|---|
|`args`|The arguments passed to the function, if any.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the function.|

#### Example
```apex
// This example shows how to implement a function that returns the sum of its arguments.
global class SumFunction implements IExpressionFunction {
    global Object execute(List<Object> args) {
        Decimal result = 0;
        for (Object arg : args) {
            result += (Decimal)arg;
        }
        return result;
    }
 }
```


---
