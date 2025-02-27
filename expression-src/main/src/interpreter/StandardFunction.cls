public with sharing abstract class StandardFunction implements IAritySupport {
    public static final List<FunctionProvider> FUNCTION_PROVIDERS = new List<FunctionProvider>{
        new LogicalFunctions.LogicalFunctionsProvider(),
        new StringFunctions.StringFunctionsProvider(),
        new MathFunctions.MathFunctionsProvider(),
        new DateAndTimeFunctions.DateAndTimeFunctionsProvider(),
        new CollectionFunctions.CollectionFunctionsProvider(),
        new DataFunctions.DataFunctionsProvider(),
        new LocationFunctions.LocationFunctionsProvider()
    };

    public static Set<String> getStandardFunctionNames() {
        Set<String> functionNames = new Set<String>{
        };
        for (FunctionProvider provider : FUNCTION_PROVIDERS) {
            functionNames.addAll(provider.getFunctions().keySet());
        }
        return functionNames;
    }

    public static Boolean functionExistsInStandardLibrary(String functionName) {
        String upperCaseFunctionName = functionName.toUpperCase();
        return getStandardFunctionNames().contains(upperCaseFunctionName);
    }

    public static StandardFunction getByName(String functionName) {
        String upperCaseFunctionName = functionName.toUpperCase();
        for (FunctionProvider provider : FUNCTION_PROVIDERS) {
            if (provider.getFunctions().containsKey(upperCaseFunctionName)) {
                return provider.getFunctions().get(upperCaseFunctionName);
            }
        }
        return null;
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
     * @return Boolean
     */
    public virtual Boolean needsQueryArgumentResolution() {
        return false;
    }

    protected Object evaluate(Expr expression) {
        return interpreter.interpret(expression);
    }

    protected Boolean isBoolean(Object single) {
        return single instanceof Boolean;
    }

    public class FunctionExecutionException extends Exception {
    }
}
