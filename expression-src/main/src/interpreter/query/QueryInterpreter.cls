public with sharing class QueryInterpreter extends Interpreter implements Visitor {

    public QueryInterpreter(Environment environment) {
        super(environment);
    }

    public List<SObject> evaluateToQuery(Expr.Query query) {
        Q querier = new Q(query.sObjectType.lexeme);

        if (query.fieldsExpression != null) {
            Object evaluatedFieldsExpression = evaluate(query.fieldsExpression);
            if (!(evaluatedFieldsExpression instanceof List<Object>)) {
                throw new Exceptions.RuntimeException(query.sObjectType, 'Expected a list of fields or an expression that evaluates to a list of fields.');
            }

            for (Object field : (List<Object>) evaluatedFieldsExpression) {
                querier.selectField((String) field);
            }
        }

//        if (query.orderBy != null) {
//            Object orderByResult = evaluate(query.orderBy);
//
//            // Order By can either be a string (specific field name),
//            // or a list ???
//        }

        return QRunner.getInstance().run(querier);
    }

    public override Object visit(Expr.MergeField mergeField) {
        return mergeField.name.lexeme;
    }
}
