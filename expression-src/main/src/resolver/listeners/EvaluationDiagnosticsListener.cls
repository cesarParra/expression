public with sharing class EvaluationDiagnosticsListener implements EvaluatorEventListener {
    Integer startCpuTime;
    Integer startDmlStatements;
    Integer startQueries;
    Integer startQueryRows;

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

    public void handle(EvaluatorEvent event) {
        if (event instanceof OnEvaluationStartEvent) {
            this.onEvaluationStart((OnEvaluationStartEvent)event);
        } else if (event instanceof OnEvaluationEndEvent) {
            this.onEvaluationEnd((OnEvaluationEndEvent)event);
        }
    }

    private void onEvaluationStart(OnEvaluationStartEvent onEvaluationStartEvent) {
        startCpuTime = Limits.getCpuTime();
        startDmlStatements = Limits.getDmlStatements();
        startQueries = Limits.getQueries();
        startQueryRows = Limits.getQueryRows();
    }

    private void onEvaluationEnd(OnEvaluationEndEvent onEvaluationFinishEvent) {
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
    }
}
