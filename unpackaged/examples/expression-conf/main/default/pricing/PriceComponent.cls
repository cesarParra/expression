public with sharing class PriceComponent {
    public Id recordId;
    public Decimal amount;
    public Decimal percentage;
    public Type pricingType;
    public String description;
    public String expression;

    public enum Type {
        LIST_PRICE,
        SURCHARGE,
        DISCOUNT
    }

    public PriceComponent(Price_Component__c record) {
        this.recordId = record.Id;
        this.amount = record.Price__c;
        this.percentage = record.Percent__c;
        this.description = record.Description__c;
        this.expression = record.Expression__c;
        this.pricingType = this.getFromTypeString(record.Type__c);
    }

    private PriceComponent.Type getFromTypeString(String pricingType) {
        switch on pricingType {
            when 'List Price' {
                return PriceComponent.Type.LIST_PRICE;
            }
            when 'Surcharge' {
                return PriceComponent.Type.SURCHARGE;
            }
            when 'Discount' {
                return PriceComponent.Type.DISCOUNT;
            }
        }
        return null;
    }
}
