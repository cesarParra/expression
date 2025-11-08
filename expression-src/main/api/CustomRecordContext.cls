global with sharing class CustomRecordContext {
    global final String key;
    global final Id recordId;
    // Optional record that has already been queried to avoid extra SOQL.
    global final SObject prequeriedRecord;

    global CustomRecordContext(String key, Id recordId) {
        this.key = key;
        this.recordId = recordId;
    }

    global CustomRecordContext(String key, Id recordId, SObject prequeriedRecord) {
        this.key = key;
        this.recordId = recordId;
        this.prequeriedRecord = prequeriedRecord;
    }
}
