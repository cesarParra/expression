/**
 * @description Repository of functions that can be used in expressions.
 * @group Collection
 * @function-repository true
 * @display-icon utility:justify_text
 */
public with sharing class CollectionFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
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
        'FOLLOWEDBY' => new FollowedByFn(),
        'JOIN' => new JoinFn(),
        'LASTWHERE' => new LastWhereFn(),
        'SKIP' => new SkipFn(),
        'SKIPWHILE' => new SkipWhileFn(),
        'TAKE' => new TakeFn(),
        'TAKEWHILE' => new TakeWhileFn(),
        'RANGE' => new RangeFn()
    };

    public class CollectionFunctionsProvider implements FunctionProvider {
        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }
    }

    private static Environment getEnvironmentFromObject(Object currentVal) {
        Environment env;
        if (currentVal instanceof SObject) {
            env = new Environment((SObject) currentVal);
        } else {
            env = new Environment(null);
        }
        return env;
    }

    /**
     * @description Creates a list using the received arguments as the values.
     * @function LIST
     * @example
     * LIST(1, 2, 3, ...LIST(4, 5, 6))
     */
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
            return Arity.atLeast(0);
        }
    }

    /**
     * @description Maps to a list using the first argument as the context and the second argument as the expression to evaluate.
     * Accepts 2 arguments: List of objects and an expression to evaluate.
     * @function MAP
     * @example
     * MAP(["a", "b", "c"], UPPER($current))
     */
    private class MapFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "MAP" function: the first argument must evaluate to an iterable.'
                );
            }

            List<Object> childrenAsList = CollectionUtils.toObjectList((Iterable<Object>) children);

            // If the list of children is empty, return early
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

    /**
     * @description
     * Filters a list using the first argument as the context and the second argument as the expression to evaluate.
     * Accepts 2 arguments: List of objects and an expression to evaluate.
     * @function WHERE
     * @example
     * WHERE([1, 2, 3], $current > 1)
     */
    private class WhereFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object children = evaluate(arguments.get(0));
            if (children == null) {
                return new List<Object>();
            }
            if (!(children instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "WHERE" function: the first argument must evaluate to an iterable.'
                );
            }

            // If the list of children is empty, return early
            List<Object> childrenAsList = CollectionUtils.toObjectList((Iterable<Object>) children);
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

    /**
     * @description Returns the average given a list of numbers.
     * Accepts 1 argument: the list of numbers to evaluate.
     * @function AVERAGE
     * @example
     * AVERAGE(LIST(1, 2, 3))
     */
    private class AverageFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfNumbers = evaluate(arguments.get(0));

            // Verify that all elements in the list are numbers
            if (!(listOfNumbers instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "AVERAGE" function: the argument must evaluate to an iterable of numbers.'
                );
            }

            List<Object> listOfNumbersAsList = CollectionUtils.toObjectList((Iterable<Object>) listOfNumbers);
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

    /**
     * @description Returns the number of elements in a list or map.
     * Accepts 1 argument: the list or map to evaluate.
     * @function SIZE
     * @example
     * SIZE(LIST(1, 2, 3)) // 3
     */
    private class SizeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listOfValues = evaluate(arguments.get(0));
            // Must be a list or a map
            if (!(listOfValues instanceof Iterable<Object>) && !(listOfValues instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SIZE" function: the argument must evaluate to an iterable or a map.'
                );
            }

            if (listOfValues instanceof Iterable<Object>) {
                return CollectionUtils.toObjectList((Iterable<Object>) listOfValues).size();
            } else {
                return ((Map<Object, Object>) listOfValues).size();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    /**
     * @description Returns true if the list or map is empty.
     * Accepts 1 argument: the list or map to evaluate.
     * @function ISEMPTY
     * @example
     * ISEMPTY(LIST(1, 2, 3)) // false
     */
    private class IsEmptyFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The argument must either be a list or a map
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof Iterable<Object>) && !(value instanceof Map<Object, Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "ISEMPTY" function: the argument must evaluate to an iterable or a map.'
                );
            }

            if (value instanceof Iterable<Object>) {
                return CollectionUtils.toObjectList((Iterable<Object>) value).isEmpty();
            } else {
                return ((Map<Object, Object>) value).isEmpty();
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    /**
     * @description Appends an item to a list.
     * Accepts 2 arguments: the list and the item to append.
     * @function APPEND
     * @example
     * APPEND(LIST(1, 2, 3), 4) // [1, 2, 3, 4]
     */
    private class AppendFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object listObj = evaluate(arguments.get(0)) ?? new List<Object>();
            Object item = evaluate(arguments.get(1));
            if (!(listObj instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "APPEND" function: the first argument must evaluate to an iterable.'
                );
            }
            List<Object> result = CollectionUtils.toObjectList((Iterable<Object>) listObj);
            result.add(item);
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Returns a list of unique values.
     * @function DISTINCT
     * @example
     * DISTINCT(LIST(1, 2, 3, 1, 2, 3)) // [1, 2, 3]
     */
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

    /**
     * @description Returns a list of keys in a map.
     * @function KEYS
     * @example
     * KEYS(MAP('a' => 1, 'b' => 2, 'c' => 3)) // ['a', 'b', 'c']
     */
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

    /**
     * @description Returns the value of a key in a map or the field in an SObject.
     * Accepts 2 arguments: the map or SObject to evaluate and the key to get.
     * @function GET
     * @example
     * GET(MAP('a' => 1, 'b' => 2, 'c' => 3), 'a') // 1
     */
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

    /**
     * @description Returns a list of values in a map.
     * @function VALUES
     * @example
     * VALUES(MAP('a' => 1, 'b' => 2, 'c' => 3)) // [1, 2, 3]
     */
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

    /**
     * @description Sorts a list.
     * Accepts at least one argument: the list to sort.
     * When sorting a list of Maps or a list of SObjects,
     * two additional arguments can be provided: the field to sort by and the sort direction.
     *
     * The field to sort can either be a field name as a merge field (field name without quotes), or an expression that evaluates to a string
     * representing the field name. Merge fields are only supported when sorting SObjects and are useful to get the framework to automatically
     * query the field for you.
     *
     * Note: The merge field must be a field on the SObject being sorted itself, not a relationship field.
     *
     * The sort direction can either be the literal string (requires quotes) `ASC` or `DESC`.
     * @function SORT
     * @example
      * SORT([{ "a": 3 }, { "a": 2 }, { "a": 1 }], "a", "DESC") // [{ "a": 3 }, { "a": 2 }, { "a": 1 }]   */
    private class SortFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SORT" function: the first argument must evaluate to an iterable.'
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

            // Forth argument is optional, describes whether to sort by nulls first or nulls last.
            Object evaluatedPosition;
            if (arguments.size() > 3) {
                evaluatedPosition = evaluate(arguments.get(3));
                if (!(evaluatedPosition instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "SORT" function: the forth argument must evaluate to a string.'
                    );
                }

                // Expect the string to be either 'NULLS_FIRST' or 'NULLS_LAST'
                if (!((String) evaluatedPosition).equalsIgnoreCase('NULLS_FIRST') && !((String) evaluatedPosition).equalsIgnoreCase('NULLS_LAST')) {
                    throw new FunctionExecutionException(
                        'Error executing "SORT" function: the forth argument must be either "NULLS_FIRST" or "NULLS_LAST".'
                    );
                }
            }

            String nullsPositionAsString = (String) evaluatedPosition;
            // If none is defined, default to NULLS_FIRST
            NullsPosition position = nullsPositionAsString == null ? NullsPosition.NULLS_FIRST :
                nullsPositionAsString.equalsIgnoreCase('NULLS_FIRST') ? NullsPosition.NULLS_FIRST : NullsPosition.NULLS_LAST;

            // If the list is empty, return early
            List<Object> listVal = CollectionUtils.toObjectList((Iterable<Object>) listObj);
            if (listVal.isEmpty()) {
                return listVal;
            }

            // If no extra arguments were provided, just sort the list
            if (fieldToSortBy == null && direction == null && evaluatedPosition == null) {
                listVal.sort();
                return listVal;
            }

            // If each element in the list is a map, sort by the field
            if (listVal.get(0) instanceof Map<Object, Object>) {
                return doSort(listVal, (String) fieldToSortBy, (String) direction, position);
            }

            // If each element in the list is an sobject, sort by the field
            if (listVal.get(0) instanceof SObject) {
                return doSort(listVal, (String) fieldToSortBy, (String) direction, position);
            }

            // Otherwise, throw an error
            throw new FunctionExecutionException(
                'Error executing "SORT" function: the first argument must evaluate to a list of maps or sobjects.'
            );
        }

        public override Arity getArity() {
            return Arity.between(1, 4);
        }

        public override Boolean needsChildrenResolution() {
            return true;
        }

        private List<Object> doSort(List<Object> listVal, String fieldToSortBy, String direction, NullsPosition position) {
            List<ComparableMaps> comparableMaps = new List<ComparableMaps>();
            // There seems to be an Apex bug where maps with null keys are not sorted properly when calling
            // sort, so we need to skip them and put them at the end of the list manually.
            List<ComparableMaps> skippedToPutAtTheEnd = new List<ComparableMaps>();
            for (Object currentVal : listVal) {
                if (currentVal instanceof Map<Object, Object>) {
                    Map<Object, Object> mapVal = (Map<Object, Object>) currentVal;
                    if (!mapVal.containsKey(fieldToSortBy)) {
                        skippedToPutAtTheEnd.add(new ComparableMaps(mapVal, fieldToSortBy, position));
                        continue;
                    }
                } else {
                    SObject sobjectVal = (SObject) currentVal;
                    if (sobjectVal.get(fieldToSortBy) == null) {
                        skippedToPutAtTheEnd.add(new ComparableMaps(sobjectVal, fieldToSortBy, position));
                        continue;
                    }
                }

                comparableMaps.add(new ComparableMaps(currentVal, fieldToSortBy, position));
            }
            comparableMaps.sort();
            comparableMaps.addAll(skippedToPutAtTheEnd);

            if (direction != null && direction.equalsIgnoreCase('DESC')) {
                comparableMaps = reverse(comparableMaps, position);
            }
            List<Object> result = new List<Object>();
            for (ComparableMaps comparableMap : comparableMaps) {
                result.add(comparableMap.mapOrSObjectVal);
            }
            return result;
        }

        private List<ComparableMaps> reverse(List<ComparableMaps> listVal, NullsPosition position) {
            List<ComparableMaps> reversed = new List<ComparableMaps>();
            List<ComparableMaps> nullValues = new List<ComparableMaps>();
            for (ComparableMaps comparableMap : listVal) {
                if (comparableMap.getValue() == null) {
                    nullValues.add(comparableMap);
                } else {
                    reversed.add(comparableMap);
                }
            }

            reversed = reverse(reversed);

            if (position == NullsPosition.NULLS_FIRST) {
                List<ComparableMaps> newList = new List<ComparableMaps>();
                newList.addAll(nullValues);
                newList.addAll(reversed);
                return newList;
            } else {
                List<ComparableMaps> newList = new List<ComparableMaps>();
                newList.addAll(reversed);
                newList.addAll(nullValues);
                return newList;
            }
        }

        private List<ComparableMaps> reverse(List<ComparableMaps> listVal) {
            List<ComparableMaps> result = new List<ComparableMaps>();
            for (Integer i = listVal.size() - 1; i >= 0; i--) {
                result.add(listVal.get(i));
            }
            return result;
        }
    }

    private enum NullsPosition {
        NULLS_FIRST,
        NULLS_LAST
    }

    private class ComparableMaps implements Comparable {
        private final Object mapOrSObjectVal;
        private final Object keyToSortBy;
        private final NullsPosition position;

        public ComparableMaps(Object mapOrSObjectVal, Object keyToSortBy, NullsPosition position) {
            this.mapOrSObjectVal = mapOrSObjectVal;
            this.keyToSortBy = keyToSortBy;
            this.position = position;
        }

        public Object getValue() {
            if (mapOrSObjectVal instanceof Map<Object, Object>) {
                return ((Map<Object, Object>) mapOrSObjectVal).get(keyToSortBy);
            } else {
                return ((SObject) mapOrSObjectVal).get((String) keyToSortBy);
            }
        }

        public Integer compareTo(Object param1) {
            if (param1 instanceof ComparableMaps) {
                if (mapOrSObjectVal instanceof Map<Object, Object>) {
                    return compareToAsMaps((Map<Object, Object>) mapOrSObjectVal, param1, position);
                } else {
                    return compareToAsSObjects((SObject) mapOrSObjectVal, param1);
                }
            }
            return 0;
        }

        private Integer compareToAsMaps(Map<Object, Object> mapVal, Object param1, NullsPosition position) {
            Object thisValue = mapVal.get(keyToSortBy);
            ComparableMaps other = (ComparableMaps) param1;
            Object otherValue = ((Map<Object, Object>) other.mapOrSObjectVal).get(keyToSortBy);

            if (thisValue == otherValue) {
                return 0;
            }

            if (thisValue == null) {
                return position == NullsPosition.NULLS_FIRST ? -1 : 1;
            }

            if (otherValue == null) {
                return position == NullsPosition.NULLS_FIRST ? 1 : -1;
            }

            List<Object> values = new List<Object>{
                thisValue, otherValue
            };
            values.sort();
            if (values.get(0) == thisValue) {
                return -1;
            }
            return 1;
        }

        private Integer compareToAsSObjects(SObject sobjectVal, Object param1) {
            Object thisValue = sobjectVal.get((String) keyToSortBy);
            ComparableMaps other = (ComparableMaps) param1;
            Object otherValue = ((SObject) other.mapOrSObjectVal).get((String) keyToSortBy);

            if (thisValue == otherValue) {
                return 0;
            }

            List<Object> values = new List<Object>{
                thisValue, otherValue
            };
            values.sort();
            if (values.get(0) == thisValue) {
                return -1;
            }
            return 1;
        }
    }

    /**
     * @description Returns the first element in a list.
     * Accepts 1 argument: the list to evaluate.
     * @function FIRST
     * @example
     * FIRST(LIST(1, 2, 3)) // 1
     */
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

    /**
     * @description Returns the last element in a list.
     * Accepts 1 argument: the list to evaluate.
     * @function LAST
     * @example
     * LAST(LIST(1, 2, 3)) // 3
     */
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

    /**
     * @description Reduces a list to a single value using the first argument as the context, the second argument as the expression to evaluate,
     * and the third argument as the initial value.
     * Accepts 3 arguments: List of objects, an expression to evaluate, and the initial value.
     * @function REDUCE
     * @example
     * REDUCE([1, 2, 3], $accumulator + $current, 0) // 6
     */
    private class ReduceFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "REDUCE" function: the first argument must evaluate to an iterable.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // Third argument is an initial value
            Object initialValue = evaluate(arguments.get(2));

            // If the list is empty, return early
            List<Object> listVal = CollectionUtils.toObjectList((Iterable<Object>) listObj);
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

    /**
     * @description Adds a key/value pair to a map.
     * Accepts 3 arguments: the map to add to, the key to add, and the value to add.
     * @function PUT
     * @example
     * PUT({ "a": 1, "b": 2, "c": 3 }, "d", 4) // { "a": 1, "b": 2, "c": 3, "d": 4 }
     */
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

    /**
     * @description Returns the element at the specified index. If the list is empty or the
     * index is out of bounds, this function will return null.
     * Accepts 2 arguments: the list to evaluate and the index to return.
     * @function AT
     * @example AT([1, 2, 3], 1) // 2
     */
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

    /**
     * @description Returns true if any element in the list matches the given expression.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate.
     * @function ANY
     * @example
     * ANY([1, 2, 3], $current = 2) // true
     */
    private class AnyFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "ANY" function: the first argument must evaluate to an iterable.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // If the list is empty, return early
            List<Object> listVal = CollectionUtils.toObjectList((Iterable<Object>) listObj);
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

    /**
     * @description Returns the sum of a list of numbers.
     * Accepts 1 argument: the list of numbers to evaluate.
     * @function SUM
     * @example
     * SUM([1, 2, 3]) // 6
     */
    private class SumFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SUM" function: the first argument must evaluate to an iterable.'
                );
            }

            // If the list is empty, return early
            List<Object> listVal = CollectionUtils.toObjectList((Iterable<Object>) listObj);
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

    /**
     * @description Returns true if every element in the list matches the given expression.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate.
     * @function EVERY
     * @example
     * EVERY([1, 2, 3], $current > 0) // true
     */
    private class EveryFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof Iterable<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "EVERY" function: the first argument must evaluate to an iterable.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            // If the list is empty, return early
            List<Object> listVal = CollectionUtils.toObjectList((Iterable<Object>) listObj);
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

    /**
     * @description Expands each element of a list into zero or more elements, resulting from the
     * evaluation of the given expression.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate. The expression
     * must return a list.
     * @function EXPAND
     * @example
     * EXPAND([1, 2, 3], LIST($current, $current + 1)) // [1, 2, 2, 3, 3, 4]
     */
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

    /**
     * @description Returns the first element of a list that matches the given expression or null
     * if the list is empty or no element matches the expression.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate.
     * @function FIRSTWHERE
     * @example
     * FIRSTWHERE([1, 2, 3], $current > 2) // 3
     */
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

    /**
     * @description Appends a list to another list.
     * Accepts 2 arguments: the list to append to and the list to append.
     * @function FOLLOWEDBY
     * @example
     * FOLLOWEDBY([1, 2, 3], [4, 5, 6])
     */
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

    /**
     * @description Joins a list of values into a string using the specified delimiter.
     * Accepts 2 arguments: the list to join and the delimiter.
     * @function JOIN
     * @example
     * JOIN([1, 2, 3], ", ")
     */
    private class JoinFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "JOIN" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is a string
            Object separator = evaluate(arguments.get(1));
            if (!(separator instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "JOIN" function: the second argument must evaluate to a string.'
                );
            }

            List<Object> listVal = (List<Object>) listObj;
            List<String> convertedStrings = new List<String>();
            for (Object currentVal : listVal) {
                convertedStrings.add(StringUtils.valueOf(currentVal));
            }

            return String.join(convertedStrings, (String) separator);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Returns the last element of a list that matches the given expression or null
     * if the list is empty or no element matches the expression.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate.
     * @function LASTWHERE
     * @example
     * LASTWHERE([1, 2, 3], $current > 2) // 3
     */
    private class LastWhereFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "LASTWHERE" function: the first argument must evaluate to a list.'
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
            for (Integer i = listVal.size() - 1; i >= 0; i--) {
                Object currentVal = listVal.get(i);
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
                        'Error executing "LASTWHERE" function: the second argument must evaluate to a boolean.'
                    );
                }
            }

            return null;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Skips the first N elements of a list.
     * Accepts 2 arguments: the list to skip and the number of elements to skip.
     * @function SKIP
     * @example
     * SKIP([1, 2, 3], 2) // [3]
     */
    private class SkipFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SKIP" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is a number
            Object numberObj = evaluate(arguments.get(1));
            if (!(numberObj instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "SKIP" function: the second argument must evaluate to a number.'
                );
            }

            List<Object> listVal = (List<Object>) listObj;
            Decimal numberVal = (Decimal) numberObj;

            // If the list is empty, return early
            if (listVal.isEmpty()) {
                return new List<Object>();
            }

            // If the number is negative, return early
            if (numberVal < 0) {
                return new List<Object>();
            }

            // If the number is greater than the size of the list, return early
            if (numberVal >= listVal.size()) {
                return new List<Object>();
            }

            // Return a new list with the first n elements removed
            List<Object> result = new List<Object>();
            for (Integer i = numberVal.intValue(); i < listVal.size(); i++) {
                result.add(listVal.get(i));
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Skips elements of a list while the given expression evaluates to true.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate.
     * @function SKIPWHILE
     * @example
     * SKIPWHILE([1, 2, 3], $current < 3) // [3]
     */
    private class SkipWhileFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "SKIPWHILE" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            List<Object> listVal = (List<Object>) listObj;
            for (Integer i = 0; i < listVal.size(); i++) {
                Object currentVal = listVal.get(i);
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                Interpreter interpreter = new Interpreter(env);
                Object result = interpreter.interpret(expr);

                if (result instanceof Boolean) {
                    if (!(Boolean) result) {
                        // Return a new list with the first n elements removed
                        List<Object> toReturn = new List<Object>();
                        for (Integer j = i; j < listVal.size(); j++) {
                            toReturn.add(listVal.get(j));
                        }
                        return toReturn;
                    }
                } else {
                    throw new FunctionExecutionException(
                        'Error executing "SKIPWHILE" function: the second argument must evaluate to a boolean.'
                    );
                }
            }

            // If we get here, it means that the expression evaluated to true for all elements in the list
            return new List<Object>();
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Returns the first N elements of a list.
     * Accepts 2 arguments: the list to take from and the number of elements to take.
     * @function TAKE
     * @example
     * TAKE([1, 2, 3], 2) // [1, 2]
     */
    private class TakeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "TAKE" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is a number
            Object numberObj = evaluate(arguments.get(1));
            if (!(numberObj instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "TAKE" function: the second argument must evaluate to a number.'
                );
            }

            List<Object> listVal = (List<Object>) listObj;
            Decimal numberVal = (Decimal) numberObj;

            // If the list is empty, return early
            if (listVal.isEmpty()) {
                return new List<Object>();
            }

            // If the number is negative, return early
            if (numberVal < 0) {
                return new List<Object>();
            }

            // If the number is greater than the size of the list, return the whole list
            if (numberVal >= listVal.size()) {
                return listVal;
            }

            // Return a new list with the first n elements
            List<Object> result = new List<Object>();
            for (Integer i = 0; i < numberVal.intValue(); i++) {
                result.add(listVal.get(i));
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Returns elements of a list while the given expression evaluates to true.
     * Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).
     * Accepts 2 arguments: the list to evaluate and the expression to evaluate.
     * @function TAKEWHILE
     * @example
     * TAKEWHILE([1, 2, 3], $current < 3)
     */
    private class TakeWhileFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a list
            Object listObj = evaluate(arguments.get(0));
            if (!(listObj instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "TAKEWHILE" function: the first argument must evaluate to a list.'
                );
            }

            // Second argument is an expression
            Expr expr = arguments.get(1);

            List<Object> listVal = (List<Object>) listObj;
            for (Integer i = 0; i < listVal.size(); i++) {
                Object currentVal = listVal.get(i);
                Environment env = getEnvironmentFromObject(currentVal);
                env.define('$current', currentVal);
                Interpreter interpreter = new Interpreter(env);
                Object result = interpreter.interpret(expr);

                if (result instanceof Boolean) {
                    if (!(Boolean) result) {
                        // Return a new list with the first n elements
                        List<Object> toReturn = new List<Object>();
                        for (Integer j = 0; j < i; j++) {
                            toReturn.add(listVal.get(j));
                        }
                        return toReturn;
                    }
                } else {
                    throw new FunctionExecutionException(
                        'Error executing "TAKEWHILE" function: the second argument must evaluate to a boolean.'
                    );
                }
            }

            // If we get here, it means that the expression evaluated to true for all elements in the list
            return listVal;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    /**
     * @description Returns a list of numbers from the start to the end, inclusive.
     * Accepts 2 arguments: the start and end numbers.
     * @function RANGE
     * @example
     * RANGE(1, 3) // [1, 2, 3]
     */
    private class RangeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument is a number
            Object numberObj = evaluate(arguments.get(0));
            if (!(numberObj instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "RANGE" function: the first argument must evaluate to a number.'
                );
            }

            // Second argument is a number
            Object numberObj2 = evaluate(arguments.get(1));
            if (!(numberObj2 instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "RANGE" function: the second argument must evaluate to a number.'
                );
            }

            Decimal numberVal = (Decimal) numberObj;
            Decimal numberVal2 = (Decimal) numberObj2;
            List<Decimal> result = new List<Decimal>();
            for (Decimal i = numberVal; i <= numberVal2; i++) {
                result.add(i);
            }
            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }
}
