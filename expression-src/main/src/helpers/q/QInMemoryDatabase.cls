@IsTest
public with sharing class QInMemoryDatabase extends QDB {
    private final Map<Id, sfab.FabricatedSObject> recordsInTheDatabase = new Map<Id, sfab.FabricatedSObject>();

    public override List<SObject> run(Q query) {
        SObjectType sObjectType = getSObjectTypeFromQ(query);
        List<SObject> filteredRecordsForSObject = new List<SObject>();
        for (sfab.FabricatedSObject fabRecord : recordsInTheDatabase.values()) {
            SObject record = (SObject) fabRecord.toSObject();
            if (record.getSObjectType() == sObjectType) {
                filteredRecordsForSObject.add(record);
            }
        }
        return fromQ(query, filteredRecordsForSObject);
    }

    public override List<SObject> runRaw(String query) {
        throw new QDBException('Raw queries are not supported in InMemoryDatabase');
    }

    public override void doInsert(SObject record) {
        sfab.FabricatedSObject fabricatedRecord = new sfab.FabricatedSObject(
            Type.forName(record.getSObjectType().getDescribe().getName()),
            record.getPopulatedFieldsAsMap()
        );

        Id generatedId = IdGenerator.generate(record.getSObjectType());
        record.Id = generatedId;
        fabricatedRecord.set('Id', generatedId);
        resolveChildRelationships(fabricatedRecord, record);
        recordsInTheDatabase.put(generatedId, fabricatedRecord);
    }

    private void resolveChildRelationships(sfab.FabricatedSObject fabricatedRecord, SObject originalRecord) {
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
                    sfab.FabricatedSObject parentRecord = recordsInTheDatabase.get((Id) originalRecord.get(currentField));
                    // Creating a new fabricated record with the parent record as the parent. We can't store
                    // the original reference because that will create a circular reference, which will
                    // cause a stack overflow error when serializing the object.
                    fabricatedRecord.set(currentField.getDescribe().getRelationshipName(),
                        parentRecord.shallowClone());
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
        return ((SObject) Type.forName(query.FromText).newInstance()).getSObjectType();
    }

    private List<SObject> fromQ(Q query, List<SObject> recordsToFilterFrom) {
        ExpressionBuilder exprBuilder = new ExpressionBuilder();

        for (QICondition condition : query.conditions) {
            exprBuilder.condition(condition);
        }

        for (QOrder order : query.orders) {
            exprBuilder.orderBy(order);
        }

        if (query.NumberOfRowsToSkip != null) {
            exprBuilder.addOffset(query.NumberOfRowsToSkip);
        }

        if (query.NumberOfRowsToQuery != null) {
            exprBuilder.addLimit(query.NumberOfRowsToQuery);
        }

        Object result = Evaluator.run(exprBuilder.build(), recordsToFilterFrom);
        List<SObject> resultRecords = castToSObjectList((List<Object>) result);

        if (query.subQueries.isEmpty()) {
            return resultRecords;
        }

        return filterChildrenBySubqueries(query, resultRecords);
    }

    private List<SObject> filterChildrenBySubqueries(Q query, List<SObject> resultRecords) {
        List<SObject> recordsWithFilteredSubqueries = new List<SObject>();
        for (Q subQuery : query.subQueries) {
            String relationshipName = subQuery.FromText;
            for (SObject currentResultRecord : resultRecords) {
                List<SObject> unfilteredChildren = (List<SObject>) currentResultRecord.getSObjects(relationshipName);
                List<SObject> filteredChildren = fromQ(subQuery, unfilteredChildren ?? new List<SObject>());

                // Find the original sfab for this record so that we can set new child relationships
                sfab.FabricatedSObject originalRecord = recordsInTheDatabase.get(currentResultRecord.Id).clone();
                List<sfab.FabricatedSObject> originalChildrenFiltered = new List<sfab.FabricatedSObject>();
                for (SObject child : filteredChildren) {
                    originalChildrenFiltered.add(recordsInTheDatabase.get(child.Id));
                }

                originalRecord.setChildren(
                    SchemaUtils.getValidChildRelationshipName(relationshipName, currentResultRecord.getSObjectType()),
                    originalChildrenFiltered
                );
                recordsWithFilteredSubqueries.add(originalRecord.toSObject());
            }
        }

        return recordsWithFilteredSubqueries;
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
            String direction = order.SortValue == QOrder.SortOrder.ASCENDING ? '"ASC"' : '"DESC"';
            String nullDirection = order.NullsOrderValue == QOrder.NullsOrder.FIRST ? '"NULLS_FIRST"' : '"NULLS_LAST"';
            expr += '-> SORT(' + order.Field + ',' + direction + ',' + nullDirection + ')';
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
                for (QICondition cond : castedCondition.Conditions) {
                    conditions.add(conditionStringBuilder(cond));
                }

                String operatorAsString = castedCondition.Operator == QConditionGroup.Operator.AND_GROUP ? 'AND' : 'OR';

                String orGroup = operatorAsString + '(';
                for (String cond : conditions) {
                    orGroup += cond + ',';
                }
                orGroup = orGroup.removeEnd(',');
                orGroup += ')';

                return orGroup;
            }

            QCondition cond = (QCondition) condition;
            switch on cond.OperatorValue {
                when EQUALS {
                    return cond.Field + ' == ' + formatFieldValue(cond.FieldValue);
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
                    // Check that the field is a string
                    if (cond.FieldValue instanceof String) {
                        return 'LIKE(' + cond.Field + ',' + formatFieldValue(cond.FieldValue) + ')';
                    } else {
                        throw new QDBException('IS LIKE operator can only be used with String fields');
                    }
                }
                when IS_IN {
                    return 'CONTAINS(' + formatFieldValue(cond.FieldValue) + ',' + cond.Field + ')';
                }
                when NOT_IN {
                    return 'NOT(CONTAINS(' + formatFieldValue(cond.FieldValue) + ',' + cond.Field + '))';
                }
                when else {
                    throw new QDBException('Operator ' + cond.OperatorValue + ' is not supported in InMemoryDatabase');
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
