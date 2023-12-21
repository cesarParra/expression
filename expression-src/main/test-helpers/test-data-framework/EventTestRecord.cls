@IsTest
public with sharing class EventTestRecord extends SObjectTestDataBuilder implements ITestDataBuilder {
    public static EventTestRecord build() {
        return new EventTestRecord();
    }

    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Event.SObjectType;
    }

    public Event registerNewForInsert() {
        return (Event)this.registerSObjectForInsert();
    }

    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public EventTestRecord withAStartTimeOf(Datetime startTime) {
        return (EventTestRecord) this.withData(Event.StartDateTime, startTime);
    }

    public ContactTestRecord withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (ContactTestRecord)this.withChildData(childBuilder, relationshipField);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Event.DurationInMinutes => 60
        };
    }
}
