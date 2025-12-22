@IsTest
private class IntegrationTest {
    @IsTest
    static void usingChildRelationships() {
        Account anyAccount = new Account(Name = 'Sample Account');
        insert anyAccount;
        Contact firstContact = new Contact(FirstName = 'First', LastName = 'Contact', AccountId = anyAccount.Id);
        Contact secondContact = new Contact(FirstName = 'Second', LastName = 'Contact', AccountId = anyAccount.Id);
        insert new List<Contact> { firstContact, secondContact };

        String expressionPiped = '@Context.Contacts -> WHERE(FirstName = "First") -> SIZE() = 1';
        Boolean pipedResult = (Boolean)Evaluator.run(expressionPiped, anyAccount.Id);
        Assert.isTrue(pipedResult, 'There should be exactly one contact with the first name "First".');

        String expressionNested = 'SIZE(WHERE(@Context.Contacts, FirstName = "First")) = 1';
        Boolean nestedResult = (Boolean)Evaluator.run(expressionNested, anyAccount.Id);
        Assert.isTrue(nestedResult, 'There should be exactly one contact with the first name "First".');
    }

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
