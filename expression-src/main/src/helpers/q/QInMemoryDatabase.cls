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
        return recordsInTheDatabase;
    }

    public void doInsert(Account record) {
        record.Id = IdGenerator.generate(Account.SObjectType);
        recordsInTheDatabase.add(record);
    }

    public void doInsert(List<Account> records) {
        for (Account record : records) {
            doInsert(record);
        }
    }
}
