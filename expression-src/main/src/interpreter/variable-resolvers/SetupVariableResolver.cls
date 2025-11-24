public with sharing class SetupVariableResolver implements IGlobalVariableResolver {
    public Object get(String customSettingApiName, List<Object> args) {
        return new CustomSettingApiName(customSettingApiName);
    }

    private static final Map<String, Object> CACHE = new Map<String, Object>();
    public with sharing class CustomSettingApiName implements IGlobalVariableResolver {
        private final String customSettingApiName;

        public CustomSettingApiName(String customSettingApiName) {
            this.customSettingApiName = customSettingApiName;
        }

        public Object get(String referenceName, List<Object> args) {
            String cacheKey = customSettingApiName + '.' + referenceName;
            if (CACHE.containsKey(cacheKey)) {
                return CACHE.get(cacheKey);
            }

            Q customSettingQ = new Q(customSettingApiName)
                .selectFields(new Set<String> { 'SetupOwnerId', referenceName })
                .add(
                    Q.orGroup()
                        .add(Q.condition('SetupOwnerId').equalsTo(UserInfo.getUserId()))
                        .add(Q.condition('SetupOwnerId').equalsTo(UserInfo.getProfileId()))
                        .add(Q.condition('SetupOwnerId').equalsTo(UserInfo.getOrganizationId()))
                );

            List<SObject> customSettings = QDB.getInstance().run(customSettingQ);

            Map<String, SObject> settingsByOwnerId = new Map<String, SObject>();

            for (SObject setting : customSettings) {
                String setupOwnerId = String.valueOf(setting.get('SetupOwnerId'));
                settingsByOwnerId.put(setupOwnerId, setting);
            }

            // Selects the record based on the correct order of precendence, in case
            // there are user, profile and org level settings.
            SObject selectedRecord = settingsByOwnerId.get(UserInfo.getUserId()) ??
                settingsByOwnerId.get(UserInfo.getProfileId()) ??
                settingsByOwnerId.get(UserInfo.getOrganizationId());

            // Add to cache
            CACHE.put(cacheKey, selectedRecord?.get(referenceName));
            return selectedRecord?.get(referenceName);
        }
    }
}
