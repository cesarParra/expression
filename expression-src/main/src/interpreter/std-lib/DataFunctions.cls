/**
 * @description Repository of functions that can be used in expressions.
 * @group Data
 * @function-repository true
 * @display-icon utility:data_mapping
 */
public with sharing class DataFunctions {
    private static final Map<String, StandardFunction> FUNCTIONS = new Map<String, StandardFunction>{
        'TRANSFORM' => new TransformFn(),
        'LET' => new LET(),
        'RAWQUERY' => new RawQuery(),
        'PRINT' => new PrintFn()
    };

    public class DataFunctionsProvider implements FunctionProvider {
        public Map<String, StandardFunction> getFunctions() {
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
    private class TransformFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object sourceObj = evaluate(arguments.get(0));
            Environment env = new Environment();
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
    private class LET extends StandardFunction {
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

    /**
     * @description Allows you to run a raw query against the database.
     * Accepts 1 argument: the query to run.
     * @function RAWQUERY
     * @example RAWQUERY("SELECT Id, Name FROM Account LIMIT 10")
     */
    private class RawQuery extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object queryObj = (String) evaluate(arguments.get(0));
            if (!(queryObj instanceof String)) {
                throw new FunctionExecutionException('First argument to RAW_QUERY must be a string');
            }
            String query = (String) queryObj;
            return QDB.getInstance().runRaw(query);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    /**
     * @description Allows you to print a value to the playground console.
     * Accepts 1 argument: the value to print.
     * @function PRINT
     * @example PRINT("Hello World")
     */
    private class PrintFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object toPrint = evaluate(arguments.get(0));
            Printer.instance.print(toPrint);
            return toPrint;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }
}
