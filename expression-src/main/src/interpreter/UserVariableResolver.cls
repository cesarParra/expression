public with sharing class UserVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        switch on referenceName.toLowerCase() {
            when 'defaultcurrency' {
                return UserInfo.getDefaultCurrency();
            }
            when 'firstname' {
                return UserInfo.getFirstName();
            }
            when 'language' {
                return UserInfo.getLanguage();
            }
            when 'lastname' {
                return UserInfo.getLastName();
            }
            when 'locale' {
                return UserInfo.getLocale();
            }
            when 'name' {
                return UserInfo.getName();
            }
            when 'timezone' {
                return UserInfo.getTimeZone();
            }
            when 'email' {
                return UserInfo.getUserEmail();
            }
            when 'id' {
                return UserInfo.getUserId();
            }
            when 'type' {
                return UserInfo.getUserType();
            }
            when else {
                throw new UserVariableResolverException('Unknown reference name: ' + referenceName);
            }
        }
    }

    public class UserVariableResolverException extends Exception {}
}
