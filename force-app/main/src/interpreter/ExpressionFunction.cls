public with sharing abstract class ExpressionFunction {
    public static final Map<String, ExpressionFunction> FUNCTIONS;

    static {
        FUNCTIONS = new Map<String, ExpressionFunction>{};
        FUNCTIONS.putAll(LogicalFunctions.FUNCTIONS);
        FUNCTIONS.putAll(StringFunctions.FUNCTIONS);
        FUNCTIONS.putAll(DateAndTimeFunctions.FUNCTIONS);
        FUNCTIONS.putAll(MathFunctions.FUNCTIONS);
        FUNCTIONS.putAll(CollectionFunctions.FUNCTIONS);
    }

    protected Interpreter interpreter;

    public void setInterpreter(Interpreter interpreter) {
        this.interpreter = interpreter;
    }

    abstract public Object call(List<Expr> arguments);

    protected Object evaluate(Expr expression) {
        return interpreter.interpret(expression);
    }

    protected Boolean isBoolean(Object single) {
        return single instanceof Boolean;
    }
}
