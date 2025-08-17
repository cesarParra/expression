public with sharing class PermissionVariableResolver implements IGlobalVariableResolver {
    private static final Map<String, Boolean> permissionCache = new Map<String, Boolean>();
    public Object get(String referenceName, List<Object> args) {
        if (permissionCache.containsKey(referenceName)) {
            return permissionCache.get(referenceName);
        }

        List<String> namespacePermissionParts = referenceName.split('__');

        String permissionName = referenceName;
        String namespacePrefix = '';
        // Custom permission name can come in 2 flavors, namespace__PermissionName or just PermissionName.
        if (namespacePermissionParts.size() > 1) {
            namespacePrefix = namespacePermissionParts[0];
            permissionName = namespacePermissionParts[1];
        }

        List<CustomPermission> customPermissions = [
                SELECT Id, DeveloperName
                FROM CustomPermission
                WHERE DeveloperName = :permissionName
                AND NamespacePrefix = :namespacePrefix
        ];

        if (customPermissions.size() != 1) {
            permissionCache.put(referenceName, false);
            return false;
        }

        Map<Id, CustomPermission> customPermissionNamesById = new Map<Id, CustomPermission>(customPermissions);

        List<SetupEntityAccess> setupEntities = [
                SELECT SetupEntityId
                FROM SetupEntityAccess
                WHERE SetupEntityId IN :customPermissionNamesById.keySet() AND
                ParentId IN (
                        SELECT PermissionSetId
                        FROM PermissionSetAssignment
                        WHERE AssigneeId = :UserInfo.getUserId()
                )
        ];

        Boolean result = !setupEntities.isEmpty();
        permissionCache.put(referenceName, result);
        return result;
    }
}
