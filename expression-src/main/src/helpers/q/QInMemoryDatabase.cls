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

        public String build() {
            return expr;
        }
    }
}
