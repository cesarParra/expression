public with sharing class CustomMetadataExpressionFunction {
    public final IExpressionFunction function;
    public final Boolean shouldCache;

    public CustomMetadataExpressionFunction(IExpressionFunction function, Boolean shouldCache) {
        this.function = function;
        this.shouldCache = shouldCache;
    }
}
