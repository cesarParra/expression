public with sharing class LabelWrapper {
    public interface ILabel {
        String get(String namespace, String label, String language);
    }

    public with sharing class SystemLabel implements ILabel {
        public String get(String namespace, String label, String language) {
            return System.Label.get(namespace, label, language);
        }
    }

    @TestVisible private static ILabel mockLabel;
    public static ILabel getInstance() {
        if (mockLabel != null) {
            return mockLabel;
        }
        return new SystemLabel();
    }
}
