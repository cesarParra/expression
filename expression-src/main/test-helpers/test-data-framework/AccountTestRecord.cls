@IsTest
public with sharing class AccountTestRecord extends SObjectTestDataBuilder implements ITestDataBuilder {
    public static AccountTestRecord any() {
        return new AccountTestRecord();
    }

    public static AccountTestRecord build() {
        return new AccountTestRecord();
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

    public AccountTestRecord named(String name) {
        return (AccountTestRecord)this.withData(Account.Name, name);
    }

    public AccountTestRecord withBillingCity(String billingCity) {
        return (AccountTestRecord)this.withData(Account.BillingCity, billingCity);
    }

    public AccountTestRecord withNumberOfEmployees(Integer numberOfEmployees) {
        return (AccountTestRecord)this.withData(Account.NumberOfEmployees, numberOfEmployees);
    }

    public AccountTestRecord withAnnualRevenue(Integer annualRevenue) {
        return (AccountTestRecord)this.withData(Account.AnnualRevenue, annualRevenue);
    }

    public AccountTestRecord withAChildContact() {
        this.withChild(
            SObjectTestDataBuilder.of(Contact.SObjectType),
            Contact.AccountId
        );
        return this;
    }

    public AccountTestRecord withAChildContact(ITestDataBuilder childBuilder) {
        this.withChild(childBuilder, Contact.AccountId);
        return this;
    }

    public ITestDataBuilder withChildContacts(Integer i) {
        for (Integer j = 0; j < i; j++) {
            this.withChild(
                SObjectTestDataBuilder.of(Contact.SObjectType),
                Contact.AccountId
            );
        }
        return this;
    }

    public AccountTestRecord withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (AccountTestRecord)this.withChildData(childBuilder, relationshipField);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Account.Name => 'ACME'
        };
    }
}
