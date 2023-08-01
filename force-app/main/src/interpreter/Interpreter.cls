public with sharing class Interpreter implements Visitor {
    public Object interpret(Expr expression) {
        return evaluate(expression);
    }

    private Object evaluate(Expr expr) {
        return expr.accept(this);
    }

    public Object visit(Expr.Binary binary) {
        Object left = evaluate(binary.left);
        Object right = evaluate(binary.right);

        switch on binary.operator.type {
            when PLUS {
                if (left instanceof Decimal && right instanceof Decimal) {
                    // Add numbers
                    return (Decimal) left + (Decimal) right;
                }
                if (left instanceof String && right instanceof String) {
                    // Concatenate strings
                    return (String) left + (String) right;
                }
                throw new InterpreterException(
                        'Error executing ' + binary.operator.lexeme + ' operator: operands must be numbers or strings.'
                );
            }
            when AMPERSAND {
                System.debug('found a solitary amp');
                if (left instanceof String && right instanceof String) {
                    // Concatenate strings
                    return (String) left + (String) right;
                }
                throw new InterpreterException(
                        'Error executing ' + binary.operator.lexeme + ' operator: operands must be strings.'
                );
            }
            when MINUS {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left - (Decimal) right;
            }
            when STAR {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left * (Decimal) right;
            }
            when SLASH {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left / (Decimal) right;
            }
            when EXPONENT {
                if (!checkIsDecimal(left) || !checkIsDecimal(right)) {
                    throw new InterpreterException(
                            'Error executing ' + binary.operator.lexeme + ' operator: the left operand must be a number and' +
                                    ' the right operand must be an integer, but found: left' + left + ' and right ' + right
                    );
                }

                // This can result in a runtime exception since right might not be an integer,
                // but any number
                return ((Decimal) left).pow(Integer.valueOf(right));
            }
            when GREATER {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left > (Decimal) right;
            }
            when GREATER_EQUAL {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left >= (Decimal) right;
            }
            when LESS {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left < (Decimal) right;
            }
            when LESS_EQUAL {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal) left <= (Decimal) right;
            }
            when EQUAL, EQUAL_EQUAL {
                return left == right;
            }
            when LESS_GREATER, BANG_EQUAL {
                return left != right;
            }
            when DOUBLE_AMPERSAND {
                if (!isBoolean(left)) {
                    throw new InterpreterException(
                            'Error executing ' + binary.operator.lexeme + ' operator: the left operand must evaluate to a boolean value.'
                    );
                }

                Boolean leftAsBoolean = (Boolean) left;

                if (leftAsBoolean) {
                    if (!isBoolean(right)) {
                        throw new InterpreterException(
                                'Error executing ' + binary.operator.lexeme + ' operator: the right operand must evaluate to a boolean value.'
                        );
                    }

                    return (Boolean) right;
                }

                return false;
            }
            when DOUBLE_PIPE {
                if (!isBoolean(left)) {
                    throw new InterpreterException(
                            'Error executing ' + binary.operator.lexeme + ' operator: the left operand must evaluate to a boolean value.'
                    );
                }

                Boolean leftAsBoolean = (Boolean) left;

                if (!leftAsBoolean) {
                    if (!isBoolean(right)) {
                        throw new InterpreterException(
                                'Error executing ' + binary.operator.lexeme + ' operator: the right operand must evaluate to a boolean value.'
                        );
                    }

                    return (Boolean) right;
                }

                return true;
            }
        }

        // Unreachable
        return null;
    }

    public Object visit(Expr.Grouping grouping) {
        return evaluate(grouping.expression);
    }

    public Object visit(Expr.Literal literal) {
        return literal.value;
    }

    public Object visit(Expr.Unary unary) {
        Object right = evaluate(unary.right);

        switch on (unary.operator.type) {
            when BANG {
                if (!isBoolean(right)) {
                    throw new InterpreterException(
                            'Error executing ' + unary.operator.lexeme + ' operator: the operand must evaluate to a boolean value.'
                    );
                }

                return !(Boolean) right;
            }
            when MINUS {
                if (!checkIsDecimal(right)) {
                    throw new InterpreterException(
                            'Error executing ' + unary.operator.lexeme + ' operator: the operand must be a number.'
                    );
                }

                return -(Decimal) right;
            }
        }

        // Unreachable
        return null;
    }

    public Object visit(Expr.Function function) {
        switch on function.name.type {
            when AND_FN {
                if (function.arguments.size() < 2) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: expected at least 2 arguments, but found ' + function.arguments.size()
                    );
                }

                // Loop through all arguments and return false if any of them is false
                for (Expr argument : function.arguments) {
                    Object evaluated = evaluate(argument);
                    if (!isBoolean(evaluated)) {
                        throw new InterpreterException(
                                'Error executing ' + function.name.lexeme + ' function: all arguments must evaluate to a boolean value.'
                        );
                    }

                    if (!(Boolean) evaluated) {
                        return false;
                    }
                }

                return true;
            }
            when IF_FN {
                // Evaluate the condition
                Object condition = evaluate(function.arguments.get(0));
                if (!isBoolean(condition)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the first argument must evaluate to a boolean value.'
                    );
                }

                // Evaluate the true branch
                if ((Boolean) condition) {
                    return evaluate(function.arguments.get(1));
                } else {
                    return evaluate(function.arguments.get(2));
                }
            }
        }

        // Unreachable
        return null;
    }

    private Boolean checkIsDecimal(Object single) {
        return single instanceof Decimal;
    }

    private Boolean isBoolean(Object single) {
        return single instanceof Boolean;
    }

    private void checkNumberOperand(Token operator, Object left, Object right) {
        if (left instanceof Decimal && right instanceof Decimal) return;
        throw new InterpreterException(
                'Error executing ' + operator.lexeme + ' operator: operands must be numbers.'
        );
    }

    public class InterpreterException extends Exception {
    }
}
