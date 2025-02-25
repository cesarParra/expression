/**
 * @description Repository of functions that can be used in expressions.
 * @group Math
 * @function-repository true
 * @display-icon utility:advanced_function
 */
public with sharing class MathFunctions {
    private static final Map<String, StandardFunction> FUNCTIONS = new Map<String, StandardFunction>{
        'ABS' => new AbsFn(),
        'CEILING' => new CeilingFn(),
        'FLOOR' => new FloorFn(),
        'MAX' => new MaxFn(),
        'MIN' => new MinFn(),
        'ROUND' => new RoundFn(),
        'TRUNC' => new TruncFn(),
        'MOD' => new ModFn()
    };

    public class MathFunctionsProvider implements FunctionProvider {
        public Map<String, StandardFunction> getFunctions() {
            return FUNCTIONS;
        }
    }

    /**
     * @description Returns the absolute value of a number.
     *
     * Accepts 1 argument: the number to evaluate.
     * @function ABS
     * @example
     * ABS(-1) // 1
     */
    private class AbsFn extends StandardFunction {
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

    /**
     * @description Returns the smallest integer greater than or equal to the specified number.
     *
     * Accepts 1 argument: the number to evaluate.
     * @function CEILING
     * @example
     * CEILING(1.5) // 2
     */
    private class CeilingFn extends StandardFunction {
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

    /**
     * @description Returns the largest integer less than or equal to the specified number.
     *
     * Accepts 1 argument: the number to evaluate.
     * @function FLOOR
     * @example
     * FLOOR(1.5) // 1
     */
    private class FloorFn extends StandardFunction {
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

    private virtual class MaxMixFns extends StandardFunction {
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

    /**
     * @description Returns the largest value in a list of numbers.
     *
     * Accepts either a list of numbers as a single argument, or multiple numerical arguments.
     * @function MAX
     * @example
     * MAX(1, 2, 3) // 3
     * MAX([1, 2, 3]) // 3
     */
    private class MaxFn extends MaxMixFns {
        public MaxFn() {
            super('MAX');
        }
    }

    /**
     * @description Returns the smallest value in a list of numbers.
     *
     * Accepts either a list of numbers as a single argument, or multiple numerical arguments.
     * @function MIN
     * @example
     * MIN(1, 2, 3) // 1
     * MIN([1, 2, 3]) // 1
     */
    private class MinFn extends MaxMixFns {
        public MinFn() {
            super('MIN');
        }
    }

    private virtual class RoundAndTruncFns extends StandardFunction {
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

    /**
     * @description Returns a rounded number. Optionally specify the number of decimal places to round to.
     *
     * Accepts 1 or 2 arguments: the number to round and optionally the number of decimal places to round to.
     * @function ROUND
     * @example
     * ROUND(1.234) // 1
     * ROUND(1.234, 2) // 1.23
     */
    private class RoundFn extends RoundAndTruncFns {
        public RoundFn() {
            super('ROUND');
        }
    }

    /**
     * @description Returns a truncated number. Optionally specify the number of decimal places to truncate to.
     *
     * Accepts 1 or 2 arguments: the number to truncate and optionally the number of decimal places to truncate to.
     * @function TRUNC
     * @example
     * TRUNC(1.234) // 1
     * TRUNC(1.234, 2) // 1.23
     */
    private class TruncFn extends RoundAndTruncFns {
        public TruncFn() {
            super('TRUNC');
        }
    }

    /**
     * @description Returns the remainder of one number divided by another.
     *
     * Accepts 2 arguments: the dividend and the divisor.
     * @function MOD
     * @example
     * MOD(5, 2) // 1
     */
    private class ModFn extends StandardFunction {
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
