public with sharing class MathFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'ABS' => new AbsFn(),
        'CEILING' => new CeilingFn(),
        'FLOOR' => new FloorFn(),
        'MAX' => new MaxMixFns('MAX'),
        'MIN' => new MaxMixFns('MIN'),
        'ROUND' => new RoundAndTruncFns('ROUND'),
        'TRUNC' => new RoundAndTruncFns('TRUNC'),
        'MOD' => new ModFn()
    };

    public class MathFunctionsProvider implements FunctionProvider {
        public String getCategory() {
            return 'Math';
        }

        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }

        public String getIcon() {
            return 'utility:advanced_function';
        }
    }

    private class AbsFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "ABS" function: the argument must evaluate to a number value.'
                );
            }

            return Math.abs((Decimal) numberValue);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class CeilingFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "CEILING" function: the argument must evaluate to a number value.'
                );
            }

            return Math.ceil((Decimal) numberValue);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class FloorFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "FLOOR" function: the argument must evaluate to a number value.'
                );
            }

            return Math.floor((Decimal) numberValue);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class MaxMixFns extends ExpressionFunction {
        private final String name;

        public MaxMixFns(String name) {
            this.name = name;
        }

        public override Object call(List<Expr> arguments) {
            List<Object> values = new List<Object>();

            // If the first argument is a list then only one argument is expected
            Object firstArgument = evaluate(arguments.get(0));
            if (firstArgument instanceof List<Object>) {
                if (arguments.size() > 1) {
                    throw new FunctionExecutionException(
                        'Error executing ' + name + ' function: the function must have at most one argument when the first argument is a list.'
                    );
                }

                values = (List<Object>) firstArgument;
            } else {
                values.add(firstArgument);

                for (Integer i = 1; i < arguments.size(); i++) {
                    values.add(evaluate(arguments.get(i)));
                }
            }

            Decimal result = null;
            for (Object value : values) {
                if (!(value instanceof Decimal)) {
                    throw new FunctionExecutionException(
                        'Error executing ' + name + ' function: the value ' + value + ' is not a number.'
                    );
                }

                if (result == null) {
                    result = (Decimal) value;
                } else {
                    if (name == 'MAX') {
                        result = Math.max(result, (Decimal) value);
                    } else {
                        result = Math.min(result, (Decimal) value);
                    }
                }
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.atLeast(1);
        }
    }

    private class RoundAndTruncFns extends ExpressionFunction {
        private final String name;

        public RoundAndTruncFns(String name) {
            this.name = name;
        }

        public override Object call(List<Expr> arguments) {
            Object numberValue = evaluate(arguments.get(0));
            if (!(numberValue instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing ' + name + ' function: the argument must evaluate to a number value.'
                );
            }

            Decimal precision = 0;
            if (arguments.size() > 1) {
                Object precisionValue = evaluate(arguments.get(1));
                if (!(precisionValue instanceof Decimal)) {
                    throw new FunctionExecutionException(
                        'Error executing ' + name + ' function: the second argument must evaluate to a number value.'
                    );
                }
                precision = (Decimal) precisionValue;
            }

            if (name == 'ROUND') {
                return ((Decimal) numberValue).setScale(precision.intValue(), RoundingMode.HALF_UP);
            } else {
                return ((Decimal) numberValue).setScale(precision.intValue(), RoundingMode.DOWN);
            }
        }

        public override Arity getArity() {
            return Arity.atLeast(1);
        }
    }

    private class ModFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object dividendValue = evaluate(arguments.get(0));
            if (!(dividendValue instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "MOD" function: the first argument must evaluate to a number value.'
                );
            }

            Object divisorValue = evaluate(arguments.get(1));
            if (!(divisorValue instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "MOD" function: the second argument must evaluate to a number value.'
                );
            }

            return Math.mod(Integer.valueOf(dividendValue), Integer.valueOf(divisorValue));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
