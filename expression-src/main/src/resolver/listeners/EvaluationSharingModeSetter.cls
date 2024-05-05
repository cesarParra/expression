public with sharing class EvaluationSharingModeSetter implements EvaluatorEventListener {
    public Map<String, Object> handle(EvaluatorEvent event) {
        OnEvaluationStartEvent startEvent = (OnEvaluationStartEvent) event;
        QDB.evaluationSharingMode = startEvent.config.sharing;
        return null;
    }
}
