public with sharing class OnAfterParseEvent implements EvaluatorEvent {
    public final Expr expression;

    public OnAfterParseEvent(Expr expression) {
        this.expression = expression;
    }

    public Type getType() {
        return OnAfterParseEvent.class;
    }
}