global without sharing class GetListPrice implements IExpressionFunction {
    global Object execute(List<Object> args) {
        if (args.isEmpty()) {
            throw new Interpreter.InterpreterException('GetListPrice requires a record id as an argument');
        }

        String productId = (String)args[0];
        Decimal value = getProductPriceById().get(productId);
        if (value == null) {
            return 0;
        }
        return value;
    }

    private static Map<Id, Decimal> productPriceByIdCache;
    private static Map<Id, Decimal> getProductPriceById() {
        if (productPriceByIdCache != null) {
            return productPriceByIdCache;
        }

        List<Product_Price_Component__c> junctions = [
            SELECT Product__c, Price_Component__r.Price__c
            FROM Product_Price_Component__c
            WHERE Price_Component__r.Type__c = 'List Price'
        ];

        productPriceByIdCache = new Map<Id, Decimal>();
        for (Product_Price_Component__c junction : junctions) {
            productPriceByIdCache.put(junction.Product__c, junction.Price_Component__r.Price__c);
        }
        return productPriceByIdCache;
    }
}
