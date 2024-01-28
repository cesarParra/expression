@IsTest
public with sharing class FakeApexAction implements IExpressionFunction {
    public Object execute(List<Object> args) {
        return 'fake';
    }
}
