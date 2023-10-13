public with sharing class StaticResourceVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        return PageReference.forResource('logo').getUrl();
    }
}
