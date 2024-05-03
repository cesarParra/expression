public abstract class QDB {
    protected QDB() {
    }

    private static QDB instance;
    public static QDB getInstance() {
        if (instance == null) {
            if (Test.isRunningTest()) {
                instance = new QInMemoryDatabase();
            } else {
                instance = new QSalesforceDatabase();
            }
        }
        return instance;
    }

    public static void memory() {
        setInstance(new QInMemoryDatabase());
    }

    public static void salesforce() {
        setInstance(new QSalesforceDatabase());
    }

    private static void setInstance(QDB instance) {
        QDB.instance = instance;
    }

    public abstract List<SObject> run(Q query);

    public abstract void doInsert(SObject record);

    public abstract void doInsert(List<SObject> records);

    public class QDBException extends Exception {
    }
}
