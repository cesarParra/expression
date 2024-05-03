public with sharing class QSalesforceDatabase implements QDatabase {
    public List<SObject> run(Q query) {
        return null;
    }

    public String build(Q query) {
        List<String> queryParts = new List<String>();

        queryParts.add(buildSelect(query));
        queryParts.add('FROM ' + query.fromText);

        if (!query.conditions.isEmpty()) {
            queryParts.add(buildConditions(query));
        }

        if (!query.orders.isEmpty()) {
            queryParts.add(buildOrderBy(query));
        }

        if (query.numberOfRows != null) {
            queryParts.add('LIMIT ' + query.numberOfRows);
        }

        if (query.numberOfRowsToSkip != null) {
            queryParts.add('OFFSET ' + query.numberOfRowsToSkip);
        }

        return String.join(queryParts, ' ');
    }

    private String buildSelect(Q query) {
        for (Q qb : query.subQueries) {
            query.fieldList.add('(' + build(qb) + ')');
        }

        if (!query.fieldList.isEmpty()) {
            return 'SELECT ' + String.join(new List<String>(query.fieldList), ', ');
        } else {
            return 'SELECT Id';
        }
    }

    private String buildConditions(Q query) {
        List<String> condList = new List<String>();

        for (QICondition cond : query.conditions) {
            condList.add(cond.build());
        }

        if (!query.conditions.isEmpty()) {
            return 'WHERE ' + String.join(condList, ' AND ');
        } else {
            return null;
        }
    }

    private String buildOrderBy(Q query) {
        List<String> orderList = new List<String>();

        for (QOrder order : query.orders) {
            orderList.add(order.build());
        }

        if (!query.orders.isEmpty()) {
            return 'ORDER BY ' + String.join(orderList, ', ');
        } else {
            return '';
        }
    }
}
