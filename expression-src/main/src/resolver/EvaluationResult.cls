public with sharing class EvaluationResult {
    public Object resultValue { get; private set; }

    public Map<String, Object> additionalData { get; private set; }

    public EvaluationResult(Object resultValue, Map<String, Object> additionalData) {
        this.resultValue = resultValue;
        this.additionalData = additionalData;
    }

    public Result toResult() {
        return new Result(resultValue);
    }
}
