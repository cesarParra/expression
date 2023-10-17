public with sharing class CollectionFunctions {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'LIST' => new ListFn(),
        'MAP' => new MapFn(),
        'WHERE' => new WhereFn(),
        'AVERAGE' => new AverageFn(),
        'SIZE' => new SizeFn(),
        'ISEMPTY' => new IsEmptyFn(),
        'APPEND' => new AppendFn(),
        'SORT' => new SortFn(),
        'DISTINCT' => new DistinctFn(),
        'KEYS' => new KeysFn(),
        'GET' => new GetFn(),
        'VALUES' => new ValuesFn(),
        'FETCH' => new FetchFn(),
        'FIRST' => new FirstFn(),
        'LAST' => new LastFn(),
        'REDUCE' => new ReduceFn(),
        'PUT' => new PutFn(),
        'AT' => new AtFn(),
        'ANY' => new AnyFn(),
        'SUM' => new SumFn(),
        'EVERY' => new EveryFn(),
        'EXPAND' => new ExpandFn(),
        'FIRSTWHERE' => new FirstWhereFn(),
        'FOLLOWEDBY' => new FollowedByFn()
    };

    private static Environment getEnvironmentFromObject(Object currentVal) {
        Environment env;
        if (currentVal instanceof SObject) {
            env = new Environment((SObject) currentVal);
        } else {
            env = new Environment(null);
        }
        return env;
    }

    private class ListFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            interpreter.setIsInListLiteral(true);

            List<Object> result = new List<Object>();
            for (Expr argument : arguments) {
                Object item = evaluate(argument);
                if (item instanceof Interpreter.ListSpreadContents) {
                    result.addAll(((Interpreter.ListSpreadContents) item).contents);
                } else {
                    result.add(item);
                }
            }

            return result;
        }

        public override Arity getArity() {
            return Arity.atLeast(1);
        }
    }

    private class MapFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "MAP" function: the first argument must evaluate to a list.'
                );
            }

            // If the list of children is empty, return early
            List<Object> childrenAsList = (List<Object>) children;
            if (childrenAsList.isEmpty()) {
                return new List<Object>();
            }

            // For all children we want to evaluate the subexpression.
            // Each one of the children will now act as a standalone context for a new expression.
            Expr secondArgument = arguments.get(1);
            List<Object> result = new List<Object>();
            for (Integer i = 0; i < childrenAsList.size(); i++) {
                Object child = childrenAsList.get(i);
                Environment env = getEnvironmentFromObject(child);
                env.define('$current', child);
                env.define('$index', i);
                env.define('$total', childrenAsList.size());

                Interpreter interpreter = new Interpreter(env);
                result.add(interpreter.interpret(secondArgument));
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }
    }

    private class WhereFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "WHERE" function: the first argument must evaluate to a list.'
                );
            }

            // If the list of children is empty, return early
            List<Object> childrenAsList = (List<Object>) children;
            if (childrenAsList.isEmpty()) {
                return new List<Object>();
            }

            // For all children we want to evaluate the subexpression.
            // Each one of the children will now act as a standalone context for a new expression.
            Expr secondArgument = arguments.get(1);
            List<Object> result = new List<Object>();
            for (Integer i = 0; i < childrenAsList.size(); i++) {
                Object child = childrenAsList.get(i);
                Environment env = getEnvironmentFromObject(child);

                env.define('$current', child);
                env.define('$index', i);
                env.define('$total', childrenAsList.size());

                Interpreter interpreter = new Interpreter(env);
                Object evaluated = interpreter.interpret(secondArgument);
                if (evaluated instanceof Boolean) {
                    if ((Boolean) evaluated) {
                        result.add(child);
                    }
                } else {
                    throw new FunctionExecutionException(
                        'Error executing "WHERE" function: the second argument must evaluate to a boolean.'
                    );
                }
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }
    }

    private class AverageFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfNumbers = evaluate(arguments.get(0));

            // Verify that all elements in the list are numbers
            if (!(listOfNumbers instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "AVERAGE" function: the argument must evaluate to a list of numbers.'
                );
            }

            List<Object> listOfNumbersAsList = (List<Object>) listOfNumbers;
            // Sanitize nulls
            List<Object> sanitizedList = new List<Object>();
            for (Object maybeNull : listOfNumbersAsList) {
                if (maybeNull != null) {
                    sanitizedList.add(maybeNull);
                }
            }
            for (Object maybeNumber : sanitizedList) {
                if (!(maybeNumber instanceof Decimal)) {
                    throw new FunctionExecutionException(
                        'Error executing "AVERAGE" function: the argument must evaluate to a list of numbers.'
                    );
                }
            }

            // Calculate the average
            Decimal sum = 0;
            for (Object numberValue : sanitizedList) {
                sum += (Decimal) numberValue;
            }

            return sum / sanitizedList.size();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class SizeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfValues = evaluate(arguments.get(0));
            // Must be a list or a map
            if (!(listOfValues instanceof List<Object>) && !(listOfValues instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SIZE" function: the argument must evaluate to a list or a map.'
                );
            }

            if (listOfValues instanceof List<Object>) {
                return ((List<Object>) listOfValues).size();
            } else {
                return ((Map<Object, Object>) listOfValues).size();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class IsEmptyFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The argument must either be a list or a map
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof List<Object>) && !(value instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "ISEMPTY" function: the argument must evaluate to a list or a map.'
                );
            }

            if (value instanceof List<Object>) {
                return ((List<Object>) value).isEmpty();
            } else {
                return ((Map<Object, Object>) value).isEmpty();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class AppendFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            Object item = evaluate(arguments.get(1));
            if (listObj == null) {
                listObj = new List<Object>();
            }
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "APPEND" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> result = new List<Object>((List<Object>) listObj);
            result.add(item);
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class DistinctFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "DISTINCT" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> result = new List<Object>((List<Object>) listObj);
            List<Object> distinct = new List<Object>();
            for (Object obj : result) {
                if (!distinct.contains(obj)) {
                    distinct.add(obj);
                }
            }
            return distinct;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class KeysFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object mapObj = evaluate(arguments.get(0));
            if (!(mapObj instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "KEYS" function: the first argument must evaluate to a map.'
                );
            }
            return new List<Object>(((Map<Object, Object>) mapObj).keySet());
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class GetFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object mapObj = evaluate(arguments.get(0));
            Object key = evaluate(arguments.get(1));

            // Should evaluate to either a map or an SObject
            if (!(mapObj instanceof Map<Object, Object>) && !(mapObj instanceof SObject)) {
                throw new FunctionExecutionException(
                    'Error executing "GET" function: the first argument must evaluate to a map or an SObject.'
                );
            }

            if ((mapObj instanceof Map<Object, Object>)) {
                return ((Map<Object, Object>) mapObj).get(key);
            } else {
                return ((SObject) mapObj).get((String) key);
            }
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class ValuesFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object mapObj = evaluate(arguments.get(0));
            if (!(mapObj instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "VALUES" function: the first argument must evaluate to a map.'
                );
            }
            return ((Map<Object, Object>) mapObj).values();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private with sharing class FetchFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a string representing the sobject type name
            Object sobjectType = evaluate(arguments.get(0));
            if (!(sobjectType instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "FETCH" function: the first argument must evaluate to a string.'
                );
            }

            // Second argument is a list of strings representing the field names
            Object fieldNames = evaluate(arguments.get(1));
            if (!(fieldNames instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "FETCH" function: the second argument must evaluate to a list of strings.'
                );
            }

            Q query = new Q((String) sobjectType);
            for (Object fieldName : (List<Object>) fieldNames) {
                if (!(fieldName instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "FETCH" function: the second argument must evaluate to a list of strings.'
                    );
                }
                query.selectField((String) fieldName);
            }

            return QRunner.getInstance().run(query);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class SortFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SORT" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is optional, describes the field to sort by. This can only
            // be used when dealing with a list of maps or sobjects.
            // It can either be a string literal or a merge field.
            Object fieldToSortBy = null;
            if (arguments.size() > 1) {
                Expr fieldToSortByExpr = arguments.get(1);
                if (fieldToSortByExpr instanceof Expr.MergeField) {
                    // If dealing with a merge field, we don't want to evaluate it since we are not interested
                    // in the value. Instead we want to use the name of the field as a string.
                    fieldToSortBy = ((Expr.MergeField) fieldToSortByExpr).name.lexeme;
                } else {
                    fieldToSortBy = evaluate(fieldToSortByExpr);
                }
                if (!(fieldToSortBy instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "SORT" function: the second argument must be a merge field or evaluate to a string.'
                    );
                }
            }

            // Third argument is optional, describes the direction to sort by. This can only
            // be used when dealing with a list of maps or sobjects.
            Object direction = null;
            if (arguments.size() > 2) {
                direction = evaluate(arguments.get(2));
                if (!(direction instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "SORT" function: the third argument must evaluate to a string.'
                    );
                }

                // Expect the string to be either 'ASC' or 'DESC'
                if (!((String) direction).equalsIgnoreCase('ASC') && !((String) direction).equalsIgnoreCase('DESC')) {
                    throw new FunctionExecutionException(
                        'Error executing "SORT" function: the third argument must be either "ASC" or "DESC".'
                    );
                }
            }

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return listVal;
            }

            // If no extra arguments were provided, just sort the list
            if (fieldToSortBy == null && direction == null) {
                listVal.sort();
                return listVal;
            }

            // If each element in the list is a map, sort by the field
            if (listVal.get(0) instanceof Map<Object, Object>) {
                return doSort(listVal, (String) fieldToSortBy, (String) direction);
            }

            // If each element in the list is an sobject, sort by the field
            if (listVal.get(0) instanceof SObject) {
                return doSort(listVal, (String) fieldToSortBy, (String) direction);
            }

            // Otherwise, throw an error
            throw new FunctionExecutionException(
                'Error executing "SORT" function: the first argument must evaluate to a list of maps or sobjects.'
            );
        }

        public override Arity getArity() {
            return Arity.between(1, 3);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }

        private List<Object> doSort(List<Object> listVal, String fieldToSortBy, String direction) {
            List<ComparableMaps> comparableMaps = new List<ComparableMaps>();
            // There seems to be an Apex bug where maps with null keys are not sorted properly when calling
            // sort, so we need to skip them and put them at the end of the list manually.
            List<ComparableMaps> skippedToPutAtTheEnd = new List<ComparableMaps>();
            for (Object currentVal : listVal) {
                if (currentVal instanceof Map<Object, Object>) {
                    Map<Object, Object> mapVal = (Map<Object, Object>) currentVal;
                    if (!mapVal.containsKey(fieldToSortBy)) {
                        skippedToPutAtTheEnd.add(new ComparableMaps(mapVal, fieldToSortBy));
                        continue;
                    }
                } else {
                    SObject sobjectVal = (SObject) currentVal;
                    if (sobjectVal.get(fieldToSortBy) == null) {
                        skippedToPutAtTheEnd.add(new ComparableMaps(sobjectVal, fieldToSortBy));
                        continue;
                    }
                }

                comparableMaps.add(new ComparableMaps(currentVal, fieldToSortBy));
            }
            comparableMaps.sort();
            comparableMaps.addAll(skippedToPutAtTheEnd);

            if (direction != null && direction.equalsIgnoreCase('DESC')) {
                comparableMaps = reverse(comparableMaps);
            }
            List<Object> result = new List<Object>();
            for (ComparableMaps comparableMap : comparableMaps) {
                result.add(comparableMap.mapOrSObjectVal);
            }
            return result;
        }

        private List<ComparableMaps> reverse(List<ComparableMaps> listVal) {
            List<ComparableMaps> result = new List<ComparableMaps>();
            for (Integer i = listVal.size() - 1; i >= 0; i--) {
                result.add(listVal.get(i));
            }
            return result;
        }
    }

    private class ComparableMaps implements Comparable {
        private final Object mapOrSObjectVal;
        private final Object keyToSortBy;

        public ComparableMaps(Object mapOrSObjectVal, Object keyToSortBy) {
            this.mapOrSObjectVal = mapOrSObjectVal;
            this.keyToSortBy = keyToSortBy;
        }

        public Integer compareTo(Object param1) {
            if (param1 instanceof ComparableMaps) {
                if (mapOrSObjectVal instanceof Map<Object, Object>) {
                    return compareToAsMaps((Map<Object, Object>) mapOrSObjectVal, param1);
                } else {
                    return compareToAsSObjects((SObject) mapOrSObjectVal, param1);
                }
            }
            return 0;
        }

        private Integer compareToAsMaps(Map<Object, Object> mapVal, Object param1) {
            Object thisValue = mapVal.get(keyToSortBy);
            ComparableMaps other = (ComparableMaps) param1;
            Object otherValue = ((Map<Object, Object>)other.mapOrSObjectVal).get(keyToSortBy);

            if (thisValue == otherValue) {
                return 0;
            }

            List<Object> values = new List<Object>{thisValue, otherValue};
            values.sort();
            if (values.get(0) == thisValue) {
                return -1;
            }
            return 1;
        }

        private Integer compareToAsSObjects(SObject sobjectVal, Object param1) {
            Object thisValue = sobjectVal.get((String)keyToSortBy);
            ComparableMaps other = (ComparableMaps) param1;
            Object otherValue = ((SObject)other.mapOrSObjectVal).get((String)keyToSortBy);

            if (thisValue == otherValue) {
                return 0;
            }

            List<Object> values = new List<Object>{thisValue, otherValue};
            values.sort();
            if (values.get(0) == thisValue) {
                return -1;
            }
            return 1;
        }
    }

    private class FirstFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "FIRST" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return null;
            }
            return listVal.get(0);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class LastFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "LAST" function: the first argument must evaluate to a list.'
                );
            }
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return null;
            }
            return listVal.get(listVal.size() - 1);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class ReduceFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "REDUCE" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // Third argument is an initial value
            Object initialValue = evaluate(arguments.get(2));

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return initialValue;
            }

            // Loop through each element in the list, evaluating the
            // expression with the current value (as $current) being looped
            // through and the accumulator (as $accumulator)
            // The result of the expression will be the new value.
            Object accumulator = initialValue;
            for (Object currentVal : listVal) {
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                env.define('$accumulator', accumulator);
                Interpreter interpreter = new Interpreter(env);
                accumulator = interpreter.interpret(expr);
            }
            return accumulator;
        }

        public override Arity getArity() {
            return Arity.exactly(3);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }
    }

    private class PutFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a map
            Object mapObj = evaluate(arguments.get(0));
            if (!(mapObj instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "PUT" function: the first argument must evaluate to a map.'
                );
            }

            // Second argument is the key
            Object key = evaluate(arguments.get(1));

            // Third argument is a value
            Object value = evaluate(arguments.get(2));

            // Create a new map with the new key/value pair included
            Map<Object, Object> mapVal = (Map<Object, Object>) mapObj;
            Map<Object, Object> result = new Map<Object, Object>(mapVal);
            result.put(key, value);
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(3);
        }
    }

    private class AtFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "AT" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an index
            Object index = evaluate(arguments.get(1));
            if (!(index instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "AT" function: the second argument must evaluate to an number.'
                );
            }

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return null;
            }

            // If the index is out of bounds, return null
            Decimal indexVal = (Decimal) index;
            if (indexVal < 0 || indexVal >= listVal.size()) {
                return null;
            }

            return listVal.get(indexVal.intValue());
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class AnyFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "ANY" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return false;
            }

            // Loop through each element in the list, evaluating the
            // expression with the current value (as $current) being looped.
            for (Object currentVal : listVal) {
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                Interpreter interpreter = new Interpreter(env);
                Object result = interpreter.interpret(expr);
                if (result instanceof Boolean) {
                    if ((Boolean) result) {
                        return true;
                    }
                } else {
                    throw new FunctionExecutionException(
                        'Error executing "ANY" function: the second argument must evaluate to a boolean.'
                    );
                }
            }

            return false;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class SumFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SUM" function: the first argument must evaluate to a list.'
                );
            }

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return 0;
            }

            Decimal sum = 0;
            for (Object currentVal : listVal) {
                if (!(currentVal instanceof Decimal)) {
                    throw new FunctionExecutionException(
                        'Error executing "SUM" function: the first argument must evaluate to a list of numbers.'
                    );
                }
                sum += (Decimal) currentVal;
            }
            return sum;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class EveryFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "EVERY" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return false;
            }

            // Loop through each element in the list, evaluating the
            // expression with the current value (as $current) being looped.
            for (Object currentVal : listVal) {
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                Interpreter interpreter = new Interpreter(env);
                Object result = interpreter.interpret(expr);
                if (result instanceof Boolean) {
                    if (!(Boolean) result) {
                        return false;
                    }
                } else {
                    throw new FunctionExecutionException(
                        'Error executing "EVERY" function: the second argument must evaluate to a boolean.'
                    );
                }
            }

            return true;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class ExpandFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "EXPAND" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return new List<Object>();
            }

            // Loop through each element in the list, evaluating the
            // expression with the current value (as $current) being looped.
            List<Object> result = new List<Object>();
            for (Object currentVal : listVal) {
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                Interpreter interpreter = new Interpreter(env);
                Object evaluated = interpreter.interpret(expr);

                // The evaluated expression must be a list.
                if (!(evaluated instanceof List<Object>)) {
                    throw new FunctionExecutionException(
                        'Error executing "EXPAND" function: the second argument must evaluate to a list.'
                    );
                }

                // Add the evaluated list to the result
                result.addAll((List<Object>) evaluated);
            }

            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class FirstWhereFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "FIRSTWHERE" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // If the list is empty, return early
            List<Object> listVal = (List<Object>) listObj;
            if (listVal.isEmpty()) {
                return null;
            }

            // Loop through each element in the list, evaluating the
            // expression with the current value (as $current) being looped.
            for (Object currentVal : listVal) {
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                Interpreter interpreter = new Interpreter(env);
                Object result = interpreter.interpret(expr);
                if (result instanceof Boolean) {
                    if ((Boolean) result) {
                        return currentVal;
                    }
                } else {
                    throw new FunctionExecutionException(
                        'Error executing "FIRSTWHERE" function: the second argument must evaluate to a boolean.'
                    );
                }
            }

            return null;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class FollowedByFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "FOLLOWEDBY" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is a list
            Object listObj2 = evaluate(arguments.get(1));
            if (!(listObj2 instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "FOLLOWEDBY" function: the second argument must evaluate to a list.'
                );
            }

            // Append the second list to the first list
            List<Object> listVal = (List<Object>) listObj;
            List<Object> listVal2 = (List<Object>) listObj2;
            List<Object> result = new List<Object>(listVal);
            result.addAll(listVal2);
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
