@IsTest
public with sharing class AnAccountRecord extends SObjectTestDataBuilder implements ITestDataBuilder {
    public static AnAccountRecord any() {
        return new AnAccountRecord();
    }

    public static AnAccountRecord build() {
        return new AnAccountRecord();
    }

    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public Account registerNewForInsert() {
        return (Account)this.registerSObjectForInsert();
    }

    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public AnAccountRecord named(String name) {
        return (AnAccountRecord)this.withData(Account.Name, name);
    }

    public AnAccountRecord withAChildContact() {
        this.withChild(
            SObjectTestDataBuilder.of(Contact.SObjectType),
            Contact.AccountId
        );
        return this;
    }

    public AnAccountRecord withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (AnAccountRecord)this.withChildData(childBuilder, relationshipField);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Account.Name => 'ACME'
        };
    }
}
