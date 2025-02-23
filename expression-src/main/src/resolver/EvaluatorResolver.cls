public with sharing abstract class EvaluatorResolver {
    private final Map<String, Object> additionalResultData = new Map<String, Object>();
    private final EvaluatorEventNotifier eventNotifier;

    private EvaluatorResolver() {
        this.eventNotifier = new EvaluatorEventNotifier(additionalResultData);
    }

    public static EvaluatorResolver forId(Id recordId) {
        return new SingleIdContextResolverEvaluator(recordId);
    }

    public static EvaluatorResolver forIds(Set<Id> ids) {
        return new MultipleIdsContextResolverEvaluator(ids);
    }

    public static EvaluatorResolver forRecord(SObject record) {
        return new BaseSingleRecordEvaluator(record);
    }

    public static EvaluatorResolver forRecords(List<SObject> sObjects) {
        return new BaseMultipleRecordsEvaluator(sObjects);
    }

    public static EvaluatorResolver withoutContext() {
        return new BaseSingleRecordEvaluator(null);
    }

    public EvaluationResult evaluate(String input, Configuration config) {
        config.subscribe(this.eventNotifier);

        eventNotifier.notify(new OnEvaluationStartEvent(config));

        List<Token> tokens = this.scan(input);
        List<Expr> parsedExpressions = this.parse(tokens);

        eventNotifier.notify(new OnAfterParseEvent(parsedExpressions));

        List<Expr> pipedExpressions = this.desugarPipe(parsedExpressions);

        // This deals with the global environment, which is shared across all evaluations, so it
        // it safe to call outside of the loop.
        addCustomContextVariablesToGlobalEnvironment(config);
        // We only care about the result of the last interpreted expression.
        // We assume that the previous results are declarations.
        Object result = null;
        for (Expr pipedExpression : pipedExpressions) {
            if (isFunctionDeclaration(pipedExpression)) {
                // If we are dealing with a function declaration we do not need to interpret it.
                Environment.addFunction((Expr.FunctionDeclaration) pipedExpression);
                continue;
            }

            Environment anEnvironment = this.prepareEnvironment(pipedExpression);
            result = this.interpret(anEnvironment, pipedExpression);
        }

        eventNotifier.notify(new OnEvaluationEndEvent());

        return new EvaluationResult(result, additionalResultData);
    }

    private static void addCustomContextVariablesToGlobalEnvironment(Configuration config) {
        if (config?.customContext == null) {
            return;
        }
        for (String customVariableName : config.customContext.keySet()) {
            Environment.addGlobalContextVariable(customVariableName, config.customContext.get(customVariableName));
        }
    }

    private static Boolean isFunctionDeclaration(Expr expression) {
        return expression instanceof Expr.FunctionDeclaration;
    }

    private List<Token> scan(String expression) {
        Scanner scanner = new Scanner(expression);
        return scanner.scanTokens();
    }

    private List<Expr> parse(List<Token> tokens) {
        Parser parser = new Parser(tokens);
        return parser.parse();
    }

    private List<Expr> desugarPipe(List<Expr> rawExpressions) {
        PipeResolver pipeInterpreter = new PipeResolver();

        List<Expr> pipedExpressions = new List<Expr>();
        for (Expr rawExpression : rawExpressions) {
            Expr pipedExpression = pipeInterpreter.resolve(rawExpression);
            pipedExpressions.add(pipedExpression);
        }

        return pipedExpressions;
    }

    protected abstract Environment prepareEnvironment(Expr pipedExpression);

    private Object interpret(Environment anEnvironment, Expr pipedExpression) {
        Interpreter theInterpreter = new Interpreter(anEnvironment);
        return theInterpreter.interpret(pipedExpression);
    }

    private class SingleIdContextResolverEvaluator extends EvaluatorResolver {
        private final Id recordId;

        public SingleIdContextResolverEvaluator(Id recordId) {
            this.recordId = recordId;
        }

        public override Environment prepareEnvironment(Expr expression) {
            ContextResolver ctxInterpreter = new ContextResolver(recordId);
            List<SObject> records = ctxInterpreter.build(expression);
            SObject record;
            if (records != null && records.size() > 0) {
                record = records[0];
            }
            Environment env = new Environment(record);

            Environment.addGlobalContextVariable('id', recordId);
            Environment.addGlobalContextVariable('context', record);

            return env;
        }
    }

    private class MultipleIdsContextResolverEvaluator extends EvaluatorResolver {
        private final Set<Id> recordIds;

        public MultipleIdsContextResolverEvaluator(Set<Id> recordIds) {
            this.recordIds = recordIds;
        }

        public override Environment prepareEnvironment(Expr expression) {
            ContextResolver ctxInterpreter = new ContextResolver(recordIds);
            List<SObject> records = ctxInterpreter.build(expression);
            // The environment is created without a record, as we are dealing with a list of records,
            // so it would not be possible to interpret references to record fields. Instead, the @context
            // variable should be used to access the list of records.
            Environment env = new Environment();

            Environment.addGlobalContextVariable('ids', recordIds);
            Environment.addGlobalContextVariable('context', records);

            return env;
        }
    }

    private class BaseSingleRecordEvaluator extends EvaluatorResolver {
        private final SObject record;

        public BaseSingleRecordEvaluator(SObject record) {
            this.record = record;
        }

        public override Environment prepareEnvironment(Expr expression) {
            Environment.addGlobalContextVariable('id', record?.Id);
            Environment.addGlobalContextVariable('context', record);
            return new Environment(record);
        }
    }

    private class BaseMultipleRecordsEvaluator extends EvaluatorResolver {
        private final List<SObject> records;

        public BaseMultipleRecordsEvaluator(List<SObject> records) {
            this.records = records;
        }

        public override Environment prepareEnvironment(Expr expression) {
            Set<Id> ids = new Set<Id>();
            for (SObject record : records) {
                if (record.Id != null) {
                    ids.add(record.Id);
                }
            }
            Environment.addGlobalContextVariable('ids', ids);
            Environment.addGlobalContextVariable('context', records);
            return new Environment();
        }
    }
}
