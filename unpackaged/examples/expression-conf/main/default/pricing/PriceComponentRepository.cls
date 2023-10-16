public without sharing class PriceComponentRepository {
    public PriceComponents getForProduct(Id productId) {
        List<Product_Price_Component__c> productPriceComponents =
            [
                SELECT Id, Price_Component__r.Id, Price_Component__r.Price__c, Price_Component__r.Percent__c,
                    Price_Component__r.Expression__c, Price_Component__r.Description__c,
                    Price_Component__r.Type__c
                FROM Product_Price_Component__c
                WHERE Product__c = :productId
            ];

        List<PriceComponent> priceComponentObjects = new List<PriceComponent>();
        for (Product_Price_Component__c junction : productPriceComponents) {
            priceComponentObjects.add(new PriceComponent(junction.Price_Component__r));
        }

        return new PriceComponents(priceComponentObjects);
    }
}
