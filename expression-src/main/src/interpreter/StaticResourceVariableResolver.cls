public with sharing class StaticResourceVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName) {
        return PageReference.forResource('logo').getUrl();
    }
}
