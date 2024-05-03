@IsTest
public with sharing class QInMemoryDatabase extends QDB {
    private final List<SObject> recordsInTheDatabase = new List<SObject>();

    public override List<SObject> run(Q query) {
        return fromQ(query).toSObjectList();
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

    private R fromQ(Q query) {
        SObjectType sObjectType = getSObjectTypeFromQ(query);
        R builtR = R.of(recordsInTheDatabase)
            .filter(R.isOfSObjectType.apply(sObjectType));

        for (QOrder order : query.orders) {
            Func direction = order.sortValue == QOrder.SortOrder.ASCENDING ?
                order.nullsValue == QOrder.NullsOrder.LAST ? R.ascend : R.ascendNullsFirst :
                R.descend;
            builtR = builtR.sortBy((Func) direction.run(R.prop.apply(order.field)));
        }

        return builtR;
    }
}
