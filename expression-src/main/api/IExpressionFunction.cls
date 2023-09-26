/**
 * @description Allows you to define your own custom functions for use in expressions.
 */
global interface IExpressionFunction {
    Object execute(List<Object> args);
}
