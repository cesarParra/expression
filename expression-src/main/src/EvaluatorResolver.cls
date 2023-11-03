public with sharing abstract class EvaluatorResolver implements IEvaluatorResolver {
    public static EvaluatorResolver forId(Id recordId) {
        return new ContextResolverEvaluator(recordId);
    }

    public static EvaluatorResolver forRecord(SObject record) {
        return new BaseEvaluator(record);
    }

    public Object evaluate(String formula, Configuration config) {
        Expr pipedExpression = this.parseExpression(formula, config);
        Environment anEnvironment = this.getEnvironment(pipedExpression);
        return getInterpreter(anEnvironment, config).interpret(pipedExpression);
    }

    private Expr parseExpression(String formula, Configuration config) {
        Configuration.evaluationSharingMode = config.sharing;
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

    protected abstract Environment getEnvironment(Expr pipedExpression);

    private class ContextResolverEvaluator extends EvaluatorResolver {
        private final Id recordId;

        public ContextResolverEvaluator(Id recordId) {
            this.recordId = recordId;
        }
        public override Environment getEnvironment(Expr pipedExpression) {
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
        public override Environment getEnvironment(Expr pipedExpression) {
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