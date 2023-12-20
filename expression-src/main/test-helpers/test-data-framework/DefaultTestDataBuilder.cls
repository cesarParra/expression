/**
 * @description Base TestDataBuilder implementation that provides default dummy data. This class gets used as a fallback
 *              for SObjectTypes for which a custom TestDataImplementation could not be found
 * @see DefaultTestData
 * @see SObjectTestDataBuilder
 * @see ITestDataBuilder
 */
@IsTest
public with sharing class DefaultTestDataBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
    private final SObjectType objectType;

    /**
     * @description Constructs a new DefaultTestDataBuilder.
     * @param objectType The SObjectType for this builder.
     */
    public DefaultTestDataBuilder(SObjectType objectType) {
        super();
        this.objectType = objectType;
    }

    /**
     * @description Sets the value for the field specified by the SObjectField.
     * @param field The SObjectField to set the value for.
     * @param value The value to set.
     * @return Updated DefaultTestDataBuilder instance.
     */
    public DefaultTestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    /**
     * @description Registers a child to be inserted for the SObject that will be built by this builder.
     * @param childBuilder An {@link ITestDataBuilder} instance that represents the child that will be related to this
     *                     record.
     * @param relationshipField The SObjectField that represents how the 2 SObjectTypes are related.
     * @return Updated DefaultTestDataBuilder instance.
     */
    public DefaultTestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (DefaultTestDataBuilder)this.withChildData(childBuilder, relationshipField);
    }

    /**
     * @description Registers this record for insertion into the database once `SObjectTestDataBuilder.commitRecords()`
     *              is called.
     * @return The record that will be inserted into the database.
     */
    public SObject registerNewForInsert() {
        return this.registerSObjectForInsert();
    }

    /**
     * @description Registers records in bulk to be inserted into the database by this builder once
     *              `SObjectTestDataBuilder.commitRecords()` is called.
     * @param numberOfRecords The number of records to insert.
     * @return The records that will be inserted into the database.
     */
    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    /**
     * @description Returns the SObjectType for this builder.
     * @return The SObjectType for this builder.
     */
    public override SObjectType getSObjectType() {
        return this.objectType;
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        Map<SObjectField, Object> defaultValueMap = new Map<SObjectField, Object>();
        for (SObjectField currentField : getSObjectType().getDescribe().fields.getMap().values()) {
            DescribeFieldResult fieldResult = currentField.getDescribe();
            if (isFieldRequired(fieldResult)) {
                defaultValueMap.put(currentField, resolveDefaultValue(fieldResult));
            }
        }
        return defaultValueMap;
    }

    private Object resolveDefaultValue(DescribeFieldResult fieldResult) {
        if ((fieldResult.getType() == DisplayType.ID || fieldResult.getType() == DisplayType.REFERENCE)
            && fieldResult.getReferenceTo().size() > 0) {
            return bindTo(SObjectTestDataBuilder.of(fieldResult.getReferenceTo()[0]));
        }
        if (fieldResult.getType() == DisplayType.BOOLEAN) {
            return DefaultTestData.DEFAULT_BOOLEAN;
        }
        if (fieldResult.getType() == DisplayType.COMBOBOX || fieldResult.getType() == DisplayType.ENCRYPTEDSTRING ||
            fieldResult.getType() == DisplayType.MULTIPICKLIST || fieldResult.getType() == DisplayType.PICKLIST ||
            fieldResult.getType() == DisplayType.STRING || fieldResult.getType() == DisplayType.TEXTAREA) {
            return DefaultTestData.TEXT;
        }
        if (fieldResult.getType() == DisplayType.CURRENCY || fieldResult.getType() == DisplayType.DOUBLE ||
            fieldResult.getType() == DisplayType.INTEGER || fieldResult.getType() == DisplayType.LONG) {
            return DefaultTestData.DEFAULT_NUMBER;
        }
        if (fieldResult.getType() == DisplayType.DATE) {
            return DefaultTestData.DEFAULT_DATE;
        }
        if (fieldResult.getType() == DisplayType.DATETIME) {
            return DefaultTestData.DEFAULT_DATE_TIME;
        }
        if (fieldResult.getType() == DisplayType.EMAIL) {
            return DefaultTestData.EMAIL;
        }
        if (fieldResult.getType() == DisplayType.PERCENT) {
            return DefaultTestData.PERCENT;
        }
        if (fieldResult.getType() == DisplayType.PHONE) {
            return DefaultTestData.PHONE_NUMBER;
        }
        if (fieldResult.getType() == DisplayType.URL) {
            return DefaultTestData.URL;
        }

        throw new SObjectTestDataBuilder.SObjectTestDataBuilderException('Could not resolve default field for ' +
            fieldResult.getName());
    }

    private static Boolean isFieldRequired(DescribeFieldResult field) {
        return field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
    }
}
