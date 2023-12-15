public with sharing class QueryInterpreter extends Interpreter implements Visitor {

    public QueryInterpreter(Environment environment) {
        super(environment);
    }

    public List<SObject> evaluateToQuery(Expr.Query query) {
        Q querier = new Q(query.sObjectType.lexeme);

        if (query.fieldsExpression != null) {
            Object evaluatedFieldsExpression = evaluate(query.fieldsExpression);
            if (!(evaluatedFieldsExpression instanceof List<Object>)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected a list of fields or an expression that evaluates to a list of fields.');
            }

            for (Object field : (List<Object>) evaluatedFieldsExpression) {
                if (!(field instanceof String)) {
                    throw new Exceptions.RuntimeException(query.sObjectType,
                        'Each field must evaluate to a string or a merge field.');
                }
                querier.selectField((String) field);
            }
        }

        for (Expr orderByExpr : query.orderBy) {
            // Each Order by will be a binary expression, containing
            // an expression that evaluates to the field name to order by
            // and the QOrder.SortOrder for the direction.
            Expr.Binary orderBy = (Expr.Binary)orderByExpr;
            Object orderByResult = evaluate(orderBy.left);
            QOrder.SortOrder sortOrder = (QOrder.SortOrder)evaluate(orderBy.right);

            // Must evaluate to a string
            if (!(orderByResult instanceof String)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected a string or an expression that evaluates to a string or merge field for the order by clause.');
            }

            querier.add(Q.orderBy((String) orderByResult).withDirection(sortOrder));
        }

        if (query.limitExpr != null) {
            Object limitResult = evaluate(query.limitExpr);
            if (!(limitResult instanceof Decimal)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected an integer or an expression that evaluates to an number for the limit clause.');
            }
            querier.addLimit(((Decimal) limitResult).intValue());
        }

        if (query.whereExpr != null) {
            Object whereResult = evaluate(query.whereExpr);
            if (!(whereResult instanceof QCondition)) {
                throw new Exceptions.RuntimeException(query.sObjectType,
                    'Expected a condition or an expression that evaluates to a condition for the where clause.');
            }
            querier.add((QCondition) whereResult);
        }

        return QRunner.getInstance().run(querier);
    }

    public override Object visit(Expr.Binary binary) {
        Set<TokenType> supportedQueryOperations = new Set<TokenType> {
            TokenType.EQUAL,
            TokenType.EQUAL_EQUAL
        };

        if (!supportedQueryOperations.contains(binary.operator.type)) {
            return super.visit(binary);
        }

        Object left = evaluate(binary.left);
        Object right = evaluate(binary.right);

        switch on binary.operator.type {
            when EQUAL, EQUAL_EQUAL {
                return Q.condition((String) left).equalsTo(right);
            }
            when else {
                throw new Exceptions.RuntimeException(binary.operator,
                    'Unsupported query operation.');
            }
        }
    }

    public override Object visit(Expr.MergeField mergeField) {
        return mergeField.name.lexeme;
    }

    public override Object visit(Expr.GetExpr getExpr) {
        String field = getExpr.field.lexeme;
        return evaluate(getExpr.objectExpr) + '.' + field;
    }
}
