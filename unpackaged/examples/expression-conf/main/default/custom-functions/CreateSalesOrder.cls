global without sharing class CreateSalesOrder implements IExpressionFunction {
    global Object execute(List<Object> args) {
        String productId = (String)args[0];

        Sales_Order__c salesOrder = new Sales_Order__c();
        insert salesOrder;

        List<Sales_Order_Line__c> lines = new SalesOrderLinePricingService()
            .buildLinesForProduct(productId);
        for (Sales_Order_Line__c line : lines) {
            line.Sales_Order__c = salesOrder.Id;
        }
        insert lines;

        return salesOrder.Id;
    }
}
