public with sharing class MiscFunctions {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'TRANSFORM' => new TransformFn()
    };

    private class TransformFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object sourceObj = evaluate(arguments.get(0));
            Environment env = new Environment(null);
            env.define('$source', sourceObj);
            Interpreter interpreter = new Interpreter(env);
            return interpreter.interpret(arguments.get(1));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
