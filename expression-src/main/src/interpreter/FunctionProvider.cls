public interface FunctionProvider {
    String getCategory();
    Map<String, ExpressionFunction> getFunctions();
    String getIcon();
}
