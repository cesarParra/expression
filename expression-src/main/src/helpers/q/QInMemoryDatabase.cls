@IsTest
public with sharing class QInMemoryDatabase implements QDatabase {
    private final List<SObject> recordsInTheDatabase = new List<SObject>();

    private QInMemoryDatabase() {
    }

    private static QInMemoryDatabase instance;
    public static QInMemoryDatabase getInstance() {
        if (instance == null) {
            instance = new QInMemoryDatabase();
        }
        return instance;
    }

    public List<SObject> run(Q query) {
        return fromQ(query).toSObjectList();
    }

    public void doInsert(SObject record) {
        record.Id = IdGenerator.generate(record.getSObjectType());
        recordsInTheDatabase.add(record);
    }

    public void doInsert(List<SObject> records) {
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

        if (!query.orders.isEmpty()) {

        }

        return builtR;
    }
}
