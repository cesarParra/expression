public with sharing class DiagnosticsDecorator implements IInterpreter {
    private final IInterpreter decorated;

    public static DiagnosticsResult result { get; private set; }

    public class DiagnosticsResult {
        public final Integer cpuTime;
        public final Integer dmlStatements;
        public final Integer queries;
        public final Integer queryRows;

        public DiagnosticsResult(Integer cpuTime, Integer dmlStatements, Integer queries, Integer queryRows) {
            this.cpuTime = cpuTime;
            this.dmlStatements = dmlStatements;
            this.queries = queries;
            this.queryRows = queryRows;
        }
    }

    public DiagnosticsDecorator(IInterpreter decorated) {
        this.decorated = decorated;
    }

    public Object interpret(Expr expr) {
        Integer startCpuTime = Limits.getCpuTime();
        Integer startDmlStatements = Limits.getDmlStatements();
        Integer startQueries = Limits.getQueries();
        Integer startQueryRows = Limits.getQueryRows();

        Object toReturn = this.decorated.interpret(expr);

        Integer endCpuTime = Limits.getCpuTime();
        Integer endDmlStatements = Limits.getDmlStatements();
        Integer endQueries = Limits.getQueries();
        Integer endQueryRows = Limits.getQueryRows();

        result = new DiagnosticsResult(
            endCpuTime - startCpuTime,
            endDmlStatements - startDmlStatements,
            endQueries - startQueries,
            endQueryRows - startQueryRows
        );

        return toReturn;
    }
}
