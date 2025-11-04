// TODO:Make global
public with sharing class CustomRecordContext {
    public final String key;
    public final Id recordId;

    public CustomRecordContext(String key, Id recordId) {
        this.key = key;
        this.recordId = recordId;
    }
}
