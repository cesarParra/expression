public with sharing class CustomMetadataVariableResolver {
    public with sharing class CmtApiName implements IGlobalVariableResolver {
        public Object get(String customMetadataApiName) {
           return new CmtRecordName(customMetadataApiName);
        }
    }

    public with sharing class CmtRecordName implements IGlobalVariableResolver {
        private final String cmtApiName;

        public CmtRecordName(String cmtApiName) {
            this.cmtApiName = cmtApiName;
        }

        public Object get(String recordName) {
           return new CmtFieldResolver(cmtApiName, recordName);
        }
    }

    private with sharing class CmtFieldResolver implements IGlobalVariableResolver {
        private final String cmtApiName;
        private final String recordName;

        public CmtFieldResolver(String cmtApiName, String recordName) {
            this.cmtApiName = cmtApiName;
            this.recordName = recordName;
        }

        public Object get(String fieldName) {
            String query = 'SELECT ' + fieldName + ' FROM ' + cmtApiName + ' WHERE DeveloperName = \'' + recordName + '\'';
            List<SObject> records = Database.query(query);
            if (records.isEmpty()) {
                throw new Interpreter.InterpreterException('No ' + cmtApiName + ' record found with DeveloperName = \'' + recordName + '\'');
            }
            return records[0].get(fieldName);
        }
    }
}
