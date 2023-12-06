/**
 * @description Evaluates a formula and returns the result.
 */
global with sharing abstract class Evaluator {
    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @return The result of the formula.
     * @example
     * Decimal result = (String)expression.Evaluator.run('1 + 1');
     */
    global static Object run(String formula) {
        return run(formula, new Configuration());
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The result of the formula.
     * @example
     * Decimal result = (String)expression.Evaluator.run(
     *     '1 + 1',
     *     new expression.Configuration().printAst()
     * );
     */
    global static Object run(String formula, Configuration config) {
        return run(formula, (SObject) null, config);
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula Evaluates a formula and returns the result.
     * @param context An SObject that will act as the context for the formula.
     *        Providing this allows you to reference fields on the SObject in
     *        the formula.
     * @return The result of the formula.
     * @example
     * Account record = new Account(Name = 'Example');
     * String recordName = (String)expression.Evaluator.run('Name', record);
     */
    global static Object run(String formula, SObject context) {
        return run(formula, context, new Configuration());
    }

    /**
     * @description
     * @param formula Evaluates a formula and returns the result.
     * @param context An SObject that will act as the context for the formula.
     *        Providing this allows you to reference fields on the SObject in
     *        the formula.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The result of the formula.
     * @example
     * Account record = new Account(Name = 'Example');
     * String recordName = (String)expression.Evaluator.run(
     *    'Name',
     *    record,
     *    new expression.Configuration().printAst()
     * );
     */
    global static Object run(String formula, SObject context, Configuration config) {
        return EvaluatorResolver.forRecord(context).evaluate(formula, config).result;
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param formula The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @return The result of the formula.
     * @example
     * Account record = new Account(Name = 'Example');
     * insert record;
     * String recordName = (String)expression.Evaluator.run('Name', record.Id);
     */
    global static Object run(String formula, Id recordId) {
        return run(formula, recordId, new Configuration());
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param formula The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The result of the formula.
     * @example
     * Account record = new Account(Name = 'Example');
     * insert record;
     * String recordName = (String)expression.Evaluator.run(
     *   'Name',
     *   record.Id,
     *   new expression.Configuration().respectSharing(false)
     * );
     */
    global static Object run(String formula, Id recordId, Configuration config) {
        return EvaluatorResolver.forId(recordId).evaluate(formula, config).result;
    }
}
