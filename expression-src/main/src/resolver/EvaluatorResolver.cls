public with sharing abstract class EvaluatorResolver {
    private final EvaluationResult evalResult;
    private final EvaluatorEventNotifier eventNotifier;

    public EvaluatorResolver() {
        this.evalResult = new EvaluationResult();
        this.eventNotifier = new EvaluatorEventNotifier();
    }

    public static EvaluatorResolver forId(Id recordId) {
        return new ContextResolverEvaluator(recordId);
    }

    public static EvaluatorResolver forRecord(SObject record) {
        return new BaseEvaluator(record);
    }

    public EvaluationResult evaluate(String input, Configuration config) {
        config.subscribe(this.eventNotifier);

        eventNotifier.notify(new OnEvaluationStartEvent(config));

        List<Token> tokens = this.scan(input);
        Expr parsedExpression = this.parse(tokens);
        this.onAfterParse(parsedExpression);
        Expr pipedExpression = this.desugarPipe(parsedExpression);
        Environment anEnvironment = this.prepareEnvironment(pipedExpression);
        Object result = getInterpreter(anEnvironment, config).interpret(pipedExpression);
        this.evalResult.setResult(result);
        return this.evalResult;
    }

    private List<Token> scan(String expression) {
        Scanner scanner = new Scanner(expression);
        return scanner.scanTokens();
    }

    private Expr parse(List<Token> tokens) {
        Parser parser = new Parser(tokens);
        return parser.parse();
    }

    protected virtual void onAfterParse(Expr expression) {
        // Hook for subclasses
    }

    private Expr desugarPipe(Expr rawExpression) {
        PipeResolver pipeInterpreter = new PipeResolver();
        Expr pipedExpression = pipeInterpreter.resolve(rawExpression);
        return pipedExpression;
    }

    protected abstract Environment prepareEnvironment(Expr pipedExpression);

    private class ContextResolverEvaluator extends EvaluatorResolver {
        private final Id recordId;

        public ContextResolverEvaluator(Id recordId) {
            this.recordId = recordId;
        }
        public override Environment prepareEnvironment(Expr pipedExpression) {
            ContextResolver ctxInterpreter = new ContextResolver(recordId);
            SObject record = ctxInterpreter.build(pipedExpression);
            return new Environment(record);
        }
    }

    private class BaseEvaluator extends EvaluatorResolver {
        private final SObject record;

        public BaseEvaluator(SObject record) {
            this.record = record;
        }
        public override Environment prepareEnvironment(Expr pipedExpression) {
            return new Environment(record);
        }
    }

    private static IInterpreter getInterpreter(Environment env, Configuration config) {
        IInterpreter mainInterpreter = new Interpreter(env);
        if (config.withDiagnostics) {
            return new DiagnosticsDecorator(mainInterpreter);
        } else {
            return mainInterpreter;
        }
    }
}