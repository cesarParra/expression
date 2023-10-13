global without sharing class CreateSalesOrder implements IExpressionFunction {
    global Object execute(List<Object> args) {
        String productId = (String)args[0];

        Sales_Order__c salesOrder = new Sales_Order__c();
        insert salesOrder;

        Sales_Order_Line__c salesOrderLine = new Sales_Order_Line__c();
        salesOrderLine.Sales_Order__c = salesOrder.Id;
        salesOrderLine.Product__c = productId;

        Decimal listPrice = (Decimal)new GetListPrice().execute(new List<Object> { productId });
        salesOrderLine.Amount__c = listPrice;
        salesOrderLine.Type__c = 'Charge';
        insert salesOrderLine;

        return salesOrderLine.Id;
    }
}
