// TODO:Make global
public with sharing class CustomRecordContext {
    public final String key;
    public final Id recordId;
    // Optional record that has already been queried to avoid extra SOQL.
    public final SObject prequeriedRecord;

    public CustomRecordContext(String key, Id recordId) {
        this.key = key;
        this.recordId = recordId;
    }

    public CustomRecordContext(String key, Id recordId, SObject prequeriedRecord) {
        this.key = key;
        this.recordId = recordId;
        this.prequeriedRecord = prequeriedRecord;
    }
}
