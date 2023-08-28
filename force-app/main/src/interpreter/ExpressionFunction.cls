public with sharing abstract class ExpressionFunction {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        // Logical
        'AND' => new LogicalFunctions.AndFn(),
        'IF' => new LogicalFunctions.IfFn(),
        'NOT' => new LogicalFunctions.NotFn(),
        'OR' => new LogicalFunctions.OrFn(),
        'BLANKVALUE' => new LogicalFunctions.BlankValue(),
        'ISBLANK' => new LogicalFunctions.IsBlank(),
        'ISNUMBER' => new LogicalFunctions.IsNumber(),
        'CASE' => new LogicalFunctions.CaseFn(),
        // String
        'BEGINS' => new StringFunctions.Begins(),
        'CONTAINS' => new StringFunctions.Contains(),
        'LOWER' => new StringFunctions.Lower(),
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
        'MAP' => new MapFn(),
        'AVERAGE' => new AverageFn(),
        'SIZE' => new SizeFn(),
        'UNIXTIMESTAMP' => new UnixTimeStampFn(),
        'WEEKDAY' => new WeekdayFn(),
        'HYPERLINK' => new HyperlinkFn(),
        'SUBSTITUTE' => new SubstituteFn(),
        'TEXT' => new TextFn(),
        'TRIM' => new TrimFn(),
        'UPPER' => new UpperFn(),
        'ISEMPTY' => new IsEmptyFn()
    };

    private enum TimeType {
        MILLISECOND, MINUTE, SECOND, HOUR_FN
    }

    private Interpreter interpreter;

    public void setInterpreter(Interpreter interpreter) {
        this.interpreter = interpreter;
    }

    abstract public Object call(List<Expr> arguments);

    protected Object evaluate(Expr expression) {
        return interpreter.interpret(expression);
    }

    protected Boolean isBoolean(Object single) {
        return single instanceof Boolean;
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
                if (item instanceof Interpreter.ListSpreadContents) {
                    result.addAll(((Interpreter.ListSpreadContents) item).contents);
                } else {
                    result.add(item);
                }
            }

            return result;
        }
    }

    private class MapFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            if (arguments.size() != 2) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MAP" function: the function must have exactly 2 arguments.'
                );
            }

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

    /**
     * @description Returns the day of the week for the given date,
     *              using 1 for Sunday, 2 for Monday, through 7 for Saturday.
     */
    private class WeekdayFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "WEEKDAY" function: the argument must evaluate to a date value.'
                );
            }

            Date dateObj = (Date) dateValue;

            return Integer.valueOf(Datetime.newInstanceGmt(
                dateObj.year(),
                dateObj.month(),
                dateObj.day(),
                0,
                0,
                0
            ).format('u'));
        }
    }

    /**
     * @description Creates a link to a URL specified that is linkable from the text specified.
     */
    private class HyperLinkFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expected arguments:
            // 1. Url
            // 2. Friendly text
            // 3. Option - target

            // Check that there is at least 2 arguments
            if (arguments.size() < 2) {
                throw new Interpreter.InterpreterException(
                    'Error executing "HYPERLINK" function: the function must have at least 2 arguments.'
                );
            }

            // Check that the first argument is a string
            Object url = evaluate(arguments.get(0));
            if (!(url instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "HYPERLINK" function: the first argument must evaluate to a string value.'
                );
            }

            // Check that the second argument is a string
            Object friendlyText = evaluate(arguments.get(1));
            if (!(friendlyText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "HYPERLINK" function: the second argument must evaluate to a string value.'
                );
            }

            // Check that the third argument is a string (if present)
            Object target = null;
            if (arguments.size() > 2) {
                target = evaluate(arguments.get(2));
                if (!(target instanceof String)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "HYPERLINK" function: the third argument must evaluate to a string value.'
                    );
                }
            }

            // Create the link
            String link = '<a href="' + (String) url + '"';
            if (target != null) {
                link += ' target="' + (String) target + '"';
            }
            link += '>' + (String) friendlyText + '</a>';

            return link;
        }
    }

    private class SubstituteFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expected arguments:
            // 1. text
            // 2. old text
            // 3. new text

            // Check that there is at least 3 arguments
            if (arguments.size() < 3) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the function must have at least 3 arguments.'
                );
            }

            // Check that the first argument is a string
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the first argument must evaluate to a string value.'
                );
            }

            // Check that the second argument is a string
            Object oldText = evaluate(arguments.get(1));
            if (!(oldText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the second argument must evaluate to a string value.'
                );
            }

            // Check that the third argument is a string
            Object newText = evaluate(arguments.get(2));
            if (!(newText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the third argument must evaluate to a string value.'
                );
            }

            // Replace all occurrences of the old text with the new text
            return ((String) text).replaceAll((String) oldText, (String) newText);
        }
    }

    private class TextFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TEXT" function: the function must have exactly 1 argument.'
                );
            }

            Object value = evaluate(arguments.get(0));
            if (value == null) {
                return '';
            }

            if (value instanceof Decimal) {
                return ((Decimal) value).format();
            } else if (value instanceof Date) {
                return ((Date) value).format();
            } else if (value instanceof Datetime) {
                return ((Datetime) value).format();
            } else if (value instanceof Boolean) {
                return ((Boolean) value) ? 'true' : 'false';
            } else if (value instanceof Time) {
                Time timeValue = (Time) value;
                Datetime dt = Datetime.newInstance(
                    1970,
                    1,
                    1,
                    timeValue.hour(),
                    timeValue.minute(),
                    timeValue.second()
                );
                return dt.format('hh:mm:ss a').replace(dt.date().format(), '').trim();
            } else {
                return String.valueOf(value);
            }
        }
    }

    private class TrimFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TRIM" function: the function must have exactly 1 argument.'
                );
            }

            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TRIM" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) value).trim();
        }
    }

    private class UpperFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "UPPER" function: the function must have exactly 1 argument.'
                );
            }

            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "UPPER" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) value).toUpperCase();
        }
    }

    private class IsEmptyFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "ISEMPTY" function: the function must have exactly 1 argument.'
                );
            }

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
    }
}
