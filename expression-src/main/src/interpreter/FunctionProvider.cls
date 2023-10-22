public interface FunctionProvider {
    // TODO: This is not necesssary anymore
    String getCategory();
    Map<String, ExpressionFunction> getFunctions();
    // TODO: This is not necessary anymore
    String getIcon();
}
