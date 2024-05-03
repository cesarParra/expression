public with sharing class QSalesforceDatabase extends QDB {
    public override List<SObject> run(Q query) {
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
            orderList.add(buildQOrder(order));
        }

        if (!query.orders.isEmpty()) {
            return 'ORDER BY ' + String.join(orderList, ', ');
        } else {
            return '';
        }
    }

    private String buildQOrder(QOrder order) {
        String orderString = order.field;

        if (order.sortValue == QOrder.SortOrder.ASCENDING) {
            orderString += ' ASC';
        } else {
            orderString += ' DESC';
        }

        if (order.nullsValue != null && order.nullsValue == QOrder.NullsOrder.FIRST) {
            orderString += ' NULLS FIRST';
        } else if (order.nullsValue != null && order.nullsValue == QOrder.NullsOrder.LAST) {
            orderString += ' NULLS LAST';
        }

        return orderString;
    }

    public override void doInsert(SObject record) {
        throw new QDBException('Not implemented');
    }

    public override void doInsert(List<SObject> records) {
        throw new QDBException('Not implemented');
    }
}
