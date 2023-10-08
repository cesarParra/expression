public with sharing class CustomLabelVariableResolver {
    public class CustomLabelResolverWrapper implements IGlobalVariableResolver {
        public Object get(String namespace) {
            return new CustomLabelResolver(namespace);
        }
    }

    public class CustomLabelResolver implements IGlobalVariableResolver {
        private String namespace;

        public CustomLabelResolver(String namespace) {
            this.namespace = namespace;
        }

        public Object get(String referenceName) {
            String userLanguage = UserInfo.getLanguage();
            if (namespace == 'c') {
                namespace = '';
            }
            return LabelWrapper.getInstance().get(namespace, referenceName, userLanguage);
        }
    }
}
