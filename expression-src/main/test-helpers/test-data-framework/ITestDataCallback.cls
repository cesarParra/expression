/**
 * @description Callback with methods to be executed before and after database calls.
 *              Do not implement directly, rather extend {@link SObjectTestDataBuilder} and override
 *              the methods provided there.
 */
public interface ITestDataCallback {
    /**
     * @description Executes before inserting the SObject
     *              for this builder into the database.
     * @param record The SObject that will be inserted into the database.
     */
    void beforeInsert(SObject record);

    /**
     * @description Executes after inserting the SObject
     *              for this builder into the database.
     * @param record The SObject that will be inserted into the database.
     */
    void afterInsert(SObject record);
}
