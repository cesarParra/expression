public with sharing class Interpreter implements Visitor {
    private final SObject context;

    public Interpreter(SObject context) {
        this.context = context;
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

    public Object visit(Expr.MergeField mergeField) {
        if (context == null) {
            throw new InterpreterException(
                    'Error executing merge field' + mergeField.name.lexeme + ': no context was provided.'
            );
        }

        Set<String> fields = context.getSObjectType().getDescribe().fields.getMap().keySet();
        if (!fields.contains(mergeField.name.lexeme.toLowerCase())) {
            throw new InterpreterException(
                    'Error executing merge field: ' +
                            mergeField.name.lexeme +
                            ' The SObject type ' +
                            context.getSObjectType().getDescribe().getName() +
                            ' does not contain a field with that name.'
            );
        }

        return context.get(mergeField.name.lexeme);
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

                if ((Boolean) condition) {
                    // Left
                    return evaluate(function.arguments.get(1));
                } else {
                    // Right
                    return evaluate(function.arguments.get(2));
                }
            }
            when NOT_FN {
                // Evaluate the expression
                Object expression = evaluate(function.arguments.get(0));
                if (!isBoolean(expression)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a boolean value.'
                    );
                }

                // Return the negated expression
                return !(Boolean) expression;
            }
            when OR_FN {
                // Loop through all arguments and return true if any of them is true
                for (Expr argument : function.arguments) {
                    Object evaluated = evaluate(argument);
                    if (!isBoolean(evaluated)) {
                        throw new InterpreterException(
                                'Error executing ' + function.name.lexeme + ' function: all arguments must evaluate to a boolean value.'
                        );
                    }

                    if ((Boolean) evaluated) {
                        return true;
                    }
                }

                return false;
            }
            when BEGINS_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                Object prefix = evaluate(function.arguments.get(1));
                if (!(prefix instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                return ((String) text).startsWith((String) prefix);
            }
            when CONTAINS_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                Object substring = evaluate(function.arguments.get(1));
                if (!(substring instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                return ((String) text).contains((String) substring);
            }
            when LOWER_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                return ((String) text).toLowerCase();
            }
            when DATE_FN {
                Object year = evaluate(function.arguments.get(0));
                if (!(year instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }
                Object month = evaluate(function.arguments.get(1));
                if (!(month instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }
                Object day = evaluate(function.arguments.get(2));
                if (!(day instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
            }
            when ABS_FN {
                Object numberValue = evaluate(function.arguments.get(0));
                if (!(numberValue instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                return Math.abs((Decimal) numberValue);
            }
            when FIND_FN {
                Object searchText = evaluate(function.arguments.get(0));
                if (!(searchText instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                Object text = evaluate(function.arguments.get(1));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                // There might be an optional third argument for the starting index, if there isn't one, it defaults to 0.
                Integer startIndex = 0;
                if (function.arguments.size() > 2) {
                    Object startIndexValue = evaluate(function.arguments.get(2));
                    if (!(startIndexValue instanceof Decimal)) {
                        throw new InterpreterException(
                                'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                        );
                    }
                    startIndex = ((Decimal) startIndexValue).intValue();
                }

                return ((String) text).indexOf((String) searchText, startIndex);
            }
            when ADDMONTHS_FN {
                Object startMonth = evaluate(function.arguments.get(0));
                if (!(startMonth instanceof Date)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a date value.'
                    );
                }

                Object monthsToAdd = evaluate(function.arguments.get(1));
                if (!(monthsToAdd instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                return ((Date) startMonth).addMonths(((Decimal) monthsToAdd).intValue());
            }
            when BLANKVALUE_FN {
                Object value = evaluate(function.arguments.get(0));
                if (value == null) {
                    return evaluate(function.arguments.get(1));
                }

                // Check if the value is a string
                if (value instanceof String) {
                    // Check if the string is empty
                    if (String.isBlank((String) value)) {
                        return evaluate(function.arguments.get(1));
                    } else {
                        return value;
                    }
                }
            }
            when CEILING_FN {
                Object numberValue = evaluate(function.arguments.get(0));
                if (!(numberValue instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                return Math.ceil((Decimal) numberValue);
            }
            when LEFT_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                Object length = evaluate(function.arguments.get(1));
                if (!(length instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                return ((String) text).substring(0, ((Decimal) length).intValue());
            }
            when DAY_FN {
                Object dateValue = evaluate(function.arguments.get(0));
                if (!(dateValue instanceof Date)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a date value.'
                    );
                }

                return ((Date) dateValue).day();
            }
            when ISBLANK_FN {
                Object value = evaluate(function.arguments.get(0));
                if ((value instanceof String)) {
                    return String.isBlank((String) value);
                }

                return value == null;
            }
            when FLOOR_FN {
                Object numberValue = evaluate(function.arguments.get(0));
                if (!(numberValue instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                return Math.floor((Decimal) numberValue);
            }
            when LEN_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                return ((String) text).length();
            }
            when DAYOFYEAR_FN {
                Object dateValue = evaluate(function.arguments.get(0));
                if (!(dateValue instanceof Date)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a date value.'
                    );
                }

                return ((Date) dateValue).dayOfYear();
            }
            when FROMUNIXTIME_FN {
                Object unixTime = evaluate(function.arguments.get(0));
                if (!(unixTime instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                Long timeStamp = ((Decimal) unixTime).longValue() * 1000;
                Datetime gmtDatetime = Datetime.newInstance(timeStamp);
                return gmtDatetime;
            }
            when LPAD_FN, RPAD_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the first argument must evaluate to a string value.'
                    );
                }

                Object length = evaluate(function.arguments.get(1));
                if (!(length instanceof Decimal)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the second argument must evaluate to a number value.'
                    );
                }

                Object padString = ' ';
                if (function.arguments.size() > 2) {
                    padString = evaluate(function.arguments.get(2));
                    if (!(padString instanceof String)) {
                        throw new InterpreterException(
                                'Error executing ' + function.name.lexeme + ' function: the third argument must evaluate to a string value.'
                        );
                    }
                }

                if (function.name.type == TokenType.LPAD_FN) {
                    return ((String) padString).repeat(((Decimal) length).intValue() - ((String) text).length()) + (String) text;
                } else {
                    return (String) text + ((String) padString).repeat(((Decimal) length).intValue() - ((String) text).length());
                }
            }
            when NOW_FN {
                return Datetime.now();
            }
            when DATEVALUE_FN {
                // Expect the expression to either be a text or a datetime
                Object expression = evaluate(function.arguments.get(0));
                if (!(expression instanceof String) && !(expression instanceof Datetime)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string or datetime value.'
                    );
                }

                if (expression instanceof String) {
                    return Date.valueOf((String) expression);
                } else {
                    return ((Datetime) expression).date();
                }
            }
            when DATETIMEVALUE_FN {
                Object expression = evaluate(function.arguments.get(0));
                if (!(expression instanceof String)) {
                    throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                return Datetime.valueOf((String) expression);
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
