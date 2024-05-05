public inherited sharing abstract class QSalesforceDatabase extends QDB {
    public static QSalesforceDatabase getInstance() {
        if (QDB.evaluationSharingMode == Configuration.SharingMode.WITH) {
            return new WithSharingRunner();
        } else {
            return new WithoutSharingRunner();
        }
    }

    private with sharing class WithSharingRunner extends QSalesforceDatabase {
        public override List<SObject> run(Q query) {
            return Database.query(build(query), AccessLevel.USER_MODE);
        }

        public override List<SObject> runRaw(String query) {
            return Database.query(query, AccessLevel.USER_MODE);
        }
    }

    private without sharing class WithoutSharingRunner extends QSalesforceDatabase {
        public override List<SObject> run(Q query) {
            return Database.query(build(query), AccessLevel.SYSTEM_MODE);
        }

        public override List<SObject> runRaw(String query) {
            return Database.query(query, AccessLevel.SYSTEM_MODE);
        }
    }

    public String build(Q query) {
        List<String> queryParts = new List<String>();

        queryParts.add(buildSelect(query));
        queryParts.add('FROM ' + query.FromText);

        if (!query.conditions.isEmpty()) {
            queryParts.add(buildConditions(query));
        }

        if (!query.orders.isEmpty()) {
            queryParts.add(buildOrderBy(query));
        }

        if (query.NumberOfRowsToQuery != null) {
            queryParts.add('LIMIT ' + query.NumberOfRowsToQuery);
        }

        if (query.NumberOfRowsToSkip != null) {
            queryParts.add('OFFSET ' + query.NumberOfRowsToSkip);
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

    private static String buildOrderBy(Q query) {
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

    private static String buildQOrder(QOrder order) {
        String orderString = order.Field;

        if (order.SortValue == QOrder.SortOrder.ASCENDING) {
            orderString += ' ASC';
        } else {
            orderString += ' DESC';
        }

        if (order.NullsOrderValue != null && order.NullsOrderValue == QOrder.NullsOrder.FIRST) {
            orderString += ' NULLS FIRST';
        } else if (order.NullsOrderValue != null && order.NullsOrderValue == QOrder.NullsOrder.LAST) {
            orderString += ' NULLS LAST';
        }

        return orderString;
    }

    private String buildQCondition(QICondition condition) {
        String value = '';
        if (condition instanceof QConditionGroup) {
            QConditionGroup conditionGroup = (QConditionGroup) condition;
            String operatorAsString = toStringOperator(conditionGroup);
            for (QICondition subCondition : conditionGroup.Conditions) {
                if (String.isNotEmpty(value)) {
                    value += ' ' + operatorAsString + ' ';
                }
                value += buildQCondition(subCondition);
            }

            return '(' + value + ')';
        } else {
            QCondition cond = (QCondition) condition;
            switch on cond.OperatorValue {
                when EQUALS {
                    return cond.Field + ' = ' + formatFieldValue(cond.FieldValue);
                }
                when NOT_EQUALS {
                    return cond.Field + ' != ' + formatFieldValue(cond.FieldValue);
                }
                when LESS_THAN {
                    return cond.Field + ' < ' + formatFieldValue(cond.FieldValue);
                }
                when LESS_OR_EQUAL {
                    return cond.Field + ' <= ' + formatFieldValue(cond.FieldValue);
                }
                when GREATER_THAN {
                    return cond.Field + ' > ' + formatFieldValue(cond.FieldValue);
                }
                when GREATER_OR_EQUAL {
                    return cond.Field + ' >= ' + formatFieldValue(cond.FieldValue);
                }
                when IS_LIKE {
                    return cond.Field + ' LIKE ' + formatFieldValue(cond.FieldValue);
                }
                when IS_IN {
                    return cond.Field + ' IN (' + formatFieldValue(cond.FieldValue) + ')';
                }
                when NOT_IN {
                    return cond.Field + ' NOT IN (' + formatFieldValue(cond.FieldValue) + ')';
                }
                when else {
                    return '';
                }
            }
        }
    }

    private static String toStringOperator(QConditionGroup conditionGroup) {
        switch on conditionGroup.Operator {
            when AND_GROUP {
                return 'AND';
            }
            when OR_GROUP {
                return 'OR';
            }
        }
        throw new QDBException('Unreachable code');
    }

    private static Object formatFieldValue(Object val) {
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
        insert record;
    }

    public override void doInsert(List<SObject> records) {
        insert records;
    }
}
