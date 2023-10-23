/**
 * @description Repository of functions that can be used in expressions.
 * @group Location
 * @function-repository true
 * @display-icon utility:pin
 */
public with sharing class LocationFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'LOCATION' => new LocationFn(),
        'DISTANCE' => new DistanceFn()
    };

    public class LocationFunctionsProvider implements FunctionProvider {
        public String getCategory() {
            return 'Location';
        }

        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }

        public String getIcon() {
            return 'utility:pin';
        }
    }

    /**
     * @description Returns a location object from the provided latitude and longitude.
     *
     * Accepts 2 arguments: the latitude and longitude.
     * @function LOCATION
     * @example
     * LOCATION(37.7749, 122.4194) // { "latitude": 37.7749, "longitude": 122.4194 }
     */
    private class LocationFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Argument must be a Decimal
            Object latitude = evaluate(arguments.get(0));
            if (!(latitude instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "LOCATION" function: the argument must evaluate to a DECIMAL.'
                );
            }

            // Argument must be a Decimal
            Object longitude = evaluate(arguments.get(1));
            if (!(longitude instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "LOCATION" function: the argument must evaluate to a DECIMAL.'
                );
            }

            return Location.newInstance((Decimal)latitude, (Decimal)longitude);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Returns the distance between two locations in the specified unit.
     *
     * Accepts 3 arguments: the first location, the second location, and the unit (either
     * `"mi"` or `"km"`).
     * @function DISTANCE
     * @example
     * DISTANCE(LOCATION(37.7749, 122.4194), LOCATION(40.7128, 74.0060), "mi") // 2565.6985207767134
     */
    private class DistanceFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First object must be a System.Location
            Object first = evaluate(arguments.get(0));
            if (!(first instanceof System.Location)) {
                throw new FunctionExecutionException(
                    'Error executing "DISTANCE" function: the first argument must evaluate to a LOCATION.'
                );
            }

            // Second object must be a System.Location
            Object second = evaluate(arguments.get(1));
            if (!(second instanceof System.Location)) {
                throw new FunctionExecutionException(
                    'Error executing "DISTANCE" function: the second argument must evaluate to a LOCATION.'
                );
            }

            // Third argument must be a string
            Object third = evaluate(arguments.get(2));
            if (!(third instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "DISTANCE" function: the third argument must evaluate to a STRING.'
                );
            }

            // The third argument must either be "km" or "mi"
            String unit = (String)third;
            if (!unit.equals('km') && !unit.equals('mi')) {
                throw new FunctionExecutionException(
                    'Error executing "DISTANCE" function: the third argument must be either "km" or "mi".'
                );
            }

            return Location.getDistance((System.Location)first, (System.Location)second, unit);
        }

        public override Arity getArity() {
            return Arity.exactly(3);
        }
    }
}
