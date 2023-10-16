public with sharing class DateAndTimeFunctions {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'ADDMONTHS' => new DateAndTimeFunctions.AddMonthsFn(),
        'DATE' => new DateAndTimeFunctions.DateFn(),
        'DAY' => new DateAndTimeFunctions.DayFn(),
        'DAYOFYEAR' => new DateAndTimeFunctions.DayOfYearFn(),
        'NOW' => new DateAndTimeFunctions.NowFn(),
        'DATEVALUE' => new DateAndTimeFunctions.DateValueFn(),
        'DATETIMEVALUE' => new DateAndTimeFunctions.DateTimeValueFn(),
        'TODAY' => new DateAndTimeFunctions.TodayFn(),
        'MILLISECOND' => new DateAndTimeFunctions.TimeFn('MILLISECOND', TimeType.MILLISECOND),
        'MINUTE' => new DateAndTimeFunctions.TimeFn('MINUTE', TimeType.MINUTE),
        'SECOND' => new DateAndTimeFunctions.TimeFn('SECOND', TimeType.SECOND),
        'HOUR' => new DateAndTimeFunctions.TimeFn('HOUR', TimeType.HOUR_FN),
        'TIMEVALUE' => new DateAndTimeFunctions.TimeValueFn(),
        'TIMENOW' => new DateAndTimeFunctions.TimeNowFn(),
        'ISOWEEK' => new DateAndTimeFunctions.IsoWeek(),
        'ISOYEAR' => new DateAndTimeFunctions.IsoYear(),
        'YEAR' => new DateAndTimeFunctions.YearFn(),
        'FROMUNIXTIME' => new DateAndTimeFunctions.FromUnixTimeFn(),
        'UNIXTIMESTAMP' => new UnixTimeStampFn(),
        'WEEKDAY' => new WeekdayFn(),
        'FORMATDURATION' => new FormatDuration(),
        'MONTH' => new MonthFn(),
        'DATETIMEFORMAT' => new DateTimeFormatFn(),
        'DATETODATETIME' => new DateToDateTimeFn(),
        'DAYSBETWEEN' => new DaysBetween()
    };

    private enum TimeType {
        MILLISECOND, MINUTE, SECOND, HOUR_FN
    }

    private class AddMonthsFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object startMonth = evaluate(arguments.get(0));
            if (!(startMonth instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "ADDMONTHS" function: the argument must evaluate to a date value.'
                );
            }

            Object monthsToAdd = evaluate(arguments.get(1));
            if (!(monthsToAdd instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "ADDMONTHS" function: the argument must evaluate to a number value.'
                );
            }

            return ((Date) startMonth).addMonths(((Decimal) monthsToAdd).intValue());
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class DateFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object year = evaluate(arguments.get(0));
            if (!(year instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "DATE" function: the argument must evaluate to a number value.'
                );
            }
            Object month = evaluate(arguments.get(1));
            if (!(month instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "DATE"" function: the argument must evaluate to a number value.'
                );
            }
            Object day = evaluate(arguments.get(2));
            if (!(day instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "DATE" function: the argument must evaluate to a number value.'
                );
            }

            return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        }

        public override Arity getArity() {
            return Arity.exactly(3);
        }
    }

    private class DayFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "DAY" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).day();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class DayOfYearFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "DAYOFYEAR" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).dayOfYear();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class NowFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            return Datetime.now();
        }

        public override Arity getArity() {
            return Arity.exactly(0);
        }
    }

    private class DateValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect the expression to either be a text or a datetime
            Object expression = evaluate(arguments.get(0));
            if (!(expression instanceof String) && !(expression instanceof Datetime)) {
                throw new FunctionExecutionException(
                    'Error executing "DATEVALUE" function: the argument must evaluate to a string or datetime value.'
                );
            }

            if (expression instanceof String) {
                return Date.valueOf((String) expression);
            } else {
                return ((Datetime) expression).date();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class DateTimeValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object expression = evaluate(arguments.get(0));
            if (!(expression instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "DATETIMEVALUE" function: the argument must evaluate to a string value.'
                );
            }

            return Datetime.valueOf((String) expression);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class TodayFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            return Date.today();
        }

        public override Arity getArity() {
            return Arity.exactly(0);
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
                throw new FunctionExecutionException(
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

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class TimeValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateTimeOrText = evaluate(arguments.get(0));
            if (!(dateTimeOrText instanceof String) && !(dateTimeOrText instanceof Datetime)) {
                throw new FunctionExecutionException(
                    'Error executing "TIMEVALUE" function: the argument must evaluate to a string or datetime value.'
                );
            }

            if (dateTimeOrText instanceof String) {
                // A received string should be in the format of HH:mm:ss.SSS
                String[] parts = ((String) dateTimeOrText).split(':');
                if (parts.size() != 3) {
                    throw new FunctionExecutionException(
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

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class TimeNowFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            return Datetime.now().time();
        }

        public override Arity getArity() {
            return Arity.exactly(0);
        }
    }

    private class IsoWeek extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "ISOWEEK" function: the argument must evaluate to a date value.'
                );
            }

            return Integer.valueOf(Datetime.newInstanceGmt((Date) dateValue, Time.newInstance(0, 0, 0, 0)).format('w'));
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class IsoYear extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "ISOYEAR" function: the argument must evaluate to a date value.'
                );
            }

            return Integer.valueOf(Datetime.newInstanceGmt((Date) dateValue, Time.newInstance(0, 0, 0, 0)).format('Y'));
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class YearFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "YEAR" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).year();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class FromUnixTimeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object unixTime = evaluate(arguments.get(0));
            if (!(unixTime instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "FROMUNIXTIME" function: the argument must evaluate to a number value.'
                );
            }

            Long timeStamp = ((Decimal) unixTime).longValue() * 1000;
            Datetime gmtDatetime = Datetime.newInstance(timeStamp);
            return gmtDatetime;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
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
                throw new FunctionExecutionException(
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

        public override Arity getArity() {
            return Arity.exactly(1);
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
                throw new FunctionExecutionException(
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

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class FormatDuration extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Datetime startDateTime;
            Datetime endDateTime;

            // Expects either 2 Times or 2 DateTimes
            Object startVal = evaluate(arguments.get(0));
            if (startVal instanceof Time) {
                Time startTime = (Time) startVal;
                // Check that the second value is also a Time
                Object endVal = evaluate(arguments.get(1));
                if (!(endVal instanceof Time)) {
                    throw new FunctionExecutionException(
                        'Error executing "FORMATDURATION" function: the second argument must evaluate to a time value.'
                    );
                }

                Time endTime = (Time) endVal;
                // Convert both times to date times
                startDateTime = Datetime.newInstanceGmt(Date.newInstance(0, 1, 1), startTime);
                endDateTime = Datetime.newInstanceGmt(Date.newInstance(0, 1, 1), endTime);
            } else if (startVal instanceof Datetime) {
                startDateTime = (Datetime) startVal;
                // Check that the second value is also a Datetime
                Object endVal = evaluate(arguments.get(1));
                if (!(endVal instanceof Datetime)) {
                    throw new FunctionExecutionException(
                        'Error executing "FORMATDURATION" function: the second argument must evaluate to a datetime value.'
                    );
                }

                endDateTime = (Datetime) endVal;
            } else {
                throw new FunctionExecutionException(
                    'Error executing "FORMATDURATION" function: the first argument must evaluate to a time or datetime value.'
                );
            }

            // Calculate the difference between the two
            Long differenceInMs = Math.abs(endDateTime.getTime() - startDateTime.getTime());
            Integer hours = (Integer) Math.floor(differenceInMs / 1000 / 60 / 60);
            Integer minutes = (Integer) Math.floor((differenceInMs - hours * 1000 * 60 * 60) / 1000 / 60);
            Integer seconds = (Integer) Math.floor((differenceInMs - hours * 1000 * 60 * 60 - minutes * 1000 * 60) / 1000);

            // Format in HH:MM:SS
            // Use StringUtils.leftPad if necessary
            return StringUtils.leftPad(String.valueOf(hours), 2, '0') +
                ':' +
                StringUtils.leftPad(String.valueOf(minutes), 2, '0') +
                ':' +
                StringUtils.leftPad(String.valueOf(seconds), 2, '0');
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class MonthFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect a Date
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "MONTH" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).month();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class DateTimeFormatFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect a DateTime
            Object dateTimeValue = evaluate(arguments.get(0));
            if (!(dateTimeValue instanceof Datetime)) {
                throw new FunctionExecutionException(
                    'Error executing "DATETIMEFORMAT" function: the argument must evaluate to a datetime value.'
                );
            }

            // Expect a format string
            Object formatValue = evaluate(arguments.get(1));
            if (!(formatValue instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "DATETIMEFORMAT" function: the argument must evaluate to a string value.'
                );
            }

            return ((Datetime) dateTimeValue).format((String) formatValue);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class DateToDateTimeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect a Date
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "DATETODATETIME" function: the argument must evaluate to a date value.'
                );
            }

            return Datetime.newInstance((Date) dateValue, Time.newInstance(0, 0, 0, 0));
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class DaysBetween extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect a Date
            Object dateValue = evaluate(arguments.get(0));
            if (!(dateValue instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "DAYSBETWEEN" function: the argument must evaluate to a date value.'
                );
            }

            // Expect a Date
            Object dateValue2 = evaluate(arguments.get(1));
            if (!(dateValue2 instanceof Date)) {
                throw new FunctionExecutionException(
                    'Error executing "DAYSBETWEEN" function: the argument must evaluate to a date value.'
                );
            }

            return ((Date) dateValue).daysBetween((Date) dateValue2);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
