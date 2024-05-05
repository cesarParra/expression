public inherited sharing abstract class QDB {
    public static Configuration.SharingMode evaluationSharingMode;

    protected QDB() {}

    @TestVisible private static QDB instance;
    public static QDB getInstance() {
        if (instance == null) {
            if (Test.isRunningTest()) {
                instance = new QInMemoryDatabase();
            } else {
                instance = QSalesforceDatabase.getInstance();
            }
        }
        return instance;
    }

    public static void memory() {
        setInstance(new QInMemoryDatabase());
    }

    public static void salesforce() {
        setInstance(QSalesforceDatabase.getInstance());
    }

    private static void setInstance(QDB instance) {
        QDB.instance = instance;
    }

    public abstract List<SObject> run(Q query);

    public abstract List<SObject> runRaw(String query);

    public abstract void doInsert(SObject record);

    public abstract void doInsert(List<SObject> records);

    public class QDBException extends Exception {}
}
