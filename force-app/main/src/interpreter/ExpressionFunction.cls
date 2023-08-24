public with sharing abstract class ExpressionFunction {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'AND' => new AndFn(),
        'IF' => new IfFn(),
        'NOT' => new NotFn(),
        'OR' => new OrFn(),
        'BEGINS' => new Begins(),
        'CONTAINS' => new Contains(),
        'LOWER' => new Lower(),
        'BLANKVALUE' => new BlankValue(),
        'ISBLANK' => new IsBlank(),
        'ISNUMBER' => new IsNumber()
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

    private class NotFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Evaluate the expression
            Object expression = evaluate(arguments.get(0));
            if (!isBoolean(expression)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "NOT" function: the argument must evaluate to a boolean value.'
                );
            }

            // Return the negated expression
            return !(Boolean) expression;
        }
    }

    private class OrFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Loop through all arguments and return true if any of them is true
            for (Expr argument : arguments) {
                Object evaluated = evaluate(argument);
                if (!isBoolean(evaluated)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "OR" function: all arguments must evaluate to a boolean value.'
                    );
                }

                if ((Boolean) evaluated) {
                    return true;
                }
            }

            return false;
        }
    }

    private class Begins extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "BEGINS" function: the argument must evaluate to a string value.'
                );
            }

            Object prefix = evaluate(arguments.get(1));
            if (!(prefix instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "BEGINS" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).startsWith((String) prefix);
        }
    }

    private class Contains extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "CONTAINS" function: the argument must evaluate to a string value.'
                );
            }

            Object substring = evaluate(arguments.get(1));
            if (!(substring instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "CONTAINS function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).contains((String) substring);
        }
    }

    private class Lower extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LOWER" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).toLowerCase();
        }
    }

    private class BlankValue extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object value = evaluate(arguments.get(0));
            if (value == null) {
                return evaluate(arguments.get(1));
            }

            // Check if the value is a string
            if (value instanceof String) {
                // Check if the string is empty
                if (String.isBlank((String) value)) {
                    return evaluate(arguments.get(1));
                } else {
                    return value;
                }
            }

            throw new Interpreter.InterpreterException(
                'Error executing "BLANKVALUE" function: the first argument must evaluate to a string value.'
            );
        }
    }

    private class IsBlank extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object value = evaluate(arguments.get(0));
            if ((value instanceof String)) {
                return String.isBlank((String) value);
            }

            return value == null;
        }
    }

    private class IsNumber extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object value = evaluate(arguments.get(0));
            return value instanceof Decimal;
        }
    }
}
