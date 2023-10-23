/**
 * @description Repository of functions that can be used in expressions.
 * @group Logical
 * @function-repository true
 * @display-icon utility:check
 */
public with sharing class LogicalFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'AND' => new LogicalFunctions.AndFn(),
        'IF' => new LogicalFunctions.IfFn(),
        'NOT' => new LogicalFunctions.NotFn(),
        'OR' => new LogicalFunctions.OrFn(),
        'BLANKVALUE' => new LogicalFunctions.BlankValue(),
        'ISBLANK' => new LogicalFunctions.IsBlank(),
        'ISNUMBER' => new LogicalFunctions.IsNumber(),
        'CASE' => new LogicalFunctions.CaseFn()
    };

    public class LogicalFunctionsProvider implements FunctionProvider {
        public String getCategory() {
            return 'Logical';
        }

        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }

        public String getIcon() {
            return 'utility:check';
        }
    }

    /**
     * @description Returns a TRUE response if all values are true; returns a FALSE response if one or more values are false.
     *
     * Accepts multiple arguments, but must have at least 2.
     * @function AND
     * @example
     * AND(true, false, true) // returns false
     */
    private class AndFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Loop through all arguments and return false if any of them is false
            for (Expr argument : arguments) {
                Object evaluated = evaluate(argument);
                if (!isBoolean(evaluated)) {
                    throw new FunctionExecutionException(
                        'Error executing "AND" function: all arguments must evaluate to a boolean value.'
                    );
                }

                if (!(Boolean) evaluated) {
                    return false;
                }
            }

            return true;
        }

        public override Arity getArity() {
            return Arity.atLeast(2);
        }
    }

    private class IfFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Evaluate the condition
            Object condition = evaluate(arguments.get(0));
            if (!isBoolean(condition)) {
                throw new FunctionExecutionException(
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

        public override Arity getArity() {
            return Arity.exactly(3);
        }
    }

    private class NotFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Evaluate the expression
            Object expression = evaluate(arguments.get(0));
            if (!isBoolean(expression)) {
                throw new FunctionExecutionException(
                    'Error executing "NOT" function: the argument must evaluate to a boolean value.'
                );
            }

            // Return the negated expression
            return !(Boolean) expression;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class OrFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Loop through all arguments and return true if any of them is true
            for (Expr argument : arguments) {
                Object evaluated = evaluate(argument);
                if (!isBoolean(evaluated)) {
                    throw new FunctionExecutionException(
                        'Error executing "OR" function: all arguments must evaluate to a boolean value.'
                    );
                }

                if ((Boolean) evaluated) {
                    return true;
                }
            }

            return false;
        }

        public override Arity getArity() {
            return Arity.atLeast(1);
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

            throw new FunctionExecutionException(
                'Error executing "BLANKVALUE" function: the first argument must evaluate to a string value.'
            );
        }

        public override Arity getArity() {
            return Arity.exactly(2);
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

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class IsNumber extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object value = evaluate(arguments.get(0));
            return value instanceof Decimal;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class CaseFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The first argument is the when expression
            Object whenExpression = evaluate(arguments.get(0));

            // Loop through argument pairs to get the match and the result pair
            for (Integer i = 1; i < arguments.size(); i += 2) {
                Object match = evaluate(arguments.get(i));
                if (match == whenExpression) {
                    return evaluate(arguments.get(i + 1));
                }
            }

            // If no match was found, return the else expression (the last argument)
            return evaluate(arguments.get(arguments.size() - 1));
        }

        public override Arity getArity() {
            return new AtLeastFourAndEvenArity();
        }
    }

    private class AtLeastFourAndEvenArity extends Arity {
        public AtLeastFourAndEvenArity() {
            super(4, null);
        }

        public override Boolean isSatisfiedBy(Integer argumentCount) {
            return argumentCount >= 4 && Math.mod(argumentCount, 2) == 0;
        }

        public override String toString() {
            return 'an even number with at least 4';
        }
    }
}
