@IsTest
public with sharing class ContactTestRecord extends SObjectTestDataBuilder implements ITestDataBuilder {
    public static ContactTestRecord build() {
        return new ContactTestRecord();
    }

    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public Contact registerNewForInsert() {
        return (Contact)this.registerSObjectForInsert();
    }

    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public ContactTestRecord withLastName(String name) {
        return (ContactTestRecord)this.withData(Contact.LastName, name);
    }

    public ContactTestRecord withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (ContactTestRecord)this.withChildData(childBuilder, relationshipField);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Contact.LastName => 'Perez'
        };
    }
}
