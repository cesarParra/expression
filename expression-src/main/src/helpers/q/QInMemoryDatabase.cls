@IsTest
public with sharing class QInMemoryDatabase extends QDB {
    private final Map<Id, sfab_FabricatedSObject> recordsInTheDatabase = new Map<Id, sfab_FabricatedSObject>();

    public override List<SObject> run(Q query) {
        return fromQ(query);
    }

    public override void doInsert(SObject record) {
        sfab_FabricatedSObject fabricatedRecord = new sfab_FabricatedSObject(
            Type.forName(record.getSObjectType().getDescribe().getName()),
            record.getPopulatedFieldsAsMap()
        );

        Id generatedId = IdGenerator.generate(record.getSObjectType());
        record.Id = generatedId;
        fabricatedRecord.set('Id', generatedId);
        resolveChildRelationships(fabricatedRecord, record);
        recordsInTheDatabase.put(generatedId, fabricatedRecord);
    }

    private void resolveChildRelationships(sfab_FabricatedSObject fabricatedRecord, SObject originalRecord) {
        Map<String, Object> populatedFields = originalRecord.getPopulatedFieldsAsMap();
        SObjectType sType = originalRecord.getSObjectType();
        Map<String, SObjectField> fieldsForType = sType.getDescribe().fields.getMap();

        // Extract only the fields that are a reference to a parent (i.e. fields with Ids)
        List<SObjectField> referenceFields = new List<SObjectField>();
        for (String currentPopulatedField : populatedFields.keySet()) {
            SObjectField field = fieldsForType.get(currentPopulatedField);
            if (field.getDescribe().getType() == DisplayType.REFERENCE) {
                // Make sure that the Id that is being referenced is actually in the database
                if (!recordsInTheDatabase.containsKey((Id) originalRecord.get(field))) {
                    throw new QDBException('The Id ' + originalRecord.get(field) + ' is not in the database');
                }

                referenceFields.add(field);
            }
        }

        Map<SObjectField, SObjectType> parentTypeOfReferenceField = new Map<SObjectField, SObjectType>();
        for (SObjectField currentField : referenceFields) {
            parentTypeOfReferenceField.put(currentField, ((Id) originalRecord.get(currentField)).getSobjectType());
        }

        for (SObjectField currentField : parentTypeOfReferenceField.keySet()) {
            SObjectType referenceType = parentTypeOfReferenceField.get(currentField);
            List<ChildRelationship> relationships = referenceType.getDescribe().getChildRelationships();
            for (ChildRelationship currentRelationship : relationships) {
                if (currentRelationship.getField() == currentField) {
                    String relationshipName = currentRelationship.getRelationshipName();
                    sfab_FabricatedSObject parentRecord = recordsInTheDatabase.get((Id) originalRecord.get(currentField));
                    parentRecord.addChild(relationshipName, fabricatedRecord);
                }
            }
        }
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
        for (sfab_FabricatedSObject fabRecord : recordsInTheDatabase.values()) {
            SObject record = (SObject) fabRecord.toSObject();
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
            expr += '-> WHERE(' + conditionStringBuilder(condition) + ')';
            return this;
        }

        public String conditionStringBuilder(QICondition condition) {
            if (condition instanceof QConditionGroup) {
                List<String> conditions = new List<String>();
                QConditionGroup castedCondition = (QConditionGroup) condition;
                for (QICondition cond : castedCondition.conditions) {
                    conditions.add(conditionStringBuilder(cond));
                }

                String operatorAsString = castedCondition.operator == QConditionGroup.Operator.AND_GROUP ? 'AND' : 'OR';

                String orGroup = operatorAsString + '(';
                for (String cond : conditions) {
                    orGroup += cond + ',';
                }
                orGroup = orGroup.removeEnd(',');
                orGroup += ')';

                return orGroup;
            }

            QCondition cond = (QCondition) condition;
            switch on cond.operatorValue {
                when EQUALS {
                    return cond.field + ' == ' + formatFieldValue(cond.fieldValue);
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
                    // Check that the field is a string
                    if (cond.fieldValue instanceof String) {
                        return 'LIKE(' + cond.field + ',' + formatFieldValue(cond.fieldValue) + ')';
                    } else {
                        throw new QDBException('IS LIKE operator can only be used with String fields');
                    }
                }
                when IS_IN {
                    return 'CONTAINS(' + formatFieldValue(cond.fieldValue) + ',' + cond.field + ')';
                }
                when NOT_IN {
                    return 'NOT(CONTAINS(' + formatFieldValue(cond.fieldValue) + ',' + cond.field + '))';
                }
                when else {
                    throw new QDBException('Operator ' + cond.operatorValue + ' is not supported in InMemoryDatabase');
                }
            }
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
