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

        return QRunner.getInstance().run(querier);
    }

    public override Object visit(Expr.MergeField mergeField) {
        return mergeField.name.lexeme;
    }

    public override Object visit(Expr.GetExpr getExpr) {
        String field = getExpr.field.lexeme;
        return evaluate(getExpr.objectExpr) + '.' + field;
    }
}
