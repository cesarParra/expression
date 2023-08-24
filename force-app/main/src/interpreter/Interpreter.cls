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

    public Object visit(Expr.Function function) {
        switch on function.name.type {
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
            when TODAY_FN {
                return Date.today();
            }
            when MAX_FN, MIN_FN {
                if (function.arguments.isEmpty()) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the function must have at least one argument.'
                    );
                }

                List<Object> values = new List<Object>();

                // If the first argument is a list then only one argument is expected
                Object firstArgument = evaluate(function.arguments.get(0));
                if (firstArgument instanceof List<Object>) {
                    if (function.arguments.size() > 1) {
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the function must have at most one argument when the first argument is a list.'
                        );
                    }

                    values = (List<Object>) firstArgument;
                } else {
                    values.add(firstArgument);

                    for (Integer i = 1; i < function.arguments.size(); i++) {
                        values.add(evaluate(function.arguments.get(i)));
                    }
                }

                Decimal result = null;
                for (Object value : values) {
                    if (!(value instanceof Decimal)) {
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the value ' + value + ' is not a number.'
                        );
                    }

                    if (result == null) {
                        result = (Decimal) value;
                    } else {
                        if (function.name.type == TokenType.MAX_FN) {
                            result = Math.max(result, (Decimal) value);
                        } else {
                            result = Math.min(result, (Decimal) value);
                        }
                    }
                }
                return result;
            }
            when REVERSE_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string value.'
                    );
                }

                return ((String) text).reverse();
            }
            when ROUND_FN, TRUNC_FN {
                Object numberValue = evaluate(function.arguments.get(0));
                if (!(numberValue instanceof Decimal)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                    );
                }

                Decimal precision = 0;
                if (function.arguments.size() > 1) {
                    Object precisionValue = evaluate(function.arguments.get(1));
                    if (!(precisionValue instanceof Decimal)) {
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the second argument must evaluate to a number value.'
                        );
                    }
                    precision = (Decimal) precisionValue;
                }

                if (function.name.type == TokenType.ROUND_FN) {
                    return ((Decimal) numberValue).setScale(precision.intValue(), RoundingMode.HALF_UP);
                } else {
                    return ((Decimal) numberValue).setScale(precision.intValue(), RoundingMode.DOWN);
                }
            }
            when TIMEVALUE_FN {
                Object dateTimeOrText = evaluate(function.arguments.get(0));
                if (!(dateTimeOrText instanceof String) && !(dateTimeOrText instanceof Datetime)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string or datetime value.'
                    );
                }

                if (dateTimeOrText instanceof String) {
                    // A received string should be in the format of HH:mm:ss.SSS
                    String[] parts = ((String) dateTimeOrText).split(':');
                    if (parts.size() != 3) {
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a string in the format of HH:mm:ss.SSS.'
                        );
                    }

                    Integer hours = Integer.valueOf(parts[0]);
                    Integer minutes = Integer.valueOf(parts[1]);

                    String secondsMilli = parts[2];

                    if (secondsMilli.contains('.')) {
                        String[] secondsMilliParts = secondsMilli.split('\\.');
                        Integer seconds = Integer.valueOf(secondsMilliParts[0]);
                        Integer milliseconds = Integer.valueOf(secondsMilliParts[1]);
                        return Time.newInstance(hours, minutes, seconds, milliseconds);
                    } else {
                        Integer seconds = Integer.valueOf(secondsMilli);
                        return Time.newInstance(hours, minutes, seconds, 0);
                    }
                } else {
                    return ((Datetime) dateTimeOrText).time();
                }
            }
            when MID_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the first argument must evaluate to a string value.'
                    );
                }

                Object start = evaluate(function.arguments.get(1));
                if (!(start instanceof Decimal)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the second argument must evaluate to a number value.'
                    );
                }

                Object length = evaluate(function.arguments.get(2));
                if (!(length instanceof Decimal)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the third argument must evaluate to a number value.'
                    );
                }

                return ((String) text).substring(((Decimal) start).intValue() - 1, ((Decimal) start).intValue() - 1 + ((Decimal) length).intValue());
            }
            when SUBSTRING_FN {
                Object text = evaluate(function.arguments.get(0));
                if (!(text instanceof String)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the first argument must evaluate to a string value.'
                    );
                }

                Object start = evaluate(function.arguments.get(1));
                if (!(start instanceof Decimal)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the second argument must evaluate to a number value.'
                    );
                }

                // Third argument is optional
                Object length = null;
                if (function.arguments.size() > 2) {
                    length = evaluate(function.arguments.get(2));
                    if (!(length instanceof Decimal)) {
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the third argument must evaluate to a number value.'
                        );
                    }
                }

                if (length == null) {
                    return ((String) text).substring(((Decimal) start).intValue() - 1);
                } else {
                    return ((String) text).substring(((Decimal) start).intValue() - 1, ((Decimal) start).intValue() - 1 + ((Decimal) length).intValue());
                }
            }
            when TIMENOW_FN {
                return Datetime.now().time();
            }
            when ISOWEEK_FN {
                Object dateValue = evaluate(function.arguments.get(0));
                if (!(dateValue instanceof Date)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a date value.'
                    );
                }

                return Integer.valueOf(Datetime.newInstanceGmt((Date) dateValue, Time.newInstance(0, 0, 0, 0)).format('w'));
            }
            when RIGHT_FN {
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

                // If the number is less than 0, force it to 0
                Integer lengthAsInteger = ((Decimal) length).intValue();
                if (lengthAsInteger < 0) {
                    lengthAsInteger = 0;
                }

                return ((String) text).right(lengthAsInteger);
            }
            when ISOYEAR_FN {
                Object dateValue = evaluate(function.arguments.get(0));
                if (!(dateValue instanceof Date)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a date value.'
                    );
                }

                return Integer.valueOf(Datetime.newInstanceGmt((Date) dateValue, Time.newInstance(0, 0, 0, 0)).format('Y'));
            }
            when YEAR_FN {
                Object dateValue = evaluate(function.arguments.get(0));
                if (!(dateValue instanceof Date)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a date value.'
                    );
                }

                return ((Date) dateValue).year();
            }
            when MILLISECOND_FN, MINUTE_FN, SECOND_FN, HOUR_FN {
                Object timeValue = evaluate(function.arguments.get(0));
                if (!(timeValue instanceof Time)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a time value.'
                    );
                }

                if (function.name.type == TokenType.MILLISECOND_FN) {
                    return ((Time) timeValue).millisecond();
                } else if (function.name.type == TokenType.MINUTE_FN) {
                    return ((Time) timeValue).minute();
                } else if (function.name.type == TokenType.SECOND_FN) {
                    return ((Time) timeValue).second();
                } else {
                    return ((Time) timeValue).hour();
                }
            }
            when LIST_FN {
                // Check that there is at least one argument
                if (function.arguments.isEmpty()) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the function must have at least one argument.'
                    );
                }

                List<Object> result = new List<Object>();
                for (Expr argument : function.arguments) {
                    result.add(evaluate(argument));
                }

                return result;
            }
            when TOLIST_FN {
                // Expect 2 arguments, the first will be the name of the child relationship field,
                // the second the name of the fields for which we want the data
                if (function.arguments.size() != 2) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the function must have exactly 2 arguments.'
                    );
                }

                Object children = evaluate(function.arguments.get(0));
                if (children == null) {
                    return new List<Object>();
                }
                if (!(children instanceof List<SObject>)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the first argument must evaluate to a list of SObject.'
                    );
                }

                // If the list of children is empty, return early
                List<SObject> childrenAsList = (List<SObject>) children;
                if (childrenAsList.isEmpty()) {
                    return new List<Object>();
                }

                // For all children we want to get the value of the field
                // Each one of the children will now act as a standalone context for a new expression
                if (!(function.arguments.get(1) instanceof Expr.MergeField)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the second argument must be a merge field.'
                    );
                }

                String secondArgument = ((Expr.MergeField) function.arguments.get(1)).name.lexeme;
                List<Object> result = new List<Object>();
                for (SObject child : childrenAsList) {
                    result.add(Evaluator.run(secondArgument, child));
                }
                return result;
            }
            when AVERAGE_FN {
                Object listOfNumbers = evaluate(function.arguments.get(0));

                // Verify that all elements in the list are numbers
                if (!(listOfNumbers instanceof List<Object>)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a list of numbers.'
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
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a list of numbers.'
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
            when BR_FN {
                Integer linesToAdd = 1;
                // If an argument was passed, then it must be a number
                if (function.arguments.size() > 0) {
                    Object linesToAddValue = evaluate(function.arguments.get(0));
                    if (!(linesToAddValue instanceof Decimal)) {
                        throw new InterpreterException(
                            'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a number value.'
                        );
                    }
                    linesToAdd = ((Decimal) linesToAddValue).intValue();
                }

                if (Request.getCurrent().getQuiddity() == Quiddity.AURA || Request.getCurrent().getQuiddity() == Quiddity.VF) {
                    return '<br/>'.repeat(linesToAdd);
                }
                return '\n'.repeat(linesToAdd);
            }
            when SIZE_FN {
                Object listOfValues = evaluate(function.arguments.get(0));
                if (!(listOfValues instanceof List<Object>)) {
                    throw new InterpreterException(
                        'Error executing ' + function.name.lexeme + ' function: the argument must evaluate to a list.'
                    );
                }

                return ((List<Object>) listOfValues).size();
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

    public Object visit(Expr.CallableFunction function) {
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
