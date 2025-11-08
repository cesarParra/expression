/**
 * @description The `Evaluator` class is the main entry point for evaluating expressions.
 *              It provides a set of static methods that allow you to evaluate expressions
 *              in a variety of contexts.
 */
global with sharing abstract class Evaluator {
    /**
     * @description Evaluates an expression and returns the result.
     * @param formula The expression to evaluate.
     * @return The result of the expression.
     * @example
     * ```apex
     * Decimal result = (String)expression.Evaluator.run('1 + 1');
     * ```
     */
    global static Object run(String formula) {
        return run(formula, new Configuration());
    }

    /**
     * @description Evaluates multiple expressions at same time.
     *
     *{% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     *{% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * List<String> expressions = new List<String>{
     *   '1 + 1',
     *   '2 * 2',
     *   '3 - 1'
     * };
     *
     * List<expression.Result> results = expression.Evaluator.run(expressions);
     *
     * System.assertEquals(3, results.size());
     * ```
     */
    global static List<Result> run(List<String> expressions) {
        return run(expressions, new Configuration());
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
        return run(formula, (SObject)null, config);
    }

    /**
     * @description Evaluates multiple expressions at same time using a configuration object.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param config A configuration object that allows you to set options for the evaluation.
     *
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * List<String> expressions = new List<String>{
     *   '1 + 1',
     *   '2 * 2',
     *   '3 - 1'
     * };
     *
     * List<expression.Result> results = expression.Evaluator.run(
     *   expressions,
     *   new expression.Configuration().printAst()
     *   );
     * ```
     */
    global static List<Result> run(List<String> expressions, Configuration config) {
        return run(expressions, (SObject)null, config);
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
     * @description Evaluates multiple expressions at same time using a context SObject.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param context An SObject that will act as the context for the expressions. Providing this allows you to reference fields on the SObject in the expressions.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   new List<String>{'Name', 'Id'},
     *   record
     * );
     *
     * System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, SObject context) {
        return run(expressions, context, new Configuration());
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
     * @description Evaluates multiple expressions at same time using a context list of records.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param context A list of records that will act as the context for the expressions.
     * Providing this allows you to reference the records through the `@context` global variable,
     * which will give you a list of records that can be iterated over.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *    new Account(Name = 'Example 1'),
     *    new Account(Name = 'Example 2')
     * };
     *
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
     *    records
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, List<SObject> context) {
        return run(expressions, context, new Configuration());
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
        return EvaluatorResolver.forRecord(context).evaluate(formula, config).resultValue;
    }

    /**
     * @description Evaluates multiple expressions at same time using a context SObject.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param context An SObject that will act as the context for the expressions.
     * Providing this allows you to reference fields on the SObject in the expressions.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   new List<String>{'Name', 'Id'},
     *   record,
     *   new expression.Configuration().printAst()
     * );
     *
     * System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, SObject context, Configuration config) {
        return toResults(EvaluatorResolver.forRecord(context).evaluate(expressions, config));
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
        return EvaluatorResolver.forRecords(context).evaluate(formula, config).resultValue;
    }

    /**
     * @description Evaluates multiple expressions at same time using a context list of records.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param context A list of records that will act as the context for the expressions.
     * Providing this allows you to reference the records through the `@context` global variable,
     * which will give you a list of records that can be iterated over.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *    new Account(Name = 'Example 1'),
     *    new Account(Name = 'Example 2')
     * };
     *
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
     *    records,
     *    new expression.Configuration().printAst()
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, List<SObject> context, Configuration config) {
        return toResults(EvaluatorResolver.forRecords(context).evaluate(expressions, config));
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param expression The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @return The result of the formula.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * insert record;
     * String recordName = (String)expression.Evaluator.run('Name', record.Id);
     * ```
     */
    global static Object run(String expression, Id recordId) {
        return run(expression, recordId, new Configuration());
    }

    /**
     * @description Evaluates multiple expressions at same time using a record Id as the context.
     * This endpoints allow you to reference different fields on the record in different expressions, while
     * only querying the record once.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param recordId The Id of the record to use as the context for the expressions.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * insert record;
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   new List<String>{'Name', 'Id'},
     *   record.Id
     * );
     *
     * System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, Id recordId) {
        List<EvaluationResult> innerResults = EvaluatorResolver.forId(recordId).evaluate(expressions, new Configuration());
        List<Result> results = new List<Result>();
        for (EvaluationResult innerResult : innerResults) {
            results.add(innerResult.toResult());
        }
        return results;
    }

    /**
     * @description Evaluates an expression and returns the result using a set of {@link CustomRecordContext} as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     *
     *              The resulting record can be accessed through a global variable named after the
     *              key specified in the {@link CustomRecordContext}.
     *
     *              For example, if you create a {@link CustomRecordContext} with the key `TargetAccount`,
     *              you can reference fields on that record using `@TargetAccount.FieldName` in your formula.
     * @param expression The formula to evaluate.
     * @param context The CustomRecordContext to use as the context for the formula.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The result of the formula.
     * @example
     * ```apex
     * Account accountRecord = new Account(Name = 'Acme');
     * insert accountRecord;
     *
     * CustomRecordContext customRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);
     *
     * String expressionFormula = '@TargetAccount.Name';
     * Object result = Evaluator.run(expressionFormula, customRecordContext, new Configuration());
     * ```
     */
    global static Object run(String expression, CustomRecordContext context, Configuration config) {
        return EvaluatorResolver.forCustomContexts(new List<CustomRecordContext> { context }).evaluate(expression, config).resultValue;
    }

    /**
     * @description Evaluates an expression using a set of {@link CustomRecordContext} as the context.
     *
     * The resulting record can be accessed through a global variable named after the
     * key specified in each provided {@link CustomRecordContext}.
     *
     * For example, if you create one {@link CustomRecordContext} with the key `TargetAccount`,
     * and another with the key `SourceContact`,
     * you can reference fields on those records using `@TargetAccount.FieldName` and `@SourceContact.FieldName`
     * in your expressions.
     *
     * @param expression The expression to evaluate.
     * @param contexts The CustomRecordContexts to use as the context for the expressions.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * Account accountRecord = new Account(Name = 'Acme', NumberOfEmployees = 50);
     * insert accountRecord;

     * Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe');
     * insert contactRecord;

     * CustomRecordContext accountRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);
     * CustomRecordContext contactRecordContext = new CustomRecordContext('TargetContact', contactRecord.Id);

     * String expressionFormula = '@TargetContact.LastName + TEXT(@TargetAccount.NumberOfEmployees)';
     * Object result = Evaluator.run(expressionFormula,
     *     new List<CustomRecordContext> { accountRecordContext, contactRecordContext }, new Configuration());
     * ```
     */
    global static Object run(String expression, List<CustomRecordContext> contexts, Configuration config) {
        return EvaluatorResolver.forCustomContexts(contexts).evaluate(expression, config).resultValue;
    }

    /**
     * @description Evaluates multiple expressions at same time using a set of {@link CustomRecordContext} as the context.
     * This endpoints allow you to reference different fields on the records in different expressions, while
     * only querying the records once.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param contexts The CustomRecordContexts to use as the context for the expressions.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * Account accountRecord = new Account(Name = 'Acme', NumberOfEmployees = 50);
     * insert accountRecord;
     *
     * Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe');
     * insert contactRecord;
     *
     * CustomRecordContext accountRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);
     * CustomRecordContext contactRecordContext = new CustomRecordContext('TargetContact', contactRecord.Id);
     *
     * List<String> expressions = new List<String>{
     *   '@TargetAccount.Name',
     *   '@TargetContact.LastName + TEXT(@TargetAccount.NumberOfEmployees)'
     * };
     *
     * List<expression.Result> results = expression.Evaluator.run(
     *   expressions,
     *   new List<CustomRecordContext> { accountRecordContext, contactRecordContext },
     *   new expression.Configuration()
     * );
     *
     * System.assertEquals(2, results.size());
     * ```
     */
    global static List<Result> run(List<String> expressions, List<CustomRecordContext> contexts, Configuration config) {
        return toResults(EvaluatorResolver.forCustomContexts(contexts).evaluate(expressions, config));
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
     * @description Evaluates multiple expressions at same time using a set of record Ids as the context.
     * This endpoints allow you to reference different fields on the records in different expressions, while
     * only querying the records once.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param recordIds The Ids of the records to use as the context for the expressions.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *   new Account(Name = 'Example 1'),
     *   new Account(Name = 'Example 2')
     * };
     * insert records;
     *
     * List<String> recordNames = (List<String)expression.Evaluator.run(
     *  new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
     *  new Set<Id>{records[0].Id, records[1].Id}
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, Set<Id> recordIds) {
        return toResults(EvaluatorResolver.forIds(recordIds).evaluate(expressions, new Configuration()));
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
        return EvaluatorResolver.forId(recordId).evaluate(formula, config).resultValue;
    }

    /**
     * @description Evaluates multiple expressions at same time using a record Id as the context.
     * This endpoints allow you to reference different fields on the record in different expressions, while
     * only querying the record once.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param recordId The Id of the record to use as the context for the expressions.
     * @param config A configuration object that allows you to set options for the evaluation.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * Account record = new Account(Name = 'Example');
     * insert record;
     * List<String> recordNames = (List<String>)expression.Evaluator.run(
     *   new List<String>{'Name', 'Id'},
     *   record.Id,
     *   new expression.Configuration().respectSharing(false)
     * );
     *
     * System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, Id recordId, Configuration config) {
        return toResults(EvaluatorResolver.forId(recordId).evaluate(expressions, config));
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
        return EvaluatorResolver.forIds(recordIds).evaluate(formula, config).resultValue;
    }

    /**
     * @description Evaluates multiple expressions at same time using a set of record Ids as the context.
     * This endpoints allow you to reference different fields on the records in different expressions, while
     * only querying the records once.
     *
     * {% callout %}
     * It is not possible to use function definitions in bulk evaluations.
     * {% /callout %}
     *
     * @param expressions The expressions to evaluate.
     * @param recordIds The Ids of the records to use as the context for the expressions.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The results of the expressions. Results are returned in the same order as the expressions.
     * @example
     * ```apex
     * List<Account> records = new List<Account>{
     *   new Account(Name = 'Example 1'),
     *   new Account(Name = 'Example 2')
     * };
     * insert records;
     *
     * List<String> recordNames = (List<String)expression.Evaluator.run(
     *  new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
     *  new Set<Id>{records[0].Id, records[1].Id},
     *  new expression.Configuration().respectSharing(false)
     * );
     *
     * System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
     * ```
     */
    global static List<Result> run(List<String> expressions, Set<Id> recordIds, Configuration config) {
        return toResults(EvaluatorResolver.forIds(recordIds).evaluate(expressions, config));
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

    private static List<Result> toResults(List<EvaluationResult> innerResults) {
        List<Result> results = new List<Result>();
        for (EvaluationResult innerResult : innerResults) {
            results.add(innerResult.toResult());
        }
        return results;
    }
}
