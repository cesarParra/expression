public interface EvaluatorEventListener {
    Map<String, Object> handle(EvaluatorEvent event);
}