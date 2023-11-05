public with sharing class EvaluationSharingModeSetter implements EvaluatorEventListener {
    public Map<String, Object> handle(EvaluatorEvent event) {
        OnEvaluationStartEvent startEvent = (OnEvaluationStartEvent)event;
        QRunner.evaluationSharingMode = startEvent.config.sharing;
        return null;
    }
}