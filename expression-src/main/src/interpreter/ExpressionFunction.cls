public with sharing abstract class ExpressionFunction {
    public static final Map<String, ExpressionFunction> FUNCTIONS;

    static {
        FUNCTIONS = new Map<String, ExpressionFunction>{};
        FUNCTIONS.putAll(LogicalFunctions.FUNCTIONS);
        FUNCTIONS.putAll(StringFunctions.FUNCTIONS);
        FUNCTIONS.putAll(DateAndTimeFunctions.FUNCTIONS);
        FUNCTIONS.putAll(MathFunctions.FUNCTIONS);
        FUNCTIONS.putAll(CollectionFunctions.FUNCTIONS);
        FUNCTIONS.putAll(MiscFunctions.FUNCTIONS);
    }

    protected Interpreter interpreter;

    public void setInterpreter(Interpreter interpreter) {
        this.interpreter = interpreter;
    }

    abstract public Object call(List<Expr> arguments);

    abstract public Arity getArity();

    /**
     * @description Indicate if we are dealing with function where children values can be referenced, and thus
     *              the arguments need to be resolved as a subquery.
     * @return {Boolean}
     */
    public virtual Boolean needsChildrenResolution() {
        return false;
    }

    protected Object evaluate(Expr expression) {
        return interpreter.interpret(expression);
    }

    protected Boolean isBoolean(Object single) {
        return single instanceof Boolean;
    }

    public class FunctionExecutionException extends Exception {}
}
