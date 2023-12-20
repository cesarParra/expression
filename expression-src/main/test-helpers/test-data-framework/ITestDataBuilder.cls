/**
 * @description Base interface to create custom test data builders. Any custom TestDataBuilder must implement this
 *              interface and extend {@link SObjectTestDataBuilder}.
 */
public interface ITestDataBuilder {
    /**
     * @description Sets the value for the field specified by the SObjectField.
     * @param field The SObjectField to set the value for.
     * @param value The value to set.
     * @return Updated DefaultTestDataBuilder instance.
     */
    ITestDataBuilder with(SObjectField field, Object value);

    /**
     * @description Registers a child to be inserted for the SObject that will be built by this builder.
     * @param childBuilder An {@link ITestDataBuilder} instance that represents the child that will be related to this
     *                     record.
     * @param relationshipField The SObjectField that represents how the 2 SObjectTypes are related.
     * @return Updated DefaultTestDataBuilder instance.
     */
    ITestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField);

    /**
     * @description Returns the SObjectType for this builder.
     * @return The SObjectType for this builder.
     */
    SObjectType getSObjectType();

    /**
     * @description Registers this record for insertion into the database once `SObjectTestDataBuilder.commitRecords()`
     *              is called.
     * @return The record that will be inserted into the database.
     */
    SObject registerNewForInsert();

    /**
     * @description Registers records in bulk to be inserted into the database by this builder once
     *              `SObjectTestDataBuilder.commitRecords()` is called.
     * @param numberOfRecords The number of records to insert.
     * @return The records that will be inserted into the database.
     */
    List<SObject> registerNewForInsert(Integer numberOfRecords);
}
