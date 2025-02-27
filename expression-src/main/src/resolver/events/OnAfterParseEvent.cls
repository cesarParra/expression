public with sharing class OnAfterParseEvent implements EvaluatorEvent {
    public final List<Expr> expressions;

    public OnAfterParseEvent(List<Expr> expressions) {
        this.expressions = expressions;
    }

    public Type getType() {
        return OnAfterParseEvent.class;
    }
}
