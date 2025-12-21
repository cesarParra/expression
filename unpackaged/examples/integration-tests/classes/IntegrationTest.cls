@IsTest
private class IntegrationTest {
    @IsTest
    static void hasPurchasedSomethingInThePast() {
        List<CustomRecordContext> contexts = getContexts();

        String pipedExpression = '@Customer.Assets -> WHERE(Product2Id = @Product.Id && Status = "Purchased") -> SIZE() > 0';
        Boolean pipedResult = (Boolean)Evaluator.run(pipedExpression, contexts, new Configuration());
        Assert.isTrue(pipedResult, 'The customer should have purchased the product in the past.');

        String nestedExpression = 'SIZE(WHERE(@Customer.Assets, Product2Id = @Product.Id && Status = "Purchased")) > 0';
        Boolean nestedResult = (Boolean)Evaluator.run(nestedExpression, contexts, new Configuration());
        Assert.isTrue(nestedResult, 'The customer should have purchased the product in the past.');
    }

    private static List<CustomRecordContext> getContexts() {
        Account someAccount = new Account(Name = 'Test Account');
        insert someAccount;
        Contact someone = new Contact(FirstName = 'Test', LastName = 'User', AccountId = someAccount.Id);
        insert someone;
        Product2 sampleProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert sampleProduct;

        Asset sampleAsset = new Asset(
            Name = 'Test Asset',
            ContactId = someone.Id, Status = 'Purchased',
            Product2Id = sampleProduct.Id);
        insert sampleAsset;

        CustomRecordContext customer = new CustomRecordContext('Customer', someone.Id);
        CustomRecordContext product = new CustomRecordContext('Product', sampleProduct.Id);
        List<CustomRecordContext> contexts = new List<CustomRecordContext> { customer, product };
        return contexts;
    }
}
