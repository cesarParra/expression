public with sharing class SalesOrderLinePricingService {
    public List<Sales_Order_Line__c> buildLinesForProduct(Id productId) {
        PriceComponents components = new PriceComponentRepository().getForProduct(productId);

        List<Sales_Order_Line__c> lines = new List<Sales_Order_Line__c>();

        // Main SOL using the Product Id as well as the List Price
        Sales_Order_Line__c salesOrderLine = new Sales_Order_Line__c();
        salesOrderLine.Product__c = productId;
        salesOrderLine.Amount__c = components.getListPrice()?.amount;
        salesOrderLine.Source_Price_Component__c = components.getListPrice()?.recordId;
        salesOrderLine.Type__c = 'Charge';
        lines.add(salesOrderLine);

        System.debug('salesOrderLine: ' + salesOrderLine);

        Configuration config = new Configuration().respectSharing(false);
        // Surcharges
        for (PriceComponent surcharge : components.getSurcharges()) {
            Boolean shouldInclude = (Boolean)Evaluator.run(surcharge.expression, config);
            if (!shouldInclude) {
                continue;
            }

            Sales_Order_Line__c lineForSurcharge = new Sales_Order_Line__c();
            lineForSurcharge.Product__c = productId;
            lineForSurcharge.Amount__c = surcharge.amount;
            lineForSurcharge.Source_Price_Component__c = surcharge.recordId;
            lineForSurcharge.Type__c = 'Charge';

            System.debug('lineForSurcharge: ' + lineForSurcharge);

            lines.add(lineForSurcharge);
        }

        // Discounts
        for (PriceComponent discount : components.getDiscounts()) {
            Boolean shouldInclude = (Boolean)Evaluator.run(discount.expression, config);
            if (!shouldInclude) {
                continue;
            }

            Sales_Order_Line__c discountLine = new Sales_Order_Line__c();
            discountLine.Product__c = productId;
            discountLine.Amount__c = (discount.amount) * -1;
            discountLine.Source_Price_Component__c = discount.recordId;
            discountLine.Type__c = 'Discount';

            System.debug('discountLine: ' + discountLine);

            lines.add(discountLine);
        }

        return lines;
    }
}
