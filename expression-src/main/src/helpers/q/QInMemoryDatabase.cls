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
        SObjectType sObjectType = getSObjectTypeFromQ(query);
        List<SObject> result = new List<SObject>();
        for (SObject record : recordsInTheDatabase) {
            if (record.getSObjectType() == sObjectType) {
                result.add(record);
            }
        }
        return result;
    }

    private static SObjectType getSObjectTypeFromQ(Q query) {
        return ((SObject) Type.forName(query.fromText).newInstance()).getSObjectType();
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
}
