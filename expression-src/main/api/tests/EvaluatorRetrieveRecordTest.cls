@IsTest
private class EvaluatorRetrieveRecordTest {
    @IsTest
    static void testRetrieveRecordForFormulas() {
        // Setup test data
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test Street',
            BillingCity = 'Test City',
            BillingState = 'TS',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
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
        
        // Create list of formulas that reference various fields
        List<String> formulas = new List<String>{
            'Name', // Simple field reference
            'BillingCity', // Another simple field reference
            'Phone', // Another field from the same object
            'Name + " in " + BillingCity', // Formula with multiple field references
            'Contacts[0].FirstName', // Child relationship field reference
            'Contacts[0].FirstName + " " + Contacts[0].LastName' // More complex relationship reference
        };
        
        // Call the method being tested
        Test.startTest();
        SObject result = Evaluator.retrieveRecordForFormulas(testAccount.Id, formulas);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result, 'Should have retrieved a record');
        
        Account retrievedAccount = (Account)result;
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Should retrieve the correct account');
        System.assertEquals('Test Account', retrievedAccount.Name, 'Name should be retrieved');
        System.assertEquals('Test City', retrievedAccount.BillingCity, 'BillingCity should be retrieved');
        System.assertEquals('555-1234', retrievedAccount.Phone, 'Phone should be retrieved');
        
        // Check for child relationship data
        System.assertNotEquals(null, retrievedAccount.getSObjects('Contacts'), 'Should have retrieved contacts');
        System.assertEquals(1, retrievedAccount.getSObjects('Contacts').size(), 'Should have retrieved one contact');
        System.assertEquals('Test', retrievedAccount.getSObjects('Contacts')[0].get('FirstName'), 'Contact FirstName should be retrieved');
        System.assertEquals('Contact', retrievedAccount.getSObjects('Contacts')[0].get('LastName'), 'Contact LastName should be retrieved');
    }
    
    @IsTest
    static void testRetrieveRecordWithRelationshipFields() {
        // Setup test data with a related object
        User testUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account testAccount = new Account(
            Name = 'Relationship Test Account',
            OwnerId = testUser.Id
        );
        insert testAccount;
        
        // Create formulas that include relationship fields
        List<String> formulas = new List<String>{
            'Owner.Name', // Basic relationship field
            'Owner.Name + " owns " + Name', // Using relationship field in a formula
            'Name'
        };
        
        // Call the method being tested
        Test.startTest();
        SObject result = Evaluator.retrieveRecordForFormulas(testAccount.Id, formulas);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result, 'Should have retrieved a record');
        
        Account retrievedAccount = (Account)result;
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Should retrieve the correct account');
        System.assertEquals('Relationship Test Account', retrievedAccount.Name, 'Name should be retrieved');
        
        // Check for relationship field data
        System.assertNotEquals(null, retrievedAccount.getSObject('Owner'), 'Should have retrieved Owner');
        System.assertEquals(testUser.Name, retrievedAccount.getSObject('Owner').get('Name'), 'Owner Name should be retrieved');
    }
    
    @IsTest
    static void testRetrieveRecordWithInvalidFormula() {
        // Setup test data
        Account testAccount = new Account(Name = 'Error Test Account');
        insert testAccount;
        
        // Create formulas with some valid and some invalid expressions
        List<String> formulas = new List<String>{
            'Name', // Valid
            'ThisFieldDoesNotExist', // Invalid field reference
            'InvalidFunction(Name)', // Invalid function
            'BillingCity' // Valid
        };
        
        // Call the method being tested
        Test.startTest();
        SObject result = Evaluator.retrieveRecordForFormulas(testAccount.Id, formulas);
        Test.stopTest();
        
        // Verify that we still get results with the valid fields
        System.assertNotEquals(null, result, 'Should have retrieved a record despite some invalid formulas');
        
        Account retrievedAccount = (Account)result;
        System.assertEquals(testAccount.Id, retrievedAccount.Id, 'Should retrieve the correct account');
        System.assertEquals('Error Test Account', retrievedAccount.Name, 'Name should be retrieved');
    }
    
    @IsTest
    static void testRetrieveRecordWithEmptyOrNullInputs() {
        // Setup test data
        Account testAccount = new Account(Name = 'Null Test Account');
        insert testAccount;
        
        // Test with null formulas
        Test.startTest();
        SObject resultWithNullFormulas = Evaluator.retrieveRecordForFormulas(testAccount.Id, null);
        System.assertEquals(null, resultWithNullFormulas, 'Should return null with null formulas');
        
        // Test with empty formulas list
        SObject resultWithEmptyFormulas = Evaluator.retrieveRecordForFormulas(testAccount.Id, new List<String>());
        System.assertEquals(null, resultWithEmptyFormulas, 'Should return null with empty formulas');
        
        // Test with null recordId
        SObject resultWithNullId = Evaluator.retrieveRecordForFormulas(null, new List<String>{'Name'});
        System.assertEquals(null, resultWithNullId, 'Should return null with null recordId');
        Test.stopTest();
    }
}