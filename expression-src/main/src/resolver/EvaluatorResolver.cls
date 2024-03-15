public with sharing abstract class EvaluatorResolver {
    private final Map<String, Object> additionalResultData = new Map<String, Object>();
    private final EvaluatorEventNotifier eventNotifier;

    private EvaluatorResolver() {
        this.eventNotifier = new EvaluatorEventNotifier(additionalResultData);
    }

    public static EvaluatorResolver forId(Id recordId) {
        return new ContextResolverEvaluator(recordId);
    }

    public static EvaluatorResolver forRecord(SObject record) {
        return new BaseEvaluator(record);
    }

    public static EvaluatorResolver withoutContext() {
        return new BaseEvaluator(null);
    }

    public EvaluationResult evaluate(String input, Configuration config) {
        config.subscribe(this.eventNotifier);

        eventNotifier.notify(new OnEvaluationStartEvent(config));

        // TODO: I think it would be better instead of having to do a re-parsing, to
        // just do a string replacement here before scanning. That way the variables
        // have full context and they just serve as merged fields essentially
        List<Token> tokens = this.scan(input);
        Expr parsedExpression = this.parse(tokens);

        eventNotifier.notify(new OnAfterParseEvent(parsedExpression));

        Expr pipedExpression = this.desugarPipe(parsedExpression);
        Environment anEnvironment = this.prepareEnvironment(pipedExpression);
        if (!config.skipUserDefinedVariableEvaluation) {
            addUserDefinedVariablesToEnvironment();
        }
        // Custom context variables are added after user defined variables to allow for overriding
        addCustomContextVariablesToEnvironment(config);
        Object result = this.interpret(anEnvironment, pipedExpression);

        eventNotifier.notify(new OnEvaluationEndEvent());

        return new EvaluationResult(result, additionalResultData);
    }

    private static void addUserDefinedVariablesToEnvironment() {
        // Limitations of user defined variables:
        // 1. cannot reference other variables
        // 2. do not have access to the current context
       Map<String, Variable__mdt> variables = Variable__mdt.getAll();
        for (String variableIdentifier : variables.keySet()) {
            Environment.addGlobalContextVariable(variableIdentifier,
                Evaluator.run(variables.get(variableIdentifier).Value__c, new Configuration().skipUserDefinedVariableEvaluation()));
        }
    }

    private static void addCustomContextVariablesToEnvironment(Configuration config) {
        for (String customVariableName : config.customContext.keySet()) {
            Environment.addGlobalContextVariable(customVariableName, config.customContext.get(customVariableName));
        }
    }

    private List<Token> scan(String expression) {
        Scanner scanner = new Scanner(expression);
        return scanner.scanTokens();
    }

    private Expr parse(List<Token> tokens) {
        Parser parser = new Parser(tokens);
        return parser.parse();
    }

    private Expr desugarPipe(Expr rawExpression) {
        PipeResolver pipeInterpreter = new PipeResolver();
        Expr pipedExpression = pipeInterpreter.resolve(rawExpression);
        return pipedExpression;
    }

    protected abstract Environment prepareEnvironment(Expr pipedExpression);

    private Object interpret(Environment anEnvironment, Expr pipedExpression) {
        Interpreter theInterpreter = new Interpreter(anEnvironment);
        return theInterpreter.interpret(pipedExpression);
    }

    private class ContextResolverEvaluator extends EvaluatorResolver {
        private final Id recordId;

        public ContextResolverEvaluator(Id recordId) {
            this.recordId = recordId;
        }
        public override Environment prepareEnvironment(Expr pipedExpression) {
            ContextResolver ctxInterpreter = new ContextResolver(recordId);
            SObject record = ctxInterpreter.build(pipedExpression);
            Environment env = new Environment(record);

            Environment.addGlobalContextVariable('id', recordId);

            return env;
        }
    }

    private class BaseEvaluator extends EvaluatorResolver {
        private final SObject record;

        public BaseEvaluator(SObject record) {
            this.record = record;
        }
        public override Environment prepareEnvironment(Expr pipedExpression) {
            Environment.addGlobalContextVariable('id', record?.Id);
            return new Environment(record);
        }
    }
}
