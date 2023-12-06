/**
 * @description Allows you to define your own custom functions for use in expressions.
 */
global interface IExpressionFunction {
    /**
     * @description Implement this method to execute your custom function.
     * @param args The arguments passed to the function, if any.
     * @return The result of the function.
     * @example
     * // This example shows how to implement a function that returns the sum of its arguments.
     * global class SumFunction implements IExpressionFunction {
     *     global Object execute(List<Object> args) {
     *         Decimal result = 0;
     *         for (Object arg : args) {
     *             result += (Decimal)arg;
     *         }
     *         return result;
     *     }
     *  }
     */
    Object execute(List<Object> args);
}
