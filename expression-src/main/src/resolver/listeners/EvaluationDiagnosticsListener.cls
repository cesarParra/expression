public with sharing class EvaluationDiagnosticsListener implements EvaluatorEventListener {
    Integer startCpuTime;
    Integer startDmlStatements;
    Integer startQueries;
    Integer startQueryRows;

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

    public Map<String, Object> handle(EvaluatorEvent event) {
        if (event.getType() == OnEvaluationStartEvent.class) {
            this.onEvaluationStart();
        } else if (event.getType() == OnEvaluationEndEvent.class) {
            return this.onEvaluationEnd();
        }
        return null;
    }

    private void onEvaluationStart() {
        startCpuTime = Limits.getCpuTime();
        startDmlStatements = Limits.getDmlStatements();
        startQueries = Limits.getQueries();
        startQueryRows = Limits.getQueryRows();
    }

    private Map<String, Object> onEvaluationEnd() {
        Integer endCpuTime = Limits.getCpuTime();
        Integer endDmlStatements = Limits.getDmlStatements();
        Integer endQueries = Limits.getQueries();
        Integer endQueryRows = Limits.getQueryRows();

        DiagnosticsResult result = new DiagnosticsResult(
            endCpuTime - startCpuTime,
            endDmlStatements - startDmlStatements,
            endQueries - startQueries,
            endQueryRows - startQueryRows
        );

        return new Map<String, Object> {
            'diagnostics' => result
        };
    }
}
