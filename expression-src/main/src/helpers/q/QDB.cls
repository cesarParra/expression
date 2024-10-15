public inherited sharing abstract class QDB {
    public static Configuration.SharingMode evaluationSharingMode;

    protected QDB() {}

    @TestVisible private static QDB instance;
    public static QDB getInstance() {
        if (instance == null) {
            instance = QSalesforceDatabase.getInstance();

        }
        return instance;
    }

    public abstract List<SObject> run(Q query);

    public abstract List<SObject> runRaw(String query);

    public abstract void doInsert(SObject record);

    public abstract void doInsert(List<SObject> records);

    public class QDBException extends Exception {}
}
