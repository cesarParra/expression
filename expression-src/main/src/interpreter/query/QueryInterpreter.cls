public with sharing class QueryInterpreter {
    public List<SObject> evaluate(Expr.Query query) {
        Q querier = new Q(query.sObjectType.lexeme);

        for (String field : query.fields) {
            querier = querier.selectField(field);
        }

//        if (query.orderBy != null) {
//            Object orderByResult = evaluate(query.orderBy);
//
//            // Order By can either be a string (specific field name),
//            // or a list ???
//        }

        return QRunner.getInstance().run(querier);
    }
}
