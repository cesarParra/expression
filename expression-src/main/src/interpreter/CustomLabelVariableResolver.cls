public with sharing class CustomLabelVariableResolver {
    public class CustomLabelResolverWrapper implements IGlobalVariableResolver {
        public Object get(String namespace, List<Object> args) {
            return new CustomLabelResolver(namespace);
        }
    }

    public class CustomLabelResolver implements IGlobalVariableResolver {
        private String namespace;

        public CustomLabelResolver(String namespace) {
            this.namespace = namespace;
        }

        public Object get(String referenceName, List<Object> args) {
            String userLanguage = UserInfo.getLanguage();
            if (namespace == 'c') {
                namespace = '';
            }
            return LabelWrapper.getInstance().get(namespace, referenceName, userLanguage);
        }
    }
}
