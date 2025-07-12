public with sharing class UserSettingsVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        switch on referenceName.toLowerCase() {
            when 'approvalposts' {
                return getUserSettings().approvalPosts;
            }
            when 'canAccesspersonalstreams' {
                return getUserSettings().canAccessPersonalStreams;
            }
            when 'canfollow' {
                return getUserSettings().canFollow;
            }
            when 'canmodifyallData' {
                return getUserSettings().canModifyAllData;
            }
            when 'canowngroups' {
                return getUserSettings().canOwnGroups;
            }
            when 'canviewalldata' {
                return getUserSettings().canViewAllData;
            }
            when 'canviewallgroups' {
                return getUserSettings().canViewAllGroups;
            }
            when 'canviewallusers' {
                return getUserSettings().canViewAllUsers;
            }
            when 'canviewcommunityswitcher' {
                return getUserSettings().canViewCommunitySwitcher;
            }
            when 'canviewfulluserprofile' {
                return getUserSettings().canViewFullUserProfile;
            }
            when 'canviewpublicfiles' {
                return getUserSettings().canViewPublicFiles;
            }
            when 'currencysymbol' {
                return getUserSettings().currencySymbol;
            }
            when 'externaluser' {
                return getUserSettings().externalUser;
            }
            when 'filesynclimit' {
                return getUserSettings().fileSyncLimit;
            }
            when 'filesyncstoragelimit' {
                return getUserSettings().fileSyncStorageLimit;
            }
            when 'foldersynclimit' {
                return getUserSettings().folderSyncLimit;
            }
            when 'hasaccesstointernalorg' {
                return getUserSettings().hasAccessToInternalOrg;
            }
            when 'haschatter' {
                return getUserSettings().hasChatter;
            }
            when 'hasfilesync' {
                return getUserSettings().hasFileSync;
            }
            when 'hasfieldservicelocationtracking' {
                return getUserSettings().hasFieldServiceLocationTracking;
            }
            when 'hasfieldservicemobileaccess' {
                return getUserSettings().hasFieldServiceMobileAccess;
            }
            when 'hasfilesyncmanagedclientautoupdate' {
                return getUserSettings().hasFileSyncManagedClientAutoUpdate;
            }
            when 'hasrestdataapiaccess' {
                return getUserSettings().hasRestDataApiAccess;
            }
            when 'timezone' {
                ConnectApi.TimeZone timeZone = getUserSettings().timeZone;
                return new Map<String, Object> {
                    'name' => timeZone.name,
                    'gmtOffset' => timeZone.gmtOffset
                };
            }
            when 'userdefaultcurrencyisocode' {
                return getUserSettings().userDefaultCurrencyIsoCode;
            }
            when 'userid' {
                return getUserSettings().userId;
            }
            when 'userlocale' {
                return getUserSettings().userLocale;
            }
            when else {
                throw new UserSettingsVariableResolverException('Unknown reference name: ' + referenceName);
            }
        }
    }

    private static ConnectApi.UserSettings getUserSettings() {
        return ConnectApi.Organization.getSettings().userSettings;
    }

    public class UserSettingsVariableResolverException extends Exception {}
}
