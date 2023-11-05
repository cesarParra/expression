public with sharing class OnEvaluationStartEvent implements EvaluatorEvent {
    public final Configuration config;

    public OnEvaluationStartEvent(Configuration config) {
        this.config = config;
    }

    public Type getType() {
        return OnEvaluationStartEvent.class;
    }
}