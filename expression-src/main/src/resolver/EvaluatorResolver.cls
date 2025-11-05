public with sharing abstract class EvaluatorResolver {
    private static final String DEFAULT_CONTEXT_KEY = 'context';
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

    public static EvaluatorResolver forCustomContexts(List<CustomRecordContext> customRecordContexts) {
        return new CustomContextResolverEvaluator(customRecordContexts);
    }

    /**
     * @description Analyzes multiple formulas and retrieves a record with all fields needed by those formulas
     * @param recordId The Id of the record to retrieve
     * @param formulas List of formulas to analyze
     * @return SObject The record populated with all fields referenced by the formulas
     */
    public static SObject retrieveRecordForFormulas(Id recordId, List<String> formulas) {
        if (recordId == null || formulas == null || formulas.isEmpty()) {
            return null;
        }

        ContextResolver contextResolver = new ContextResolver(new CustomRecordContext(DEFAULT_CONTEXT_KEY, recordId),
            '@', new List<Expr.FunctionDeclaration>());

        for (String formula : formulas) {
            try {
                List<Token> tokens = new Scanner(formula).scanTokens();
                List<Expr> expressions = new Parser(tokens).parse();

                for (Expr parsedExpression : expressions) {
                    Expr desugaredExpression = new PipeResolver().resolve(parsedExpression);
                    contextResolver.resolveForRecord(desugaredExpression);
                }
            } catch (Exception e) {
                // Continue analyzing other formulas even if one fails
                System.debug(LoggingLevel.WARN, 'Error analyzing formula "' + formula + '": ' + e.getMessage());
            }
        }

        if (!contextResolver.shouldExecuteQuery()) {
            return null;
        }

        // Add subqueries to the main query
        for (ContextResolver.Query subquery : contextResolver.getSubQueries()) {
            contextResolver.getQueryContext().queryBuilder.addSubquery(subquery.queryBuilder);
        }

        // Add condition to filter by the specific record id
        contextResolver.getQueryContext().queryBuilder.add(Q.condition('Id').isIn(new List<Id> { recordId }));

        // Execute the query and return the first record (if any)
        List<SObject> records = QDB.getInstance().run(contextResolver.getQueryContext().queryBuilder);
        return records.isEmpty() ? null : records[0];
    }

    public EvaluationResult evaluate(String input, Configuration config) {
        return evaluate(new List<String> { input }, config).get(0);
    }

    public List<EvaluationResult> evaluate(List<String> inputs, Configuration config) {
        config.subscribe(this.eventNotifier);
        eventNotifier.subscribe(OnEvaluationEndEvent.class, new Environment.ClearContext());
        eventNotifier.notify(new OnEvaluationStartEvent(config));

        // This deals with the global environment, which is shared across all evaluations, so it
        // it safe to call outside of the loop.
        addCustomContextVariablesToGlobalEnvironment(config);

        List<List<Expr>> allPipedExpressions = new List<List<Expr>>();
        for (String input : inputs) {
            List<Token> tokens = this.scan(input);
            List<Expr> parsedExpressions = this.parse(tokens);

            eventNotifier.notify(new OnAfterParseEvent(parsedExpressions));

            List<Expr> pipedExpressions = this.desugarPipe(parsedExpressions);
            allPipedExpressions.add(pipedExpressions);
        }

        List<Expr.FunctionDeclaration> functionDeclarations = new List<Expr.FunctionDeclaration>();
        List<Expr> expressionsForEnvironment = new List<Expr>();
        for (List<Expr> pipedExpressions : allPipedExpressions) {
            for (Expr expression : pipedExpressions) {
                Boolean isFunctionDeclaration = isFunctionDeclaration(expression);
                if (isFunctionDeclaration && inputs.size() > 1) {
                    // Calling the bulk endpoint does not support function declarations,
                    throw new UnsupportedOperationException('Function declarations are not supported in bulk evaluations.');
                }

                if (isFunctionDeclaration) {
                    // If we are dealing with a function declaration we do not need to interpret it.
                    Expr.FunctionDeclaration fnDeclaration = (Expr.FunctionDeclaration)expression;
                    Environment.addGlobalVariable(fnDeclaration.functionName, fnDeclaration);
                    functionDeclarations.add(fnDeclaration);
                    continue;
                }

                expressionsForEnvironment.add(expression);
            }
        }

        Environment anEnvironment = this.prepareEnvironment(expressionsForEnvironment, functionDeclarations, config.globalContextVariablePrefix);
        List<EvaluationResult> results = new List<EvaluationResult>();
        for (List<Expr> pipedExpressions : allPipedExpressions) {
            // We only care about the result of the last interpreted expression
            // We assume that the previous results are declarations.
            Object result = null;
            for (Expr pipedExpression : pipedExpressions) {
                if (!isFunctionDeclaration(pipedExpression)) {
                    result = this.interpret(anEnvironment, pipedExpression);
                }
            }
            results.add(new EvaluationResult(result, additionalResultData));
        }

        eventNotifier.notify(new OnEvaluationEndEvent());
        return results;
    }

    private static void addCustomContextVariablesToGlobalEnvironment(Configuration config) {
        if (config?.customContext == null) {
            return;
        }
        for (String customVariableName : config.customContext.keySet()) {
            Environment.addGlobalContextVariable(config.globalContextVariablePrefix, customVariableName, config.customContext.get(customVariableName));
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

    protected abstract Environment prepareEnvironment(List<Expr> pipedExpressions, List<Expr.FunctionDeclaration> customFunctionDeclarations, String contextPrefix);

    private Object interpret(Environment anEnvironment, Expr pipedExpression) {
        Interpreter theInterpreter = new Interpreter(anEnvironment);
        return theInterpreter.interpret(pipedExpression);
    }

    private class SingleIdContextResolverEvaluator extends EvaluatorResolver {
        private final Id recordId;

        public SingleIdContextResolverEvaluator(Id recordId) {
            this.recordId = recordId;
        }

        public override Environment prepareEnvironment(List<Expr> expressions,
            List<Expr.FunctionDeclaration> customFunctionDeclarations, String contextPrefix) {
            ContextResolver ctxInterpreter = new ContextResolver(new CustomRecordContext(DEFAULT_CONTEXT_KEY, recordId),
                contextPrefix, customFunctionDeclarations);
            List<SObject> records = ctxInterpreter.build(expressions);
            SObject record;
            if (records != null && records.size() > 0) {
                record = records[0];
            }
            Environment env = new Environment(record);

            Environment.addGlobalContextVariable(contextPrefix, 'id', recordId);
            Environment.addGlobalContextVariable(contextPrefix, 'context', record);

            return env;
        }
    }

    private class MultipleIdsContextResolverEvaluator extends EvaluatorResolver {
        private final Set<Id> recordIds;

        public MultipleIdsContextResolverEvaluator(Set<Id> recordIds) {
            this.recordIds = recordIds;
        }

        public override Environment prepareEnvironment(List<Expr> expressions, List<Expr.FunctionDeclaration> customFunctionDeclarations, String contextPrefix) {
            List<CustomRecordContext> recordContexts = new List<CustomRecordContext>();
            for (Id recordId : this.recordIds) {
                recordContexts.add(new CustomRecordContext(DEFAULT_CONTEXT_KEY, recordId));
            }
            ContextResolver ctxInterpreter = new ContextResolver(recordContexts, contextPrefix, customFunctionDeclarations);
            List<SObject> records = ctxInterpreter.build(expressions);
            // The environment is created without a record, as we are dealing with a list of records,
            // so it would not be possible to interpret references to record fields. Instead, the @context
            // variable should be used to access the list of records.
            Environment env = new Environment();

            Environment.addGlobalContextVariable(contextPrefix, 'ids', recordIds);
            Environment.addGlobalContextVariable(contextPrefix, 'context', records);

            return env;
        }
    }

    private class CustomContextResolverEvaluator extends EvaluatorResolver {
        private final List<CustomRecordContext> contexts;

        public CustomContextResolverEvaluator(List<CustomRecordContext> contexts) {
            this.contexts = contexts;
        }

        public override Environment prepareEnvironment(List<Expr> expressions, List<Expr.FunctionDeclaration> customFunctionDeclarations, String contextPrefix) {
            Environment env = new Environment();

            Map<SObjectType, List<CustomRecordContext>> contextsBySObjectTypes = new Map<SObjectType, List<CustomRecordContext>>();
            for (CustomRecordContext context : this.contexts) {
                SObjectType sObjectType = context.recordId.getSobjectType();
                if (!contextsBySObjectTypes.containsKey(sObjectType)) {
                    contextsBySObjectTypes.put(sObjectType, new List<CustomRecordContext>());
                }
                contextsBySObjectTypes.get(sObjectType).add(context);
            }

            for (SObjectType currentType : contextsBySObjectTypes.keySet()) {
                List<CustomRecordContext> contextsForType = contextsBySObjectTypes.get(currentType);
                Map<Id, CustomRecordContext> contextByRecordId = new Map<Id, CustomRecordContext>();
                for (CustomRecordContext context : contextsForType) {
                    contextByRecordId.put(context.recordId, context);
                }

                ContextResolver ctxInterpreter = new ContextResolver(contextsForType, contextPrefix, customFunctionDeclarations);
                List<SObject> queriedRecords = ctxInterpreter.build(expressions);
                Map<Id, SObject> recordById = new Map<Id, SObject>(queriedRecords);
                for (Id recordId : recordById.keySet()) {
                    SObject record = recordById.get(recordId);
                    CustomRecordContext context = contextByRecordId.get(recordId);

                    Environment.addGlobalContextVariable(contextPrefix, context.key, record);
                }
            }

            return env;
        }
    }

    private class BaseSingleRecordEvaluator extends EvaluatorResolver {
        private final SObject record;

        public BaseSingleRecordEvaluator(SObject record) {
            this.record = record;
        }

        public override Environment prepareEnvironment(List<Expr> expressions, List<Expr.FunctionDeclaration> customFunctionDeclarations, String contextPrefix) {
            Environment.addGlobalContextVariable(contextPrefix, 'id', record?.Id);
            Environment.addGlobalContextVariable(contextPrefix, 'context', record);
            return new Environment(record);
        }
    }

    private class BaseMultipleRecordsEvaluator extends EvaluatorResolver {
        private final List<SObject> records;

        public BaseMultipleRecordsEvaluator(List<SObject> records) {
            this.records = records;
        }

        public override Environment prepareEnvironment(List<Expr> expressions,
            List<Expr.FunctionDeclaration> customFunctionDeclarations, String contextPrefix) {
            Set<Id> ids = new Set<Id>();
            for (SObject record : records) {
                if (record.Id != null) {
                    ids.add(record.Id);
                }
            }
            Environment.addGlobalContextVariable(contextPrefix, 'ids', ids);
            Environment.addGlobalContextVariable(contextPrefix, 'context', records);
            return new Environment();
        }
    }
}
