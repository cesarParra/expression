public with sharing abstract class ExpressionFunction {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction> {
        'AND' => new AndFn(),
        'IF' => new IfFn()
    };

    private Interpreter interpreter;

    public void setInterpreter(Interpreter interpreter) {
        this.interpreter = interpreter;
    }

    abstract public Object call(List<Expr> arguments);

    private Object evaluate(Expr expression) {
        return interpreter.interpret(expression);
    }

    private Boolean isBoolean(Object single) {
        return single instanceof Boolean;
    }

    private class AndFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            if (arguments.size() < 2) {
                throw new Interpreter.InterpreterException(
                    'Error executing "AND" function: expected at least 2 arguments, but found ' + arguments.size()
                );
            }

            // Loop through all arguments and return false if any of them is false
            for (Expr argument : arguments) {
                Object evaluated = evaluate(argument);
                if (!isBoolean(evaluated)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "AND" function: all arguments must evaluate to a boolean value.'
                    );
                }

                if (!(Boolean) evaluated) {
                    return false;
                }
            }

            return true;
        }
    }

    private class IfFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Evaluate the condition
            Object condition = evaluate(arguments.get(0));
            if (!isBoolean(condition)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "IF" function: the first argument must evaluate to a boolean value.'
                );
            }

            if ((Boolean) condition) {
                // Left
                return evaluate(arguments.get(1));
            } else {
                // Right
                return evaluate(arguments.get(2));
            }
        }
    }
}
