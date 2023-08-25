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
        'ISNUMBER' => new IsNumber(),
        'CASE' => new CaseFn(),
        'FIND' => new FindFn(),
        'LEFT' => new LeftFn(),
        'LEN' => new LenFn(),
        'LPAD' => new LRPad('LPAD'),
        'RPAD' => new LRPad('RPAD'),
        'REVERSE' => new ReverseFn(),
        'MID' => new MidFn(),
        'SUBSTRING' => new SubstringFn(),
        'RIGHT' => new RightFn(),
        'BR' => new BrFn(),
        'ADDMONTHS' => new AddMonthsFn(),
        'DATE' => new DateFn(),
        'DAY' => new DayFn(),
        'DAYOFYEAR' => new DayOfYearFn(),
        'NOW' => new NowFn(),
        'DATEVALUE' => new DateValueFn(),
        'DATETIMEVALUE' => new DateTimeValueFn(),
        'TODAY' => new TodayFn(),
        'MILLISECOND' => new TimeFn('MILLISECOND', TimeType.MILLISECOND),
        'MINUTE' => new TimeFn('MINUTE', TimeType.MINUTE),
        'SECOND' => new TimeFn('SECOND', TimeType.SECOND),
        'HOUR' => new TimeFn('HOUR', TimeType.HOUR_FN),
        'TIMEVALUE' => new TimeValueFn(),
        'TIMENOW' => new TimeNowFn(),
        'ISOWEEK' => new IsoWeek(),
        'ISOYEAR' => new IsoYear(),
        'YEAR' => new YearFn(),
        'ABS' => new AbsFn(),
        'CEILING' => new CeilingFn(),
        'FLOOR' => new FloorFn(),
        'FROMUNIXTIME' => new FromUnixTimeFn(),
        'MAX' => new MaxMixFns('MAX'),
        'MIN' => new MaxMixFns('MIN'),
        'ROUND' => new RoundAndTruncFns('ROUND'),
        'TRUNC' => new RoundAndTruncFns('TRUNC'),
        'LIST' => new ListFn(),
        'TOLIST' => new ToListFn(),
        'AVERAGE' => new AverageFn(),
        'SIZE' => new SizeFn(),
        'UNIXTIMESTAMP' => new UnixTimeStampFn()
    };

    private enum TimeType {
        MILLISECOND, MINUTE, SECOND, HOUR_FN
    }

    private Interpreter interpreter;

    public void setInterpreter(Interpreter interpreter) {
        this.interpreter = interpreter;
    }

    abstract public Object call(List<Expr> arguments);

    private Object evaluate(Expr expression) {
        return interpreter.interpret(expression);
    }

    private static Boolean isBoolean(Object single) {
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

    private class CaseFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // At the very least 4 arguments must be and if more are received it must
            // be an even number
            if (arguments.size() < 4 || Math.mod(arguments.size(), 2) != 0) {
                throw new Interpreter.InterpreterException(
                    'Error executing "CASE" function: expected an even number of arguments, but found ' + arguments.size()
                );
            }

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
    }

    private class FindFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object searchText = evaluate(arguments.get(0));
            if (!(searchText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "FIND" function: the argument must evaluate to a string value.'
                );
            }

            Object text = evaluate(arguments.get(1));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "FIND" function: the argument must evaluate to a string value.'
                );
            }

            // There might be an optional third argument for the starting index, if there isn't one, it defaults to 0.
            Integer startIndex = 0;
            if (arguments.size() > 2) {
                Object startIndexValue = evaluate(arguments.get(2));
                if (!(startIndexValue instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "FIND" function: the argument must evaluate to a number value.'
                    );
                }
                startIndex = ((Decimal) startIndexValue).intValue();
            }

            return ((String) text).indexOf((String) searchText, startIndex);
        }
    }

    private class LeftFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LEFT" function: the argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LEFT" function: the argument must evaluate to a number value.'
                );
            }

            return ((String) text).substring(0, ((Decimal) length).intValue());
        }
    }

    private class LenFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LEN" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).length();
        }
    }

    private class LRPad extends ExpressionFunction {
        private final String name;

        public LRPad(String name) {
            this.name = name;
        }

        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + name + ' function: the first argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + name + ' function: the second argument must evaluate to a number value.'
                );
            }

            Object padString = ' ';
            if (arguments.size() > 2) {
                padString = evaluate(arguments.get(2));
                if (!(padString instanceof String)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing ' + name + ' function: the third argument must evaluate to a string value.'
                    );
                }
            }

            if (name == 'LPAD') {
                return ((String) padString).repeat(((Decimal) length).intValue() - ((String) text).length()) + (String) text;
            } else {
                return (String) text + ((String) padString).repeat(((Decimal) length).intValue() - ((String) text).length());
            }
        }
    }

    private class ReverseFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "REVERSE" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).reverse();
        }
    }

    private class MidFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MID" function: the first argument must evaluate to a string value.'
                );
            }

            Object start = evaluate(arguments.get(1));
            if (!(start instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MID" function: the second argument must evaluate to a number value.'
                );
            }

            Object length = evaluate(arguments.get(2));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MID" function: the third argument must evaluate to a number value.'
                );
            }

            return ((String) text).substring(((Decimal) start).intValue() - 1, ((Decimal) start).intValue() - 1 + ((Decimal) length).intValue());
        }
    }

    private class SubstringFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTRING" function: the first argument must evaluate to a string value.'
                );
            }

            Object start = evaluate(arguments.get(1));
            if (!(start instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTRING" function: the second argument must evaluate to a number value.'
                );
            }

            // Third argument is optional
            Object length = null;
            if (arguments.size() > 2) {
                length = evaluate(arguments.get(2));
                if (!(length instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "SUBSTRING" function: the third argument must evaluate to a number value.'
                    );
                }
            }

            if (length == null) {
                return ((String) text).substring(((Decimal) start).intValue() - 1);
            } else {
                return ((String) text).substring(((Decimal) start).intValue() - 1, ((Decimal) start).intValue() - 1 + ((Decimal) length).intValue());
            }
        }
    }

    private class RightFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "RIGHT: function: the first argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "RIGHT" function: the second argument must evaluate to a number value.'
                );
            }

            // If the number is less than 0, force it to 0
            Integer lengthAsInteger = ((Decimal) length).intValue();
            if (lengthAsInteger < 0) {
                lengthAsInteger = 0;
            }

            return ((String) text).right(lengthAsInteger);
        }
    }

    private class BrFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Integer linesToAdd = 1;
            // If an argument was passed, then it must be a number
            if (arguments.size() > 0) {
                Object linesToAddValue = evaluate(arguments.get(0));
                if (!(linesToAddValue instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "BR" function: the argument must evaluate to a number value.'
                    );
                }
                linesToAdd = ((Decimal) linesToAddValue).intValue();
            }

            if (Request.getCurrent().getQuiddity() == Quiddity.AURA || Request.getCurrent().getQuiddity() == Quiddity.VF) {
                return '<br/>'.repeat(linesToAdd);
            }
            return '\n'.repeat(linesToAdd);
        }
    }

    private class AddMonthsFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object startMonth = evaluate(arguments.get(0));
            if (!(startMonth instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ADDMONTHS" function: the argument must evaluate to a date value.'
                );
            }

            Object monthsToAdd = evaluate(arguments.get(1));
            if (!(monthsToAdd instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ADDMONTHS" function: the argument must evaluate to a number value.'
                );
            }

            return ((Date) startMonth).addMonths(((Decimal) monthsToAdd).intValue());
        }
    }

    private class DateFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object year = evaluate(arguments.get(0));
            if (!(year instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DATE" function: the argument must evaluate to a number value.'
                );
            }
            Object month = evaluate(arguments.get(1));
            if (!(month instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DATE"" function: the argument must evaluate to a number value.'
                );
            }
            Object day = evaluate(arguments.get(2));
            if (!(day instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DATE" function: the argument must evaluate to a number value.'
                );
            }

            return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        }
    }

    private class DayFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DAY" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).day();
        }
    }

    private class DayOfYearFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DAYOFYEAR" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).dayOfYear();
        }
    }

    private class NowFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            return Datetime.now();
        }
    }

    private class DateValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect the expression to either be a text or a datetime
            Object expression = evaluate(arguments.get(0));
            if (!(expression instanceof String) && !(expression instanceof Datetime)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DATEVALUE" function: the argument must evaluate to a string or datetime value.'
                );
            }

            if (expression instanceof String) {
                return Date.valueOf((String) expression);
            } else {
                return ((Datetime) expression).date();
            }
        }
    }

    private class DateTimeValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object expression = evaluate(arguments.get(0));
            if (!(expression instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "DATETIMEVALUE" function: the argument must evaluate to a string value.'
                );
            }

            return Datetime.valueOf((String) expression);
        }
    }

    private class TodayFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            return Date.today();
        }
    }

    private class TimeFn extends ExpressionFunction {
        private final String fnName;
        private final TimeType type;

        public TimeFn(String fnName, TimeType type) {
            this.fnName = fnName;
            this.type = type;
        }

        public override Object call(List<Expr> arguments) {
            Object timeValue = evaluate(arguments.get(0));
            if (!(timeValue instanceof Time)) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + fnName + ' function: the argument must evaluate to a time value.'
                );
            }

            if (type == TimeType.MILLISECOND) {
                return ((Time) timeValue).millisecond();
            } else if (type == TimeType.MINUTE) {
                return ((Time) timeValue).minute();
            } else if (type == TimeType.SECOND) {
                return ((Time) timeValue).second();
            } else {
                return ((Time) timeValue).hour();
            }
        }
    }

    private class TimeValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateTimeOrText = evaluate(arguments.get(0));
            if (!(dateTimeOrText instanceof String) && !(dateTimeOrText instanceof Datetime)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TIMEVALUE" function: the argument must evaluate to a string or datetime value.'
                );
            }

            if (dateTimeOrText instanceof String) {
                // A received string should be in the format of HH:mm:ss.SSS
                String[] parts = ((String) dateTimeOrText).split(':');
                if (parts.size() != 3) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "TIMEVALUE" function: the argument must evaluate to a string in the format of HH:mm:ss.SSS.'
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
    }

    private class TimeNowFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            return Datetime.now().time();
        }
    }

    private class IsoWeek extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ISOWEEK" function: the argument must evaluate to a date value.'
                );
            }

            return Integer.valueOf(Datetime.newInstanceGmt((Date) dateValue, Time.newInstance(0, 0, 0, 0)).format('w'));
        }
    }

    private class IsoYear extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ISOYEAR" function: the argument must evaluate to a date value.'
                );
            }

            return Integer.valueOf(Datetime.newInstanceGmt((Date) dateValue, Time.newInstance(0, 0, 0, 0)).format('Y'));
        }
    }

    private class YearFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "YEAR" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).year();
        }
    }

    private class AbsFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ABS" function: the argument must evaluate to a number value.'
                );
            }

            return Math.abs((Decimal) numberValue);
        }
    }

    private class CeilingFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "CEILING" function: the argument must evaluate to a number value.'
                );
            }

            return Math.ceil((Decimal) numberValue);
        }
    }

    private class FloorFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "FLOOR" function: the argument must evaluate to a number value.'
                );
            }

            return Math.floor((Decimal) numberValue);
        }
    }

    private class FromUnixTimeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object unixTime = evaluate(arguments.get(0));
            if (!(unixTime instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "FROMUNIXTIME" function: the argument must evaluate to a number value.'
                );
            }

            Long timeStamp = ((Decimal) unixTime).longValue() * 1000;
            Datetime gmtDatetime = Datetime.newInstance(timeStamp);
            return gmtDatetime;
        }
    }

    private class MaxMixFns extends ExpressionFunction {
        private final String name;

        public MaxMixFns(String name) {
            this.name = name;
        }

        public override Object call(List<Expr> arguments) {
            if (arguments.isEmpty()) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + name + ' function: the function must have at least one argument.'
                );
            }

            List<Object> values = new List<Object>();

            // If the first argument is a list then only one argument is expected
            Object firstArgument = evaluate(arguments.get(0));
            if (firstArgument instanceof List<Object>) {
                if (arguments.size() > 1) {
                    throw new Interpreter.InterpreterException(
                        'Error executing ' + name + ' function: the function must have at most one argument when the first argument is a list.'
                    );
                }

                values = (List<Object>) firstArgument;
            } else {
                values.add(firstArgument);

                for (Integer i = 1; i < arguments.size(); i++) {
                    values.add(evaluate(arguments.get(i)));
                }
            }

            Decimal result = null;
            for (Object value : values) {
                if (!(value instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing ' + name + ' function: the value ' + value + ' is not a number.'
                    );
                }

                if (result == null) {
                    result = (Decimal) value;
                } else {
                    if (name == 'MAX') {
                        result = Math.max(result, (Decimal) value);
                    } else {
                        result = Math.min(result, (Decimal) value);
                    }
                }
            }
            return result;
        }
    }

    private class RoundAndTruncFns extends ExpressionFunction {
        private final String name;

        public RoundAndTruncFns(String name) {
            this.name = name;
        }

        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + name + ' function: the argument must evaluate to a number value.'
                );
            }

            Decimal precision = 0;
            if (arguments.size() > 1) {
                Object precisionValue = evaluate(arguments.get(1));
                if (!(precisionValue instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing ' + name + ' function: the second argument must evaluate to a number value.'
                    );
                }
                precision = (Decimal) precisionValue;
            }

            if (name == 'ROUND') {
                return ((Decimal) numberValue).setScale(precision.intValue(), RoundingMode.HALF_UP);
            } else {
                return ((Decimal) numberValue).setScale(precision.intValue(), RoundingMode.DOWN);
            }
        }
    }

    private class ListFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Check that there is at least one argument
            if (arguments.isEmpty()) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LIST" function: the function must have at least one argument.'
                );
            }

            interpreter.setIsInListLiteral(true);

            List<Object> result = new List<Object>();
            for (Expr argument : arguments) {
                Object item = evaluate(argument);
                if (item instanceof Interpreter.SpreadContents) {
                    result.addAll(((Interpreter.SpreadContents) item).contents);
                } else {
                    result.add(item);
                }
            }

            return result;
        }
    }

    private class ToListFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 2 arguments, the first will be the name of the child relationship field,
            // the second the name of the fields for which we want the data
            if (arguments.size() != 2) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TOLIST" function: the function must have exactly 2 arguments.'
                );
            }

            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof List<SObject>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TOLIST" function: the first argument must evaluate to a list of SObject.'
                );
            }

            // If the list of children is empty, return early
            List<SObject> childrenAsList = (List<SObject>) children;
            if (childrenAsList.isEmpty()) {
                return new List<Object>();
            }

            // For all children we want to get the value of the field
            // Each one of the children will now act as a standalone context for a new expression
            if (!(arguments.get(1) instanceof Expr.MergeField)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TOLIST" function: the second argument must be a merge field.'
                );
            }

            String secondArgument = ((Expr.MergeField) arguments.get(1)).name.lexeme;
            List<Object> result = new List<Object>();
            for (SObject child : childrenAsList) {
                result.add(Evaluator.run(secondArgument, child));
            }
            return result;
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
    }

    private class SizeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfValues = evaluate(arguments.get(0));
            if (!(listOfValues instanceof List<Object>)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SIZE" function: the argument must evaluate to a list.'
                );
            }

            return ((List<Object>) listOfValues).size();
        }
    }

    /**
     * @description Returns the number of seconds since 1 Jan 1970 for the given date or datetime,
     *              or number of seconds in the day for a time.
     */
    private class UnixTimeStampFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateOrDateTimeOrTime = evaluate(arguments.get(0));
            if (!(dateOrDateTimeOrTime instanceof Date) && !(dateOrDateTimeOrTime instanceof Datetime) && !(dateOrDateTimeOrTime instanceof Time)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "UNIXTIMESTAMP" function: the argument must evaluate to a date, datetime or time value.'
                );
            }

            if (dateOrDateTimeOrTime instanceof Date) {
                // Convert to datetime first
                Datetime gmtDatetime = Datetime.newInstanceGmt((Date) dateOrDateTimeOrTime, Time.newInstance(0, 0, 0, 0));
                return gmtDatetime.getTime() / 1000;
            } else if (dateOrDateTimeOrTime instanceof Datetime) {
                Datetime gmtDateTime = Datetime.newInstanceGmt(((Datetime) dateOrDateTimeOrTime).date(), ((Datetime) dateOrDateTimeOrTime).time());
                return gmtDateTime.getTime() / 1000;
            } else {
                // Calculate the number of seconds in the day for a given time
                return ((Time) dateOrDateTimeOrTime).hour() * 3600 + ((Time) dateOrDateTimeOrTime).minute() * 60 + ((Time) dateOrDateTimeOrTime).second();
            }
        }
    }
}
