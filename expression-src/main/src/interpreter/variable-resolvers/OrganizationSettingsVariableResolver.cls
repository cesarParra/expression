public with sharing class OrganizationSettingsVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        switch on referenceName.toLowerCase() {
            when 'name' {
                return getOrganizationSettings().name;
            }
            when 'orgid' {
                return getOrganizationSettings().orgId;
            }
            when else {
                throw new OrganizationSettingsVariableResolverException('Unknown reference name: ' + referenceName);
            }
        }
    }

    private static ConnectApi.OrganizationSettings getOrganizationSettings() {
        return ConnectApi.Organization.getSettings();
    }

    public class OrganizationSettingsVariableResolverException extends Exception {}
}
