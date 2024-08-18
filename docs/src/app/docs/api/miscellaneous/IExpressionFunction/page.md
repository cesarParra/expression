---
nextjs:
  metadata:
    title: IExpressionFunction
    description: Api documentation for the IExpressionFunction interface}
---

# IExpressionFunction Interface

Allows you to define your own custom functions for use in expressions.

## Namespace
expression

## Methods
### `execute(args)`

Implement this method to execute your custom function.

#### Signature
```apex
global Object execute(List<Object> args)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| args | List&lt;Object&gt; | The arguments passed to the function, if any. |

#### Return Type
**Object**

The result of the function.

#### Example
This example shows how to implement a function that returns the sum of its arguments. 
```apex
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