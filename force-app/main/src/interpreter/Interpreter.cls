public with sharing class Interpreter implements Visitor {
    private Environment env;

    public Interpreter(Environment env) {
        this.env = env;
    }

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

    public Object visit(Expr.GetExpr getExpr) {
        if (env == null) {
            throw new InterpreterException(
                'Error executing get expression: no context was provided.'
            );
        }

        Object result = evaluate(getExpr.objectExpr);
        if (result instanceof SObject) {
            Environment tempEnvironmentForGet = new Environment((SObject) result);

            // We might be dealing with either a field reference or with a reference to another parent
            if (tempEnvironmentForGet.containsField(getExpr.name.lexeme)) {
                return tempEnvironmentForGet.get(getExpr.name.lexeme);
            } else if (tempEnvironmentForGet.containsAsParent(getExpr.name.lexeme)) {
                return tempEnvironmentForGet.getParentSObject(getExpr.name.lexeme);
            }

            throw new InterpreterException(
                'Error executing get expression: the SObject type ' +
                    tempEnvironmentForGet.getSObjectTypeName() +
                    ' does not contain a field with the name' + getExpr.name.lexeme
            );
        }
        throw new InterpreterException(
            'Error executing get expression: the object expression must evaluate to an SObject.'
        );
    }

    public Object visit(Expr.MergeField mergeField) {
        if (env == null) {
            throw new InterpreterException(
                'Error executing merge field' + mergeField.name.lexeme + ': no context was provided.'
            );
        }

        if (!env.containsField(mergeField.name.lexeme)) {
            if (env.containsAsParent(mergeField.name.lexeme)) {
                return env.getParentSObject(mergeField.name.lexeme);
            }

            throw new InterpreterException(
                'Error executing merge field: ' +
                    mergeField.name.lexeme +
                    ' The SObject type ' +
                    env.getSObjectTypeName() +
                    ' does not contain a field with that name.'
            );
        }

        return env.get(mergeField.name.lexeme);
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

    public Object visit(Expr.Function function) {
        // Check if the function is in the list of supported functions
        if (!ExpressionFunction.FUNCTIONS.containsKey(function.functionName)) {
            throw new InterpreterException(
                'Error executing ' + function.functionName + ' function: the function is not supported.'
            );
        }

        ExpressionFunction fn = ExpressionFunction.FUNCTIONS.get(function.functionName);
        fn.setInterpreter(this);
        return fn.call(function.arguments);
    }
}
