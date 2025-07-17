public with sharing class PermissionVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        return FeatureManagement.checkPermission(referenceName);
    }
}
