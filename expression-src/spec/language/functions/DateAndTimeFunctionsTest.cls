@IsTest
private class DateAndTimeFunctionsTest {
    @IsTest
    private static void dateEvaluatesToADate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATE(2015, 1, 1)'));
    }

    @IsTest
    private static void addMonthsFunctionAddsMonths() {
        Assert.areEqual(Date.newInstance(2015, 2, 1), Evaluator.run('ADDMONTHS(DATE(2015, 1, 1), 1)'));
    }

    @IsTest
    private static void dayFunctionReturnsDay() {
        Assert.areEqual(1, Evaluator.run('DAY(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void dayOfYearFunctionReturnsDayOfYear() {
        Assert.areEqual(1, Evaluator.run('DAYOFYEAR(DATE(2015, 1, 1))'));
        Assert.areEqual(365, Evaluator.run('DAYOFYEAR(DATE(2015, 12, 31))'));
    }

    @IsTest
    private static void fromUnixTimeFunctionReturnsADatetimeFromUnixTime() {
        Assert.areEqual(Datetime.newInstanceGmt(2015, 1, 1, 0, 0, 0), Evaluator.run('FROMUNIXTIME(1420070400)'));
    }

    @IsTest
    private static void nowFunctionReturnsAValue() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(Evaluator.run('NOW()'));
    }

    @IsTest
    private static void dateValueFunctionConvertsAStringToDate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATEVALUE("2015-01-01")'));
    }

    @IsTest
    private static void dateValueFunctionConvertsADatetimeToDate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), Evaluator.run('DATEVALUE(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void datetimeValueFunctionConvertsAStringToADatetime() {
        Assert.areEqual(Datetime.newInstance(2015, 1, 1, 0, 0, 0), Evaluator.run('DATETIMEVALUE("2015-01-01 00:00:00")'));
    }

    @IsTest
    private static void todayFunctionReturnsToday() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(Evaluator.run('TODAY()'));
    }

    @IsTest
    private static void timeValueFunctionReturnsTheTimeValueOfADateTime() {
        Assert.areEqual(Time.newInstance(2, 0, 0, 0), Evaluator.run('TIMEVALUE(DATETIMEVALUE("2015-01-01 02:00:00"))'));
    }

    @IsTest
    private static void timeValueFunctionReturnsTheTimeValueOfADateTimeString() {
        Assert.areEqual(Time.newInstance(17, 30, 45, 125), Evaluator.run('TIMEVALUE("17:30:45.125")'));
    }

    @IsTest
    private static void timenowFunctionReturnsTheCurrentTime() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(Evaluator.run('TIMENOW()'));
    }

    @IsTest
    private static void isoweekFunctionReturnsTheIsoWeek() {
        Assert.areEqual(1, Evaluator.run('ISOWEEK(DATE(2015, 1, 1))'));
        Assert.areEqual(52, Evaluator.run('ISOWEEK(DATE(2015, 12, 27))'));
    }

    @IsTest
    private static void isoyearFunctionReturnsTheIsoYear() {
        Assert.areEqual(2015, Evaluator.run('ISOYEAR(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void yearFunctionReturnsTheYear() {
        Assert.areEqual(2015, Evaluator.run('YEAR(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void millisecondFunctionReturnsTheMillisecond() {
        Assert.areEqual(123, Evaluator.run('MILLISECOND(TIMEVALUE("12:00:00.123"))'));
    }

    @IsTest
    private static void minuteFunctionReturnsTheMinute() {
        Assert.areEqual(30, Evaluator.run('MINUTE(TIMEVALUE("12:30:00"))'));
    }

    @IsTest
    private static void secondFunctionReturnsTheSecond() {
        Assert.areEqual(45, Evaluator.run('SECOND(TIMEVALUE("12:00:45"))'));
    }

    @IsTest
    private static void hourFunctionReturnsTheHour() {
        Assert.areEqual(12, Evaluator.run('HOUR(TIMEVALUE("12:00:00"))'));
    }

    @IsTest
    private static void unixTimeStampReturnsTheCorrectNumberOfSecondsForADate() {
        // Uses GMT
        Assert.areEqual(1420070400, Evaluator.run('UNIXTIMESTAMP(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void unixTimeStampReturnsTheCorrectNumberForADateTime() {
        // Uses GMT
        Assert.areEqual(1420070400, Evaluator.run('UNIXTIMESTAMP(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void unixTimeStampReturnsTheNumberOfSecondsTheDayWhenReceivingATime() {
        Assert.areEqual(3600, Evaluator.run('UNIXTIMESTAMP(TIMEVALUE("01:00:00"))'), 'Expect the number of seconds for a given time');
    }

    @IsTest
    private static void weekDayReturnsTheDayOfTheWeek() {
        Assert.isNotNull(Evaluator.run('WEEKDAY(DATE(2015, 1, 5))'));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_hoursDifference() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:00:00"), TIMEVALUE("02:00:00"))';
        Assert.areEqual('01:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_minutesDifference() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:30:00"), TIMEVALUE("02:00:00"))';
        Assert.areEqual('00:30:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_secondsDifference() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:30:00"), TIMEVALUE("01:30:45"))';
        Assert.areEqual('00:00:45', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_multipleDifferences() {
        String formula = 'FORMATDURATION(TIMEVALUE("01:45:00"), TIMEVALUE("09:00:01"))';
        Assert.areEqual('07:15:01', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoTimes_firstTimeGreaterThanSecond() {
        String formula = 'FORMATDURATION(TIMEVALUE("02:00:00"), TIMEVALUE("01:00:00"))';
        Assert.areEqual('01:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_daysDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 00:00:00"), DATETIMEVALUE("2015-01-02 00:00:00"))';
        Assert.areEqual('24:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_hoursDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:00:00"), DATETIMEVALUE("2015-01-01 02:00:00"))';
        Assert.areEqual('01:00:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_minutesDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:30:00"), DATETIMEVALUE("2015-01-01 02:00:00"))';
        Assert.areEqual('00:30:00', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_secondsDifference() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:30:00"), DATETIMEVALUE("2015-01-01 01:30:45"))';
        Assert.areEqual('00:00:45', Evaluator.run(formula));
    }

    @IsTest
    private static void formatDurationFormatsTheTimeBetweenTwoDateTimes_multipleDifferences() {
        String formula = 'FORMATDURATION(DATETIMEVALUE("2015-01-01 01:45:00"), DATETIMEVALUE("2015-01-01 09:00:01"))';
        Assert.areEqual('07:15:01', Evaluator.run(formula));
    }

    @IsTest
    private static void monthReturnsANumberBetween1And12ForTheSpecifiedDate() {
        Assert.areEqual(1, Evaluator.run('MONTH(DATE(2015, 1, 1))'));
        Assert.areEqual(12, Evaluator.run('MONTH(DATE(2015, 12, 1))'));
    }

    @IsTest
    private static void dateTimeFormatFormatsADateTimeToTheSpecifiedStringFormat() {
        String formula = 'DATETIMEFORMAT(DATETIMEVALUE("2015-01-01 01:00:00"), "yyyy-MM-dd HH:mm:ss")';
        Object result = Evaluator.run(formula);
        Assert.areEqual('2015-01-01 01:00:00', result);
    }

    @IsTest
    private static void dateToDateTimeConvertsADateToADateTime() {
        String formula = 'DATETODATETIME(DATEVALUE("2015-01-01"))';
        Object result = Evaluator.run(formula);
        Assert.areEqual(Datetime.newInstance(2015, 1, 1, 0, 0, 0), result);
    }

    @IsTest
    private static void daysBetweenReturnsTheNumberOfDaysBetweenTwoDates() {
        String formula = 'DAYSBETWEEN(DATEVALUE("2020-01-01"), DATEVALUE("2020-01-02"))';
        Object result = Evaluator.run(formula);
        Assert.areEqual(1, result);
    }

    @IsTest
    private static void daysBetweenReturnsTheNumberOfDaysBetweenTwoDates_higherDateAsFirstArgument_resultsInNegative() {
        String formula = 'DAYSBETWEEN(DATEVALUE("2020-01-02"), DATEVALUE("2020-01-01"))';
        Object result = Evaluator.run(formula);
        Assert.areEqual(-1, result);
    }
}
