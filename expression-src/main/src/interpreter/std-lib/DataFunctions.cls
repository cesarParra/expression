/**
 * @description Repository of functions that can be used in expressions.
 * @group Data
 * @function-repository true
 * @display-icon utility:data_mapping
 */
public with sharing class DataFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'TRANSFORM' => new TransformFn(),
        'LET' => new LET()
    };

    public class DataFunctionsProvider implements FunctionProvider {
        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }
    }

    /**
     * @description Transforms any input using the provided expression.
     * Provides a special variable `$source` in the inner expression that contains the original input.
     *
     * Accepts 2 arguments: the input to transform and the expression to evaluate.
     * @function TRANSFORM
     * @example TRANSFORM("Hello World", UPPER($source)) // "HELLO WORLD"
     */
    private class TransformFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object sourceObj = evaluate(arguments.get(0));
            Environment env = new Environment(null);
            env.define('$source', sourceObj);
            Interpreter interpreter = new Interpreter(env);
            return interpreter.interpret(arguments.get(1));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Allows you to define custom variables that can be used in the expression.
     * Accepts 2 arguments: a map of variables to define and the expression to evaluate.
     * The map keys should be the variable names prefixed with `$`.
     * @function LET
     * @example LET({ "$a": 1, "$b": 2 }, $a + $b) // 3
     */
    private class LET extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument should be a map
            Object left = evaluate(arguments.get(0));
            if (!(left instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException('First argument to LET must be a map');
            }

            for (Object key : ((Map<Object, Object>) left).keySet()) {
                if (!(key instanceof String)) {
                    throw new FunctionExecutionException('Keys in map passed to LET must be strings');
                }

                String keyStr = (String) key;
                if (!keyStr.startsWith('$')) {
                    throw new FunctionExecutionException('Custom variables created through LET must start with $');
                }

                Environment.addGlobalVariable(keyStr, ((Map<Object, Object>) left).get(key));
            }

            // Second argument is any expression
            return evaluate(arguments.get(1));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
