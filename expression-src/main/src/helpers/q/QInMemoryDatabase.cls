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

        for (QICondition condition : query.conditions) {
            exprBuilder.condition(condition);
        }

        for (QOrder order : query.orders) {
            exprBuilder.orderBy(order);
        }

        if (query.numberOfRowsToSkip != null) {
            exprBuilder.addOffset(query.numberOfRowsToSkip);
        }

        if (query.numberOfRows != null) {
            exprBuilder.addLimit(query.numberOfRows);
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
                when LESS_OR_EQUAL {
                    expr += '-> WHERE(' + cond.field + ' <= ' + formatFieldValue(cond.fieldValue) + ')';
                }
                when GREATER_THAN {
                    expr += '-> WHERE(' + cond.field + ' > ' + formatFieldValue(cond.fieldValue) + ')';
                }
                when GREATER_OR_EQUAL {
                    expr += '-> WHERE(' + cond.field + ' >= ' + formatFieldValue(cond.fieldValue) + ')';
                }
                when IS_LIKE {
                    // Check that the field is a string
                    if (cond.fieldValue instanceof String) {
                        expr += '-> WHERE(LIKE(' + cond.field + ',' + formatFieldValue(cond.fieldValue) + '))';
                    } else {
                        throw new QDBException('IS LIKE operator can only be used with String fields');
                    }
                }
                when IS_IN {
                    expr += '-> WHERE(CONTAINS(' + formatFieldValue(cond.fieldValue) + ',' + cond.field + '))';
                }
                when NOT_IN {
                    expr += '-> WHERE(NOT(CONTAINS(' + formatFieldValue(cond.fieldValue) + ',' + cond.field + ')))';
                }
                when else {
                    throw new QDBException('Operator ' + cond.operatorValue + ' is not supported in InMemoryDatabase');
                }
            }

            return this;
        }

        public ExpressionBuilder addLimit(Integer numberToLimitTo) {
            expr += '-> TAKE(' + numberToLimitTo + ')';
            return this;
        }

        public ExpressionBuilder addOffset(Integer numberToOffset) {
            expr += '-> SKIP(' + numberToOffset + ')';
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
            } else if (val instanceof List<Object>) {
                String formattedList = '[';
                for (Object obj : (List<Object>) val) {
                    formattedList += formatFieldValue(obj) + ',';
                }
                formattedList = formattedList.removeEnd(',');
                formattedList += ']';
                return formattedList;
            }
            return val;
        }

        public String build() {
            return expr;
        }
    }
}
