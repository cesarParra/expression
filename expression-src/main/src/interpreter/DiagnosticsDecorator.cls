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
        System.debug('start query rows: ' + startQueryRows);

        Object toReturn = this.decorated.interpret(expr);

        Integer endCpuTime = Limits.getCpuTime();
        Integer endDmlStatements = Limits.getDmlStatements();
        Integer endQueries = Limits.getQueries();
        Integer endQueryRows = Limits.getQueryRows();
        System.debug('end query rows: ' + endQueryRows);

        System.debug('Total query rows: ' + (endQueryRows - startQueryRows));

        result = new DiagnosticsResult(
            endCpuTime - startCpuTime,
            endDmlStatements - startDmlStatements,
            endQueries - startQueries,
            endQueryRows - startQueryRows
        );
        System.debug('diag result: ' + result);

        return toReturn;
    }

    public Object visit(Expr.Binary binary) {
        return this.decorated.visit(binary);
    }

    public Object visit(Expr.Grouping grouping) {
        return this.decorated.visit(grouping);
    }

    public Object visit(Expr.StringLiteral literal) {
        return this.decorated.visit(literal);
    }

    public Object visit(Expr.Literal literal) {
        return this.decorated.visit(literal);
    }

    public Object visit(Expr.Unary unary) {
        return this.decorated.visit(unary);
    }

    public Object visit(Expr.FunctionCall function) {
        return this.decorated.visit(function);
    }

    public Object visit(Expr.GetExpr getExpr) {
        return this.decorated.visit(getExpr);
    }

    public Object visit(Expr.Variable variable) {
        return this.decorated.visit(variable);
    }

    public Object visit(Expr.MergeField mergeField) {
        return this.decorated.visit(mergeField);
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        return this.decorated.visit(listLiteral);
    }

    public Object visit(Expr.MapLiteral mapLiteral) {
        return this.decorated.visit(mapLiteral);
    }

    public Object visit(Expr.Spread spread) {
        return this.decorated.visit(spread);
    }
}
