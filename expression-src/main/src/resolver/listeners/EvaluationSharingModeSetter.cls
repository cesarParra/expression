public with sharing class EvaluationSharingModeSetter implements EvaluatorEventListener {
    public void handle(EvaluatorEvent event) {
        OnEvaluationStartEvent startEvent = (OnEvaluationStartEvent)event;
        Configuration.evaluationSharingMode = startEvent.config.sharing;
    }
}