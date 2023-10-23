/**
 * @description Repository of functions that can be used in expressions.
 * @group Data
 * @function-repository true
 * @display-icon utility:data_mapping
 */
public with sharing class DataFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'FETCH' => new FetchFn(),
        'TRANSFORM' => new TransformFn(),
        'LET' => new LET()
    };

    public class DataFunctionsProvider implements FunctionProvider {
        public String getCategory() {
            return 'Data';
        }

        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }

        public String getIcon() {
            return 'utility:data_mapping';
        }
    }

    /**
     * @description Allows you to query data from the database. This is useful
     * when the data you want to use is not provided as part of the context.
     *
     * TTakes 2 arguments: a string with the `SObjectName` you wish to extract data from,
     * and a list of strings with the fields you wish to extract. This will query all the records of the given
     * type and return a list of `SObjects` with the data.
     *
     * Note that when using this function, the automatic context resolution is not performed, so you need to
     * explicitly specify all fields you wish to reference in the formula.
     * @function FETCH
     * @example
     * FETCH("Account", ["Id", "Name"])
     */
    private with sharing class FetchFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a string representing the sobject type name
            Object sobjectType = evaluate(arguments.get(0));
            if (!(sobjectType instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "FETCH" function: the first argument must evaluate to a string.'
                );
            }

            // Second argument is a list of strings representing the field names
            Object fieldNames = evaluate(arguments.get(1));
            if (!(fieldNames instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "FETCH" function: the second argument must evaluate to a list of strings.'
                );
            }

            Q query = new Q((String) sobjectType);
            for (Object fieldName : (List<Object>) fieldNames) {
                if (!(fieldName instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "FETCH" function: the second argument must evaluate to a list of strings.'
                    );
                }
                query.selectField((String) fieldName);
            }

            return QRunner.getInstance().run(query);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Transforms any input using the provided expression.
     * Provides a special variable `$source` in the inner expression that contains the original input.
     *
     * Accepts 2 arguments: the input to transform and the expression to evaluate.
     * @function TRANSFORM
     * @example
     * TRANSFORM("Hello World", UPPER($source)) // "HELLO WORLD"
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
     * @example
     * LET({ "$a": 1, "$b": 2 }, $a + $b) // 3
     */
    private class LET extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument should be a map
            Object left = evaluate(arguments.get(0));
            if (!(left instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException('First argument to LET must be a map');
            }

            for (Object key : ((Map<Object, Object>)left).keySet()) {
                if (!(key instanceof String)) {
                    throw new FunctionExecutionException('Keys in map passed to LET must be strings');
                }

                String keyStr = (String)key;
                if (!keyStr.startsWith('$')) {
                    throw new FunctionExecutionException('Custom variables created through LET must start with $');
                }

                Environment.addGlobalVariable(keyStr, ((Map<Object, Object>)left).get(key));
            }

            // Second argument is any expression
            return evaluate(arguments.get(1));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
