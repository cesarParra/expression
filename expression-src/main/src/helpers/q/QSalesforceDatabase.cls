public with sharing class QSalesforceDatabase extends QDB {
    public override List<SObject> run(Q query) {
        throw new QDBException('Not implemented');
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
            condList.add(buildQCondition(cond));
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

    private String buildQCondition(QICondition condition) {
        String value = '';
        if (condition instanceof QConditionGroup) {
            QConditionGroup conditionGroup = (QConditionGroup) condition;
            for (QICondition subCondition : conditionGroup.conditions) {
                if (String.isNotEmpty(value)) {
                    value += ' ' + conditionGroup.operator + ' ';
                }
                value += buildQCondition(subCondition);
            }

            return '(' + value + ')';
        } else {
            QCondition cond = (QCondition) condition;
            switch on cond.operatorValue {
                when EQUALS {
                    return cond.field + ' = ' + formatFieldValue(cond.fieldValue);
                }
                when NOT_EQUALS {
                    return cond.field + ' != ' + formatFieldValue(cond.fieldValue);
                }
                when LESS_THAN {
                    return cond.field + ' < ' + formatFieldValue(cond.fieldValue);
                }
                when LESS_OR_EQUAL {
                    return cond.field + ' <= ' + formatFieldValue(cond.fieldValue);
                }
                when GREATER_THAN {
                    return cond.field + ' > ' + formatFieldValue(cond.fieldValue);
                }
                when GREATER_OR_EQUAL {
                    return cond.field + ' >= ' + formatFieldValue(cond.fieldValue);
                }
                when IS_LIKE {
                    return cond.field + ' LIKE ' + formatFieldValue(cond.fieldValue);
                }
                when IS_IN {
                    return cond.field + ' IN (' + formatFieldValue(cond.fieldValue) + ')';
                }
                when NOT_IN {
                    return cond.field + ' NOT IN (' + formatFieldValue(cond.fieldValue) + ')';
                }
                when else {
                    return '';
                }
            }
        }
    }

    private Object formatFieldValue(Object val) {
        if (val instanceof List<Object>) {
            List<String> values = new List<String>();
            for (Object value : (List<Object>) val) {
                if (value instanceof String) {
                    values.add('\'' + String.escapeSingleQuotes((String) value) + '\'');
                } else {
                    values.add((String) value);
                }
            }
            return String.join(values, ', ');
        }
        if (val instanceof String) {
            return '\'' + String.escapeSingleQuotes((String) val) + '\'';
        } else if (val instanceof Date) {
            String dateString = String.valueOf(val);
            return dateString.substring(0, dateString.indexOf(' '));
        } else if (val instanceof Datetime) {
            return ((Datetime) val).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        } else {
            return val;
        }
    }

    public override void doInsert(SObject record) {
        throw new QDBException('Not implemented');
    }

    public override void doInsert(List<SObject> records) {
        throw new QDBException('Not implemented');
    }
}
