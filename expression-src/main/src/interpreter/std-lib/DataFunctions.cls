/**
 * @description Repository of functions that can be used in expressions.
 * @group Data
 * @function-repository true
 * @display-icon utility:data_mapping
 */
public with sharing class DataFunctions {
    private static final Map<String, StandardFunction> FUNCTIONS = new Map<String, StandardFunction>{
        'TRANSFORM' => new TransformFn(),
        'LET' => new LET(),
        'RAWQUERY' => new RawQuery(),
        'PRINT' => new PrintFn(),
        'PARSEJSON' => new ParseJsonFn()
    };

    public class DataFunctionsProvider implements FunctionProvider {
        public Map<String, StandardFunction> getFunctions() {
            return FUNCTIONS;
        }
    }

    /**
     * @description Transforms any input using the provided expression.
     * Provides a special variable `$source` in the inner expression that contains the original input.
     *
     * Accepts 2 arguments: the input to transform and the expression to evaluate.
     * @function TRANSFORM
     * @example TRANSFORM("Hello World", UPPER($source)) // "HELLO WORLD"
     */
    private class TransformFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object sourceObj = evaluate(arguments.get(0));
            Environment env = new Environment();
            env.define('$source', sourceObj);
            Interpreter interpreter = new Interpreter(env);
            return interpreter.interpret(arguments.get(1));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Allows you to define custom variables that can be used in the expression.
     * Accepts 2 arguments: a map of variables to define and the expression to evaluate.
     * The map keys should be the variable names prefixed with `$`.
     * @function LET
     * @example LET({ "$a": 1, "$b": 2 }, $a + $b) // 3
     */
    private class LET extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            // First argument should be a map
            Object left = evaluate(arguments.get(0));
            if (!(left instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException('First argument to LET must be a map');
            }

            for (Object key : ((Map<Object, Object>) left).keySet()) {
                if (!(key instanceof String)) {
                    throw new FunctionExecutionException('Keys in map passed to LET must be strings');
                }

                String keyStr = (String) key;
                if (!keyStr.startsWith('$')) {
                    throw new FunctionExecutionException('Custom variables created through LET must start with $');
                }

                Environment.addGlobalVariable(keyStr, ((Map<Object, Object>) left).get(key));
            }

            // Second argument is any expression
            return evaluate(arguments.get(1));
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Allows you to run a raw query against the database.
     * Accepts 1 argument: the query to run.
     * @function RAWQUERY
     * @example RAWQUERY("SELECT Id, Name FROM Account LIMIT 10")
     */
    private class RawQuery extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object queryObj = (String) evaluate(arguments.get(0));
            if (!(queryObj instanceof String)) {
                throw new FunctionExecutionException('First argument to RAW_QUERY must be a string');
            }
            String query = (String) queryObj;
            return QDB.getInstance().runRaw(query);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    /**
     * @description Allows you to print a value to the playground console.
     * Accepts 1 argument: the value to print.
     * @function PRINT
     * @example PRINT("Hello World")
     */
    private class PrintFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object toPrint = evaluate(arguments.get(0));
            Printer.instance.print(toPrint);
            return toPrint;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    /**
     * @description Parses a JSON string into a usable map/object structure.
     * Accepts 1 argument: the JSON string to parse.
     * @function PARSEJSON
     * @example PARSEJSON("{\"name\":\"John\",\"age\":30}") // Returns a map with keys "name" and "age"
     * @example PARSEJSON(Contact.Custom_JSON_Field__c) // Parses JSON from a field
     */
    public class ParseJsonFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            // Get the first argument and evaluate it
            Object jsonInput = evaluate(arguments.get(0));
            
            // Validate the input is a string
            if (!(jsonInput instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "PARSEJSON" function: the argument must evaluate to a string value.'
                );
            }
            
            String jsonStr = (String) jsonInput;
            
            try {
                // Parse the JSON string and convert it to a Map<Object, Object>
                Object deserializedObj = JSON.deserializeUntyped(jsonStr);
                
                // If it's not a map, wrap it in a map with a "value" key
                if (!(deserializedObj instanceof Map<String, Object>)) {
                    Map<Object, Object> wrappedMap = new Map<Object, Object>();
                    wrappedMap.put('value', deserializedObj);
                    return wrappedMap;
                }
                
                // Convert Map<String, Object> to Map<Object, Object> for compatibility
                Map<String, Object> typedMap = (Map<String, Object>)deserializedObj;
                Map<Object, Object> resultMap = new Map<Object, Object>();
                
                for (String key : typedMap.keySet()) {
                    Object value = typedMap.get(key);
                    // Recursively convert nested maps
                    if (value instanceof Map<String, Object>) {
                        value = convertToObjectMap((Map<String, Object>)value);
                    } else if (value instanceof List<Object>) {
                        value = convertListContents((List<Object>)value);
                    }
                    resultMap.put(key, value);
                }
                
                return resultMap;
            } catch (Exception e) {
                throw new FunctionExecutionException(
                    'Error executing "PARSEJSON" function: Invalid JSON format. ' + e.getMessage()
                );
            }
        }
        
        private Map<Object, Object> convertToObjectMap(Map<String, Object> typedMap) {
            Map<Object, Object> resultMap = new Map<Object, Object>();
            
            for (String key : typedMap.keySet()) {
                Object value = typedMap.get(key);
                // Recursively convert nested maps
                if (value instanceof Map<String, Object>) {
                    value = convertToObjectMap((Map<String, Object>)value);
                } else if (value instanceof List<Object>) {
                    value = convertListContents((List<Object>)value);
                }
                resultMap.put(key, value);
            }
            
            return resultMap;
        }
        
        private List<Object> convertListContents(List<Object> typedList) {
            List<Object> resultList = new List<Object>();
            
            for (Object item : typedList) {
                if (item instanceof Map<String, Object>) {
                    resultList.add(convertToObjectMap((Map<String, Object>)item));
                } else if (item instanceof List<Object>) {
                    resultList.add(convertListContents((List<Object>)item));
                } else {
                    resultList.add(item);
                }
            }
            
            return resultList;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }
}