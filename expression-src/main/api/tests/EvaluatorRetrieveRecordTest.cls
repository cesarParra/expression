@IsTest
private class EvaluatorRetrieveRecordTest {
    @IsTest
    static void testRetrieveRecordForFormulas() {
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test Street',
            BillingCity = 'Test City',
            BillingState = 'Washington',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            Phone = '555-1234'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            Phone = '555-5678'
        );
        insert testContact;
        
        List<String> formulas = new List<String>{
            'Name',
            'BillingCity',
            'Phone',
            'Name + " in " + BillingCity',
            'MAP(Contacts, FirstName) -> FIRST()',
            'MAP(Contacts, FirstName) -> FIRST() + " " + MAP(Contacts, LastName) -> FIRST()'
        };
        
        Test.startTest();
        SObject result = Evaluator.retrieveRecordForFormulas(testAccount.Id, formulas);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should have retrieved a record');
        
        Account retrievedAccount = (Account)result;
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Should retrieve the correct account');
        System.assertEquals('Test Account', retrievedAccount.Name, 'Name should be retrieved');
        System.assertEquals('Test City', retrievedAccount.BillingCity, 'BillingCity should be retrieved');
        System.assertEquals('555-1234', retrievedAccount.Phone, 'Phone should be retrieved');
        
        System.assertNotEquals(null, retrievedAccount.getSObjects('Contacts'), 'Should have retrieved contacts');
        System.assertEquals(1, retrievedAccount.getSObjects('Contacts').size(), 'Should have retrieved one contact');
        System.assertEquals('Test', retrievedAccount.getSObjects('Contacts')[0].get('FirstName'), 'Contact FirstName should be retrieved');
        System.assertEquals('Contact', retrievedAccount.getSObjects('Contacts')[0].get('LastName'), 'Contact LastName should be retrieved');
    }
    
    @IsTest
    static void testRetrieveRecordWithRelationshipFields() {
        User testUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account testAccount = new Account(
            Name = 'Relationship Test Account',
            OwnerId = testUser.Id
        );
        insert testAccount;
        
        List<String> formulas = new List<String>{
            'Owner.Name + " owns " + Name',
            'Name'
        };
        
        Test.startTest();
        SObject result = Evaluator.retrieveRecordForFormulas(testAccount.Id, formulas);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should have retrieved a record');
        
        Account retrievedAccount = (Account)result;
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Should retrieve the correct account');
        System.assertEquals('Relationship Test Account', retrievedAccount.Name, 'Name should be retrieved');
        
        System.assertNotEquals(null, retrievedAccount.getSObject('Owner'), 'Should have retrieved Owner');
        System.assertEquals(testUser.Name, retrievedAccount.getSObject('Owner').get('Name'), 'Owner Name should be retrieved');
    }
    
    @IsTest
    static void testRetrieveRecordWithInvalidFormula() {
        Account testAccount = new Account(Name = 'Error Test Account');
        insert testAccount;
        
        List<String> formulas = new List<String>{
            'Name',
            'ThisFieldDoesNotExist',
            'InvalidFunction(Name)',
            'BillingCity'
        };
        
        Test.startTest();
        SObject result = Evaluator.retrieveRecordForFormulas(testAccount.Id, formulas);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should have retrieved a record despite some invalid formulas');
        
        Account retrievedAccount = (Account)result;
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Should retrieve the correct account');
        System.assertEquals('Error Test Account', retrievedAccount.Name, 'Name should be retrieved');
    }
    
    @IsTest
    static void testRetrieveRecordWithEmptyOrNullInputs() {
        Account testAccount = new Account(Name = 'Null Test Account');
        insert testAccount;
        
        Test.startTest();
        SObject resultWithNullFormulas = Evaluator.retrieveRecordForFormulas(testAccount.Id, null);
        System.assertEquals(null, resultWithNullFormulas, 'Should return null with null formulas');
        
        SObject resultWithEmptyFormulas = Evaluator.retrieveRecordForFormulas(testAccount.Id, new List<String>());
        System.assertEquals(null, resultWithEmptyFormulas, 'Should return null with empty formulas');
        
        SObject resultWithNullId = Evaluator.retrieveRecordForFormulas(null, new List<String>{'Name'});
        System.assertEquals(null, resultWithNullId, 'Should return null with null recordId');
        Test.stopTest();
    }
}