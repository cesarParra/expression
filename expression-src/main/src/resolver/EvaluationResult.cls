public with sharing class EvaluationResult {
    public Object result { get; private set; }

    public Map<String, Object> additionalData { get; private set; }

    public EvaluationResult(Object result, Map<String, Object> additionalData) {
        this.result = result;
        this.additionalData = additionalData;
    }
}