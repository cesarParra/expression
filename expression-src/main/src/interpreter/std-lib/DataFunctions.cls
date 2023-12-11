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
        'LET' => new LET(),
        'ORDERBY' => new OrderByFn()
    };

    public class DataFunctionsProvider implements FunctionProvider {
        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }
    }

    /**
     * @description Allows you to query data from the database. This is useful
     * when the data you want to use is not provided as part of the context.
     *
     * Takes 2 arguments: a string with the `SObjectName` you wish to extract data from,
     * and a list of strings with the fields you wish to extract. This will query all the records of the given
     * type and return a list of `SObjects` with the data.
     *
     * Note that when using this function, the automatic context resolution is not performed, so you need to
     * explicitly specify all fields you wish to reference in the formula.
     * @function FETCH
     * @example FETCH("Account", ["Id", "Name"])
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

            if (arguments.size() > 2) {
                Object orderBy = evaluate(arguments.get(2));
                if (!(orderBy instanceof QOrder)) {
                    throw new FunctionExecutionException(
                        'Invalid function used within a FETCH function: the third argument must be an ORDER BY clause.'
                    );
                }
                query.add((QOrder) orderBy);
            }

            return QRunner.getInstance().run(query);
        }

        public override Arity getArity() {
            return Arity.atLeast(2);
        }
    }

    /**
     * @description Allows you to specify the order in which the results of a FETCH function are returned.
     * Note that this function can only be used within a FETCH function.
     *
     * Takes 2 arguments: a string with the field name to order by and a string with the order direction.
     * The order direction can be either `ASC` or `DESC`.
     * The order of direction is optional and defaults to `ASC`.
     *
     * @function ORDER BY
     * @example FETCH("Account", ["Id", "Name"], ORDERBY("Name", "DESC"))
     */
    private with sharing class OrderByFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // This can only be called from within a FETCH function.
            // The call stack will include the current function, so if it is only 1 element long
            // it means that the current function is the only one in the stack.
            // If the second element is not FETCH, it means that the current function is not being called
            // from within a FETCH function.
            if (CallStack.instance.size()  == 1 || CallStack.instance.peekN(2).toUpperCase() != 'FETCH') {
                System.debug(CallStack.instance.toString());
                throw new FunctionExecutionException(
                    'Error executing "ORDER BY" function: this function can only be used within a FETCH function.'
                );
            }

            // First argument is a string representing the field name
            Object fieldName = evaluate(arguments.get(0));
            if (!(fieldName instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "ORDER BY" function: the first argument must evaluate to a string.'
                );
            }

            // The second argument is optional and represents the order direction
            if (arguments.size() > 1) {
                Object orderDirection = evaluate(arguments.get(1));
                if (!(orderDirection instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "ORDER BY" function: the second argument must evaluate to a string.'
                    );
                }

                if (!orderDirection.equals('ASC') && !orderDirection.equals('DESC')) {
                    throw new FunctionExecutionException(
                        'Error executing "ORDER BY" function: the second argument must be either "ASC" or "DESC".'
                    );
                }

                switch on ((String) orderDirection) {
                    when 'ASC' {
                        return new QOrder((String) fieldName).ascending();
                    }

                    when 'DESC' {
                        return new QOrder((String) fieldName).descending();
                    }

                    when else {
                        throw new FunctionExecutionException(
                            'Error executing "ORDER BY" function: the second argument must be either "ASC" or "DESC".'
                        );
                    }
                }
            }

            return new QOrder((String) fieldName);
        }

        public override Arity getArity() {
            return Arity.atLeast(1);
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
