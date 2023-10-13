/**
 * @description Evaluates a formula and returns the result.
 */
global with sharing class Evaluator {
    public static SharingMode evaluationSharingMode;

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @return The result of the formula.
     */
    global static Object run(String formula) {
        return run(formula, new Config());
    }

    /**
     * @description Evaluates a formula and returns the result.
     * @param formula The formula to evaluate.
     * @param config A configuration object that allows you to set options for
     *        the evaluation.
     * @return The result of the formula.
     */
    global static Object run(String formula, Config config) {
        return run(formula, (SObject) null, config);
    }

    /**
     * @description
     * @param formula Evaluates a formula and returns the result.
     * @param context An SObject that will act as the context for the formula.
     *        Providing this allows you to reference fields on the SObject in
     *        the formula.
     * @return The result of the formula.
     */
    global static Object run(String formula, SObject context) {
        return run(formula, context, new Config());
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
     */
    global static Object run(String formula, SObject context, Config config) {
        Expr pipedExpression = parseExpression(formula, config);
        return interpretWithContext(context, pipedExpression);
    }

    /**
     * @description Evaluates a formula and returns the result using a record Id as the context.
     *              When using this endpoint field references will automatically be resolved
     *              and queried.
     * @param formula The formula to evaluate.
     * @param recordId The Id of the record to use as the context for the formula.
     * @return The result of the formula.
     */
    global static Object run(String formula, Id recordId) {
        return run(formula, recordId, new Config());
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
     */
    global static Object run(String formula, Id recordId, Config config) {
        Expr pipedExpression = parseExpression(formula, config);
        SObject record = getRecord(recordId, pipedExpression);
        return interpretWithContext(record, pipedExpression);
    }

    private static Expr parseExpression(String formula, Config config) {
        evaluationSharingMode = config.sharing;
        System.debug('Sharing mode: ' + evaluationSharingMode);
        Scanner scanner = new Scanner(formula);
        List<Token> tokens = scanner.scanTokens();

        Parser parser = new Parser(tokens);
        Expr expression = parser.parse();

        if (config.printAst) {
            AstPrinter printer = new AstPrinter();
            printer.printAst(expression);
        }

        PipeResolver pipeInterpreter = new PipeResolver();
        Expr pipedExpression = pipeInterpreter.resolve(expression);
        return pipedExpression;
    }

    private static SObject getRecord(Id recordId, Expr pipedExpression) {
        ContextResolver ctxInterpreter = new ContextResolver(recordId);
        return ctxInterpreter.build(pipedExpression);
    }

    private static Object interpretWithContext(SObject record, Expr pipedExpression) {
        Environment env = new Environment(record);
        Interpreter interpreter = new Interpreter(env);
        return interpreter.interpret(pipedExpression);
    }

    global enum SharingMode {
        WITH,
        WITHOUT
    }

    global class Config {
        global SharingMode sharing = SharingMode.WITH;
        global Boolean printAst = false;
    }
}
