@IsTest
private class EnvironmentTest {
    @IsTest
    static void environmentsAreEqualWhenTheyHaveTheSameSObjectContext() {
        SObject context = new Account(Name = 'Test');
        Environment environment1 = new Environment(context);
        Environment environment2 = new Environment(context);
        Assert.areEqual(environment1, environment2);
    }

    @IsTest
    static void environmentsAreNotEqualWhenTheyHaveDifferentSObjectContexts() {
        SObject context1 = new Account(Name = 'Test');
        SObject context2 = new Account(Name = 'Test2');
        Environment environment1 = new Environment(context1);
        Environment environment2 = new Environment(context2);
        Assert.areNotEqual(environment1, environment2);
    }

    @IsTest
    static void environmentsAreEqualWhenTheyHaveTheSameParentEnvironment() {
        Environment parentEnvironment = new Environment();
        Environment environment1 = new Environment(parentEnvironment);
        Environment environment2 = new Environment(parentEnvironment);
        Assert.areEqual(environment1, environment2);
    }

    @IsTest
    static void environmentsAreNotEqualWhenTheyHaveDifferentParentEnvironments() {
        Environment parentEnvironment1 = new Environment();
        Environment environment1 = new Environment(parentEnvironment1);
        Environment environment2 = new Environment((Environment) null);
        Assert.areNotEqual(environment1, environment2);
    }

    @IsTest
    static void environmentsAreEqualWhenTheyHaveTheSameVariables() {
        Environment environment1 = new Environment();
        environment1.define('name', 'value');
        Environment environment2 = new Environment();
        environment2.define('name', 'value');
        Assert.areEqual(environment1, environment2);
    }
}
