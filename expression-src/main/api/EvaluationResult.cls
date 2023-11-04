global with sharing class EvaluationResult {
    global Object result { get; private set; }

    public Map<String, Object> additionalData = new Map<String, Object>();

    public void setResult(Object result) {
        this.result = result;
    }
}