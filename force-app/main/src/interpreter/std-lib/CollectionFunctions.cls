public with sharing class CollectionFunctions {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'LIST' => new ListFn(),
        'MAP' => new MapFn(),
        'WHERE' => new WhereFn(),
        'AVERAGE' => new AverageFn(),
        'SIZE' => new SizeFn(),
        'ISEMPTY' => new IsEmptyFn(),
        'APPEND' => new AppendFn(),
        'SORT' => new SortFn(),
        'DISTINCT' => new DistinctFn(),
        'KEYS' => new KeysFn(),
        'GET' => new GetFn(),
        'VALUES' => new ValuesFn()
    };

    private class ListFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            interpreter.setIsInListLiteral(true);

            List<Object> result = new List<Object>();
            for (Expr argument : arguments) {
                Object item = evaluate(argument);
                if (item instanceof Interpreter.ListSpreadContents) {
                    result.addAll(((Interpreter.ListSpreadContents) item).contents);
                } else {
                    result.add(item);
                }
            }

            return result;
        }

        public override Arity getArity() {
            return Arity.atLeast(1);
        }
    }

    private class MapFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MAP" function: the first argument must evaluate to a list.'
                );
            }

            // If the list of children is empty, return early
            List<Object> childrenAsList = (List<Object>) children;
            if (childrenAsList.isEmpty()) {
                return new List<Object>();
            }

            // For all children we want to evaluate the subexpression.
            // Each one of the children will now act as a standalone context for a new expression.
            Expr secondArgument = arguments.get(1);
            List<Object> result = new List<Object>();
            for (Integer i = 0; i < childrenAsList.size(); i++) {
                Object child = childrenAsList.get(i);
                Environment env;
                if (child instanceof SObject) {
                    env = new Environment((SObject)child);
                } else {
                    env = new Environment(null);
                }

                env.define('$current', child);
                env.define('$index', i);
                env.define('$total', childrenAsList.size());

                Interpreter interpreter = new Interpreter(env);
                result.add(interpreter.interpret(secondArgument));
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }
    }

    private class WhereFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "WHERE" function: the first argument must evaluate to a list.'
                );
            }

            // If the list of children is empty, return early
            List<Object> childrenAsList = (List<Object>) children;
            if (childrenAsList.isEmpty()) {
                return new List<Object>();
            }

            // For all children we want to evaluate the subexpression.
            // Each one of the children will now act as a standalone context for a new expression.
            Expr secondArgument = arguments.get(1);
            List<Object> result = new List<Object>();
            for (Integer i = 0; i < childrenAsList.size(); i++) {
                Object child = childrenAsList.get(i);
                Environment env;
                if (child instanceof SObject) {
                    env = new Environment((SObject)child);
                } else {
                    env = new Environment(null);
                }

                env.define('$current', child);
                env.define('$index', i);
                env.define('$total', childrenAsList.size());

                Interpreter interpreter = new Interpreter(env);
                Object evaluated = interpreter.interpret(secondArgument);
                if (evaluated instanceof Boolean) {
                    if ((Boolean) evaluated) {
                        result.add(child);
                    }
                } else {
                    throw new Interpreter.InterpreterException(
                        'Error executing "WHERE" function: the second argument must evaluate to a boolean.'
                    );
                }
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }
    }

    private class AverageFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfNumbers = evaluate(arguments.get(0));

            // Verify that all elements in the list are numbers
            if (!(listOfNumbers instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "AVERAGE" function: the argument must evaluate to a list of numbers.'
                );
            }

            List<Object> listOfNumbersAsList = (List<Object>) listOfNumbers;
            // Sanitize nulls
            List<Object> sanitizedList = new List<Object>();
            for (Object maybeNull : listOfNumbersAsList) {
                if (maybeNull != null) {
                    sanitizedList.add(maybeNull);
                }
            }
            for (Object maybeNumber : sanitizedList) {
                if (!(maybeNumber instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "AVERAGE" function: the argument must evaluate to a list of numbers.'
                    );
                }
            }

            // Calculate the average
            Decimal sum = 0;
            for (Object numberValue : sanitizedList) {
                sum += (Decimal) numberValue;
            }

            return sum / sanitizedList.size();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class SizeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfValues = evaluate(arguments.get(0));
            // Must be a list or a map
            if (!(listOfValues instanceof List<Object>) && !(listOfValues instanceof Map<Object, Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SIZE" function: the argument must evaluate to a list or a map.'
                );
            }

            if (listOfValues instanceof List<Object>) {
                return ((List<Object>) listOfValues).size();
            } else {
                return ((Map<Object, Object>) listOfValues).size();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class IsEmptyFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The argument must either be a list or a map
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof List<Object>) && !(value instanceof Map<Object, Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ISEMPTY" function: the argument must evaluate to a list or a map.'
                );
            }

            if (value instanceof List<Object>) {
                return ((List<Object>) value).isEmpty();
            } else {
                return ((Map<Object, Object>) value).isEmpty();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class AppendFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            Object item = evaluate(arguments.get(1));
            if (listObj == null) {
                listObj = new List<Object>();
            }
            if (!(listObj instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "APPEND" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> result = new List<Object>((List<Object>) listObj);
            result.add(item);
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class SortFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            if (listObj == null) {
                listObj = new List<Object>();
            }
            if (!(listObj instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SORT" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> result = new List<Object>((List<Object>) listObj);
            result.sort();
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class DistinctFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DISTINCT" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> result = new List<Object>((List<Object>) listObj);
            List<Object> distinct = new List<Object>();
            for (Object obj : result) {
                if (!distinct.contains(obj)) {
                    distinct.add(obj);
                }
            }
            return distinct;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class KeysFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object mapObj = evaluate(arguments.get(0));
            if (!(mapObj instanceof Map<Object, Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "KEYS" function: the first argument must evaluate to a map.'
                );
            }
            return new List<Object>(((Map<Object, Object>) mapObj).keySet());
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class GetFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object mapObj = evaluate(arguments.get(0));
            Object key = evaluate(arguments.get(1));
            if (!(mapObj instanceof Map<Object, Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "GET" function: the first argument must evaluate to a map.'
                );
            }
            return ((Map<Object, Object>) mapObj).get(key);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class ValuesFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object mapObj = evaluate(arguments.get(0));
            if (!(mapObj instanceof Map<Object, Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "VALUES" function: the first argument must evaluate to a map.'
                );
            }
            return ((Map<Object, Object>) mapObj).values();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }
}
