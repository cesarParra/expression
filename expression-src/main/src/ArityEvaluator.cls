public with sharing class ArityEvaluator {
    public static void check(ExpressionFunction fn, Expr.FunctionCall function) {
        if (fn.getArity().isSatisfiedBy(function.arguments.size()) == false) {
            throw new Exceptions.RuntimeException(
                function.functionToken,
                'Error executing ' + function.functionName + ' function: the function expects ' +
                    fn.getArity().toString() + ' argument(s), but ' +
                    function.arguments.size() + ' were provided.'
            );
        }
    }
}
