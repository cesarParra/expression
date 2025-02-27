/**
 * @description The `Evaluator` class is the main entry point for evaluating expressions.
 *              It provides a set of static methods that allow you to evaluate expressions
 *              in a variety of contexts.
 */
global with sharing abstract class Evaluator {
    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @return The result of the formula.
     * @example
     * ```apex
     * Decimal result = (String)expression.Evaluator.run('1 + 1');
     * ```
     */
    global static Object run(String formula) {
        return run(formula, new Configuration());
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The result of the formula.
     * @example
     * ```apex
     * Decimal result = (String)expression.Evaluator.run(
     *     '1 + 1',
     *     new expression.Configuration().printAst()
     * );
     * ```
     */
    global static Object run(String formula, Configuration config) {
        return run(formula, (SObject) null, config);
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula Evaluates a formula and returns the result.
     * @param context An SObject that will act as the context for the formula. Providing this allows you to reference fields on the SObject in the formula.
     * @return The result of the formula.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * String recordName = (String)expression.Evaluator.run('Name', record);
     * ```
     */
    global static Object run(String formula, SObject context) {
        return run(formula, context, new Configuration());
    }

    /**
     * @description Evaluates an expression and returns the result.
     * @param expression The expression to evaluate.
     * @param context A list of records that will act as the context for the expression. Providing this allows you to reference the records through the `@context` global variable, which will give you a list of records that can be iterated over.
     * @return The result of the formula.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *    new Account(Name = 'Example 1'),
     *    new Account(Name = 'Example 2')
     * };
     *
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   'MAP(@context, Name)',
     *    records
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
     * ```
     */
    global static Object run(String expression, List<SObject> context) {
        return run(expression, context, new Configuration());
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The expression to evaluate
     * @param context An SObject that will act as the context for the formula. Providing this allows you to reference fields on the SObject in the formula.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The result of the formula.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * String recordName = (String)expression.Evaluator.run(
     *    'Name',
     *    record,
     *    new expression.Configuration().printAst()
     * );
     * ```
     */
    global static Object run(String formula, SObject context, Configuration config) {
        return EvaluatorResolver.forRecord(context).evaluate(formula, config).result;
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The expression to evaluate.
     * @param context A list of records that will act as the context for the formula. Providing this allows you to reference the records through the `@context` global variable, which will give you a list of records that can be iterated over.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The result of the formula.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *    new Account(Name = 'Example 1'),
     *    new Account(Name = 'Example 2')
     * };
     *
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   'MAP(@context, Name)',
     *    records,
     *    new expression.Configuration().printAst()
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
     * ```
     */
    global static Object run(String formula, List<SObject> context, Configuration config) {
        return EvaluatorResolver.forRecords(context).evaluate(formula, config).result;
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param formula The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @return The result of the formula.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * insert record;
     * String recordName = (String)expression.Evaluator.run('Name', record.Id);
     * ```
     */
    global static Object run(String formula, Id recordId) {
        return run(formula, recordId, new Configuration());
    }

    /**
     * @description Evaluates a formula and returns the result using a set of record Ids as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     *
     *              The resulting records can be accessed through the `@context` global variable, which
     *              will give you a list of records that can be iterated over.
     * @param formula The formula to evaluate.
     * @param recordIds The Ids of the records to use as the context for the formula.
     * @return The result of the formula.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *   new Account(Name = 'Example 1'),
     *   new Account(Name = 'Example 2')
     * };
     * insert records;
     *
     * List<String> recordNames = (List<String)expression.Evaluator.run(
     *  'MAP(@context, Name)',
     *  new Set<Id>{records[0].Id, records[1].Id}
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
     * ```
     */
    global static Object run(String formula, Set<Id> recordIds) {
        return run(formula, recordIds, new Configuration());
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param formula The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The result of the formula.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * insert record;
     * String recordName = (String)expression.Evaluator.run(
     *   'Name',
     *   record.Id,
     *   new expression.Configuration().respectSharing(false)
     * );
     * ```
     */
    global static Object run(String formula, Id recordId, Configuration config) {
        return EvaluatorResolver.forId(recordId).evaluate(formula, config).result;
    }

    /**
     * @description Evaluates a formula and returns the result using a set of record Ids as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     *
     *              The resulting records can be accessed through the `@context` global variable, which
     *              will give you a list of records that can be iterated over.
     * @param formula The formula to evaluate.
     * @param recordIds The Ids of the records to use as the context for the formula.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The result of the formula.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *   new Account(Name = 'Example 1'),
     *   new Account(Name = 'Example 2')
     * };
     * insert records;
     *
     * List<String> recordNames = (List<String)expression.Evaluator.run(
     *  'MAP(@context, Name)',
     *  new Set<Id>{records[0].Id, records[1].Id},
     *  new expression.Configuration().respectSharing(false)
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
     * ```
     */
    global static Object run(String formula, Set<Id> recordIds, Configuration config) {
        return EvaluatorResolver.forIds(recordIds).evaluate(formula, config).result;
    }
    
    /**
     * @description Analyzes multiple formulas and retrieves a record with all fields needed by those formulas.
     *              This is useful when you need to query a record once with all required fields for multiple
     *              formula evaluations, rather than letting each formula evaluation perform its own query.
     * @param recordId The Id of the record to retrieve
     * @param formulas List of formulas to analyze
     * @return SObject The record populated with all fields referenced in the formulas
     * @example
     * ```apex
     * Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
     * List<String> formulas = new List<String>{
     *   'Name',
     *   'BillingCity',
     *   'Owner.Name'
     * };
     * Account account = (Account)expression.Evaluator.retrieveRecordForFormulas(accountId, formulas);
     * // Now use the account record which contains all the needed fields
     * String accountName = (String)account.get('Name');
     * String ownerName = (String)account.getSObject('Owner').get('Name');
     * ```
     */
    global static SObject retrieveRecordForFormulas(Id recordId, List<String> formulas) {
        return EvaluatorResolver.retrieveRecordForFormulas(recordId, formulas);
    }
}
