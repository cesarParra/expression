@IsTest
private class UserGlobalVariableTest {
    private static User getUserToRunAs() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        return new User(Alias = 'standard', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName);
    }

    @IsTest
    static void canReferenceTheUsersDefaultCurrency() {
        String formula = '$User.DefaultCurrency';
        Object result = Evaluator.run(formula);
        // Only checking against null since we don't know if this is an MC
        // org or not.
        Assert.isNotNull(result);
    }

    @IsTest
    static void canReferenceTheUsersFirstName() {
        User toRunAs = getUserToRunAs();
        toRunAs.FirstName = 'Bob';
        System.runAs(toRunAs) {
            String formula = '$User.FirstName';
            Object result = Evaluator.run(formula);
            Assert.areEqual('Bob', result);
        }
    }

    @IsTest
    static void canReferenceTheUsersLanguage() {
        User toRunAs = getUserToRunAs();
        toRunAs.LanguageLocaleKey = 'en_US';
        System.runAs(toRunAs) {
            String formula = '$User.Language';
            Object result = Evaluator.run(formula);
            Assert.areEqual('en_US', result);
        }
    }

    @IsTest
    static void canReferenceTheUsersLastName() {
        User toRunAs = getUserToRunAs();
        toRunAs.LastName = 'Smith';
        System.runAs(toRunAs) {
            String formula = '$User.LastName';
            Object result = Evaluator.run(formula);
            Assert.areEqual('Smith', result);
        }
    }

    @IsTest
    static void canReferenceTheUsersLocale() {
        User toRunAs = getUserToRunAs();
        toRunAs.LanguageLocaleKey = 'en_US';
        System.runAs(toRunAs) {
            String formula = '$User.Locale';
            Object result = Evaluator.run(formula);
            Assert.areEqual('en_US', result);
        }
    }

    @IsTest
    static void canReferenceTheUsersFullName() {
        User toRunAs = getUserToRunAs();
        System.runAs(toRunAs) {
            String formula = '$User.Name';
            Object result = Evaluator.run(formula);
            Assert.isNotNull(result);
        }
    }

    @IsTest
    static void canReferenceTheUsersTimeZone() {
        User toRunAs = getUserToRunAs();
        System.runAs(toRunAs) {
            String formula = '$User.TimeZone';
            Object result = Evaluator.run(formula);
            Assert.isNotNull(result);
        }
    }

    @IsTest
    static void canReferenceTheUsersEmail() {
        User toRunAs = getUserToRunAs();
        toRunAs.Email = 'example@example.com';
        System.runAs(toRunAs) {
            String formula = '$User.Email';
            Object result = Evaluator.run(formula);
            Assert.areEqual('example@example.com', result);
        }
    }

    @IsTest
    static void canReferenceTheUsersId() {
        User toRunAs = getUserToRunAs();
        System.runAs(toRunAs) {
            String formula = '$User.Id';
            Object result = Evaluator.run(formula);
            Assert.isNotNull(result);
        }
    }

    @IsTest
    static void canReferenceTheUsersType() {
        User toRunAs = getUserToRunAs();
        System.runAs(toRunAs) {
            String formula = '$User.Type';
            Object result = Evaluator.run(formula);
            Assert.areEqual('Standard', result);
        }
    }

    @IsTest
    static void throwsExceptionWhenUsingAnInvalidReference() {
        String formula = '$User.NonExistent';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }
}
