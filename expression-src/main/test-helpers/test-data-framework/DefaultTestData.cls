/**
 * @description Provides default data for the {@link DefaultTestDataBuilder} class.
 */
@IsTest
public with sharing class DefaultTestData {
    public static final Boolean DEFAULT_BOOLEAN = false;
    public static final String TEXT = 'Any Text';
    public static final Integer DEFAULT_NUMBER = 100;
    public static final Date DEFAULT_DATE = Date.newInstance(2020, 1, 1);
    public static final Datetime DEFAULT_DATE_TIME = Datetime.newInstance(2020, 1, 1);
    public static final String EMAIL = 'example@email.com';
    public static final Decimal PERCENT = 0.5;
    public static final String PHONE_NUMBER = '555-555-5555';
    public static final String URL = 'https://www.example.com';
}
