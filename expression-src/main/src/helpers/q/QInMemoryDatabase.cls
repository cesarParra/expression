@IsTest
public with sharing class QInMemoryDatabase extends QDB {
    private final List<SObject> recordsInTheDatabase = new List<SObject>();

    public override List<SObject> run(Q query) {
        return fromQ(query);
    }

    public override void doInsert(SObject record) {
        record.Id = IdGenerator.generate(record.getSObjectType());
        recordsInTheDatabase.add(record);
    }

    public override void doInsert(List<SObject> records) {
        for (SObject record : records) {
            doInsert(record);
        }
    }

    private static SObjectType getSObjectTypeFromQ(Q query) {
        return ((SObject) Type.forName(query.fromText).newInstance()).getSObjectType();
    }

    private List<SObject> fromQ(Q query) {
        SObjectType sObjectType = getSObjectTypeFromQ(query);
        List<SObject> filteredRecordsForSObject = new List<SObject>();
        for (SObject record : recordsInTheDatabase) {
            if (record.getSObjectType() == sObjectType) {
                filteredRecordsForSObject.add(record);
            }
        }

        ExpressionBuilder exprBuilder = new ExpressionBuilder();

        System.debug('recordsInTheDatabase: ' + recordsInTheDatabase);
        for (QICondition condition : query.conditions) {
            exprBuilder.condition(condition);
        }

        for (QOrder order : query.orders) {
            exprBuilder.orderBy(order);
        }

        Object result = Evaluator.run(exprBuilder.build(), filteredRecordsForSObject);

        return castToSObjectList((List<Object>) result);
    }

    private static List<SObject> castToSObjectList(List<Object> objects) {
        List<SObject> sObjects = new List<SObject>();
        for (Object obj : objects) {
            sObjects.add((SObject) obj);
        }
        return sObjects;
    }

    private class ExpressionBuilder {
        private String expr;

        public ExpressionBuilder() {
            this.expr = '@Context';
        }

        public ExpressionBuilder orderBy(QOrder order) {
            String direction = order.sortValue == QOrder.SortOrder.ASCENDING ? '"ASC"' : '"DESC"';
            String nullDirection = order.nullsValue == QOrder.NullsOrder.FIRST ? '"NULLS_FIRST"' : '"NULLS_LAST"';
            expr += '-> SORT(' + order.field + ',' + direction + ',' + nullDirection + ')';
            return this;
        }

        public ExpressionBuilder condition(QICondition condition) {
            if (condition instanceof QConditionGroup) {
                throw new QDBException('QConditionGroup is not supported in InMemoryDatabase just yet');
            }

            QCondition cond = (QCondition) condition;
            switch on cond.operatorValue {
                when EQUALS {
                    expr += '-> WHERE(' + cond.field + ' == ' + formatFieldValue(cond.fieldValue) + ')';
                }
                when NOT_EQUALS {
                    expr += '-> WHERE(' + cond.field + ' != ' + formatFieldValue(cond.fieldValue) + ')';
                }
                when LESS_THAN {
                    expr += '-> WHERE(' + cond.field + ' < ' + formatFieldValue(cond.fieldValue) + ')';
                }
                when else {
                    throw new QDBException('Operator ' + cond.operatorValue + ' is not supported in InMemoryDatabase');
                }
            }

            return this;
        }

        private Object formatFieldValue(Object val) {
            if (val instanceof String) {
                return '"' + val + '"';
            } else if (val instanceof Date) {
                Date castDate = (Date) val;
                return 'DATE(' + castDate.year() + ',' + castDate.month() + ',' + castDate.day() + ')';
            } else if (val instanceof Datetime) {
                Datetime castDatetime = (Datetime) val;
                return 'DATETIME(' + castDatetime.year() + ',' + castDatetime.month() + ',' + castDatetime.day() + ',' + castDatetime.hour() + ',' + castDatetime.minute() + ',' + castDatetime.second() + ')';
            }
            return val;
        }

        public String build() {
            return expr;
        }
    }
}
