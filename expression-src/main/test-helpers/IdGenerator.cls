@IsTest
@NamespaceAccessible
public with sharing class IdGenerator {
    private static Integer fakeIdCount = 0;
    private static final String ID_PATTERN = '000000000000';

    @NamespaceAccessible
    public static Id generate(Schema.SObjectType sobjectType) {
        String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
        fakeIdCount++;

        String fakeIdPrefix = ID_PATTERN.substring(
            0,
            ID_PATTERN.length() - String.valueOf(fakeIdCount).length()
        );

        return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
    }
}
