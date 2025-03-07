public with sharing class QueryInterpreter extends Interpreter {
    private Boolean isWhereContext = false;
    private static Boolean allowScopeVariableInterpretation = false;
    private SObjectType objectType;

    public QueryInterpreter(Environment environment) {
        super(environment);
    }

    public Q evaluateToQuery(Expr.Query query) {
        objectType = Schema.getGlobalDescribe().get(query.sObjectType.lexeme);
        if (objectType == null) {
            throw new Exceptions.RuntimeException(query.sObjectType,
                'Unknown sObject type: ' + query.sObjectType.lexeme);
        }

        return buildQ(query.sObjectType.lexeme, query);
    }

    private Q buildQ(String sObjectToQuery, Expr.Query query) {
        Q querier = new Q(sObjectToQuery);

        if (query.fieldsExpression != null) {
            Object evaluatedFieldsExpression = evaluate(query.fieldsExpression);
            if (!(evaluatedFieldsExpression instanceof List<Object>)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected a list of fields or an expression that evaluates to a list of fields.');
            }

            for (Object field : (List<Object>) evaluatedFieldsExpression) {
                if (!(field instanceof String) && !(field instanceof Q)) {
                    throw new Exceptions.RuntimeException(query.sObjectType,
                        'Each field must evaluate to a string, a merge field or a sub query.');
                }

                if (field instanceof Q) {
                    querier.addSubquery((Q) field);
                } else {
                    querier.selectField((String) field);
                }
            }
        }

        for (Expr orderByExpr : query.orderBy) {
            // Each Order by will be a binary expression, containing
            // an expression that evaluates to the field name to order by
            // and the QOrder.SortOrder for the direction.
            Expr.Binary orderBy = (Expr.Binary) orderByExpr;
            Object orderByResult = evaluate(orderBy.left);
            QOrder.SortOrder sortOrder = (QOrder.SortOrder) evaluate(orderBy.right);

            // Must evaluate to a string (or a merge field, which resolves as a string in this interpreter)
            if (!(orderByResult instanceof String)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected a string or an expression that evaluates to a string or merge field for the order by clause.');
            }

            querier.add(Q.orderBy((String) orderByResult).withDirection(sortOrder));
        }

        if (query.limitExpr != null) {
            allowScopeVariableInterpretation = true;
            Object limitResult = evaluate(query.limitExpr);
            allowScopeVariableInterpretation = false;
            if (!(limitResult instanceof Decimal)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected an integer or an expression that evaluates to an number for the limit clause.');
            }
            querier.addLimit(((Decimal) limitResult).intValue());
        }

        if (query.whereExpr != null) {
            isWhereContext = true;
            Object whereResult = evaluate(query.whereExpr);
            if (!(whereResult instanceof QICondition)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected a condition or an expression that evaluates to a condition for the where clause.');
            }
            isWhereContext = false;

            querier.add((QICondition) whereResult);
        }

        if (query.offsetExpr != null) {
            allowScopeVariableInterpretation = true;
            Object offsetResult = evaluate(query.offsetExpr);
            allowScopeVariableInterpretation = false;
            if (!(offsetResult instanceof Decimal)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected an integer or an expression that evaluates to an number for the offset clause.');
            }
            querier.addOffset(((Decimal) offsetResult).intValue());
        }

        return querier;
    }

    public override Object visit(Expr.Logical logical) {
        if (!isWhereContext) {
            throw new Exceptions.RuntimeException(logical.operator,
                'Logical operators are not supported in a Query context outside of a where clause.');
        }

        Object left = evaluate(logical.left);
        Object right = evaluate(logical.right);

        switch on logical.operator.type {
            when DOUBLE_AMPERSAND {
                if (!(left instanceof QICondition)) {
                    throw new Exceptions.RuntimeException(logical.operator,
                        'Expected a condition or an expression that evaluates to a condition for the left side of the AND operator.');
                }
                if (!(right instanceof QICondition)) {
                    throw new Exceptions.RuntimeException(logical.operator,
                        'Expected a condition or an expression that evaluates to a condition for the right side of the AND operator.');
                }

                List<QICondition> conditions = new List<QICondition>{
                    (QICondition) left,
                    (QICondition) right
                };
                return new QAndGroup(conditions);
            }
            when DOUBLE_PIPE {
                if (!(left instanceof QICondition)) {
                    throw new Exceptions.RuntimeException(logical.operator,
                        'Expected a condition or an expression that evaluates to a condition for the left side of the OR operator.');
                }
                if (!(right instanceof QICondition)) {
                    throw new Exceptions.RuntimeException(logical.operator,
                        'Expected a condition or an expression that evaluates to a condition for the right side of the OR operator.');
                }

                List<QICondition> conditions = new List<QICondition>{
                    (QICondition) left,
                    (QICondition) right
                };
                return new QOrGroup(conditions);
            }
            when else {
                // Unreachable
                throw new Exceptions.RuntimeException(logical.operator,
                    'Unsupported logical operator.');
            }
        }
    }

    public override Object visit(Expr.Binary binary) {
        if (!isWhereContext) {
            throw new Exceptions.RuntimeException(binary.operator,
                'Operators are not supported in a Query context outside of a where clause.');
        }

        Object left = evaluate(binary.left);
        allowScopeVariableInterpretation = true;
        Object right = evaluate(binary.right);
        allowScopeVariableInterpretation = false;

        switch on binary.operator.type {
            when EQUAL, EQUAL_EQUAL {
                return Q.condition((String) left).equalsTo(right);
            }
            when GREATER {
                return Q.condition((String) left).isGreaterThan(right);
            }
            when GREATER_EQUAL {
                return Q.condition((String) left).isGreaterOrEquals(right);
            }
            when LESS {
                return Q.condition((String) left).isLessThan(right);
            }
            when LESS_EQUAL {
                return Q.condition((String) left).isLessOrEquals(right);
            }
            when BANG_EQUAL, LESS_GREATER {
                return Q.condition((String) left).notEqualsTo(right);
            }
            when else {
                throw new Exceptions.RuntimeException(binary.operator,
                    'Unsupported operator: ' + binary.operator.lexeme + ' within a Query context\'s where clause.');
            }
        }
    }

    public override Object visit(Expr.Unary unary) {
        if (unary.operator.type == TokenType.BANG) {
            throw new Exceptions.RuntimeException(unary.operator,
                'Unsupported operator: ' + unary.operator.lexeme + ' within a Query context.');
        }

        return super.visit(unary);
    }

    public override Object visit(Expr.MergeFieldOrScopeVariable mergeField) {
        if (allowScopeVariableInterpretation) {
            return super.visit(mergeField);
        }
        return mergeField.name.lexeme;
    }

    public override Object visit(Expr.GetExpr getExpr) {
        // Within a GetExpr, we are going to either be dealing with a Variable
        // (e.g. $Var.Field or @Var.Field) or a MergeField.
        // Variables can be interpreted right away, so we can get the value,
        // and thus we call the super method. But for merge fields we simply want to
        // return them as is, so that they get passed into the SOQL query for interpretation.
        if (getExpr.objectExpr instanceof Expr.Variable) {
            return super.visit(getExpr);
        }
        String field = getExpr.field.lexeme;
        return evaluate(getExpr.objectExpr) + '.' + field;
    }

    public override Object visit(Expr.Query query) {
        return buildQ(query.sObjectType.lexeme, query);
    }

    public override Object visit(Expr.FunctionCall function) {
        if (!isWhereContext) {
            throw new Exceptions.RuntimeException(function.functionToken,
                'Functions are not supported in a Query context outside of a where clause.');
        }

        Map<String, StandardFunction> dateAndTimeFunctions = new DateAndTimeFunctions.DateAndTimeFunctionsProvider().getFunctions();
        Map<String, StandardFunction> supportedWhereFunctions = new Map<String, StandardFunction>{
            'LIKE' => new LikeFn(),
            'ISIN' => new IsInFn(),
            'ISNOTIN' => new IsNotInFn(),
            'ISNULL' => new IsNullFn(),
            'ISNOTNULL' => new IsNotNullFn(),
            'AND' => new AndFn(),
            'OR' => new OrFn(),
            'DATETIMEVALUE' => dateAndTimeFunctions.get('DATETIMEVALUE'),
            'DATEVALUE' => dateAndTimeFunctions.get('DATEVALUE'),
            'DATE' => dateAndTimeFunctions.get('DATE'),
            'TODAY' => dateAndTimeFunctions.get('TODAY'),
            'NOW' => dateAndTimeFunctions.get('NOW')
        };

        String functionName = function.functionToken.lexeme.toUpperCase();
        if (supportedWhereFunctions.containsKey(functionName)) {
            StandardFunction expressionFunction = supportedWhereFunctions.get(functionName);
            expressionFunction.setInterpreter(this);
            ArityEvaluator.check(expressionFunction, function);
            try {
                return expressionFunction.call(function.arguments);
            } catch (Exception e) {
                throw new Exceptions.RuntimeException(
                    function.functionToken,
                    e.getMessage()
                );
            }
        }

        throw new Exceptions.RuntimeException(function.functionToken,
            'Unsupported function: ' + function.functionToken.lexeme + ' within a Query context\'s where clause.');
    }

    private class LikeFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            allowScopeVariableInterpretation = true;
            Object pattern = evaluate(arguments.get(1));
            allowScopeVariableInterpretation = false;
            if (!(text instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "LIKE" function: the first argument must evaluate to a string value.'
                );
            }
            if (!(pattern instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "LIKE" function: the second argument must evaluate to a string value.'
                );
            }

            return Q.condition((String) text).isLike((String) pattern);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class IsInFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 2 arguments, the first is the field name, the second is a list of values
            Object field = evaluate(arguments.get(0));
            allowScopeVariableInterpretation = true;
            Object values = evaluate(arguments.get(1));
            allowScopeVariableInterpretation = false;

            if (!(field instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "ISIN" function: the first argument must evaluate to a string value or a merge field.'
                );
            }

            if (!(values instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "ISIN" function: the second argument must evaluate to a list of values.'
                );
            }

            // Empty lists are not accepted, as they will never match anything
            if (((List<Object>) values).isEmpty()) {
                throw new FunctionExecutionException(
                    'Error executing "ISIN" function: the second argument must evaluate to a non-empty list of values.'
                );
            }

            return Q.condition((String) field).isIn((List<Object>) values);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class IsNotInFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 2 arguments, the first is the field name, the second is a list of values
            Object field = evaluate(arguments.get(0));
            allowScopeVariableInterpretation = true;
            Object values = evaluate(arguments.get(1));
            allowScopeVariableInterpretation = false;

            if (!(field instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "ISNOTIN" function: the first argument must evaluate to a string value or a merge field.'
                );
            }

            if (!(values instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "ISNOTIN" function: the second argument must evaluate to a list of values.'
                );
            }

            // Empty lists are not accepted, as they will never match anything
            if (((List<Object>) values).isEmpty()) {
                throw new FunctionExecutionException(
                    'Error executing "ISNOTIN" function: the second argument must evaluate to a non-empty list of values.'
                );
            }

            return Q.condition((String) field).isNotIn((List<Object>) values);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class IsNullFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument, the field name
            Object field = evaluate(arguments.get(0));

            if (!(field instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "ISNULL" function: the first argument must evaluate to a string value or a merge field.'
                );
            }

            return Q.condition((String) field).isNull();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class IsNotNullFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument, the field name
            Object field = evaluate(arguments.get(0));

            if (!(field instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "ISNOTNULL" function: the first argument must evaluate to a string value or a merge field.'
                );
            }

            return Q.condition((String) field).isNotNull();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class AndFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            List<QICondition> conditions = new List<QICondition>();
            for (Expr argument : arguments) {
                Object evaluatedArgument = evaluate(argument);
                if (!(evaluatedArgument instanceof QICondition)) {
                    throw new FunctionExecutionException(
                        'Error executing "AND" function: all arguments must evaluate to conditions.'
                    );
                }
                conditions.add((QICondition) evaluatedArgument);
            }

            return new QAndGroup(conditions);
        }

        public override Arity getArity() {
            return Arity.atLeast(2);
        }
    }

    private class OrFn extends StandardFunction {
        public override Object call(List<Expr> arguments) {
            List<QICondition> conditions = new List<QICondition>();
            for (Expr argument : arguments) {
                Object evaluatedArgument = evaluate(argument);
                if (!(evaluatedArgument instanceof QICondition)) {
                    throw new FunctionExecutionException(
                        'Error executing "OR" function: all arguments must evaluate to conditions.'
                    );
                }
                conditions.add((QICondition) evaluatedArgument);
            }

            return new QOrGroup(conditions);
        }

        public override Arity getArity() {
            return Arity.atLeast(2);
        }
    }
}
