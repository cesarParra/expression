public with sharing class sfab {
    public virtual class sfab_FabricatedSObject {
        private final Type sType;
        @TestVisible private Map<String, sfab_FabricatedSObjectNode> nodes = new Map<String, sfab_FabricatedSObjectNode>();

        final sfab_ObjectDescriber objectDescriber = new sfab_ObjectDescriber();

        public sfab_FabricatedSObject(Type sType) {
            this.sType = sType;
        }

        public sfab_FabricatedSObject(Type sType, Map<Schema.SObjectField, Object> fields) {
            this(sType);
            set(fields);
        }

        public sfab_FabricatedSObject(Type sType, Map<String, Object> fields) {
            this(sType);
            set(fields);
        }

        public sfab_FabricatedSObject shallowClone() {
            // Clones all populated fields except the child relationhips
            List<sfab_FabricatedSObjectNode> nodes = new List<sfab_FabricatedSObjectNode>();
            for (sfab_FabricatedSObjectNode node : this.nodes.values()) {
                if (!(node instanceof sfab_ChildRelationshipNode)) {
                    nodes.add(node);
                }
            }
            return new sfab_FabricatedSObject(sType, nodes);
        }

        @TestVisible
        protected sfab_FabricatedSObject(Type sType, List<sfab_FabricatedSObjectNode> nodes) {
            this.sType = sType;
            this.nodes = new Map<String, sfab_FabricatedSObjectNode>();
            for (sfab_FabricatedSObjectNode node : nodes) {
                setNode(node.getName(), node);
            }
        }

        public sfab_FabricatedSObject set(Schema.SObjectField field, Object value) {
            return setField(field, value);
        }

        public sfab_FabricatedSObject set(String fieldName, Object value) {
            // This looks like it duplicates the overloading of 'set', but unfortunately Apex determines the method to call
            // based on the static type of a parameter rather than the dynamic type.
            // I.E. if a passed parameter's value is declared as 'Object' it will always call the 'Object'
            // defined version of an overloaded method even when a more specific type matches for a given value.
            // This means that 'setParentField' will always call this version of the overloaded method regardless
            // of the contents of the value parameter.  So we need to manually check the instance type in the code.
            if (value instanceof List<sfab_FabricatedSObject>) {
                return setChildren(fieldName, (List<sfab_FabricatedSObject>) value);
            }

            if (value instanceof sfab_FabricatedSObject) {
                return setParent(fieldName, (sfab_FabricatedSObject) value);
            }

            return setField(fieldName, value);
        }

        public sfab_FabricatedSObject set(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
            return setParent(relationshipName, fabricatedParent);
        }

        public sfab_FabricatedSObject set(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
            return setChildren(relationshipName, fabricatedChildren);
        }

        public sfab_FabricatedSObject add(String relationshipName, sfab_FabricatedSObject fabricatedChild) {
            return addChild(relationshipName, fabricatedChild);
        }

        public sfab_FabricatedSObject set(Map<Schema.SObjectField, Object> fields) {
            for (Schema.SObjectField field : fields.keySet()) {
                setField(field, fields.get(field));
            }
            return this;
        }

        public sfab_FabricatedSObject set(Map<String, Object> fields) {
            for (String fieldName : fields.keySet()) {
                set(fieldName, fields.get(fieldName));
            }
            return this;
        }

        public sfab_FabricatedSObject setField(Schema.SObjectField field, Object value) {
            return setDirectField(field.getDescribe().getName(), value);
        }

        public sfab_FabricatedSObject setField(String fieldName, Object value) {
            if (new sfab_FieldNameSplitter(fieldName).isAParentNavigation()) {
                return setParentField(fieldName, value);
            }
            return setDirectField(fieldName, value);
        }

        public sfab_FabricatedSObject setParent(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
            if (new sfab_FieldNameSplitter(relationshipName).isAParentNavigation()) {
                return setParentField(relationshipName, fabricatedParent);
            }
            return setDirectParent(relationshipName, fabricatedParent);
        }

        public sfab_FabricatedSObject setChildren(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
            if (new sfab_FieldNameSplitter(relationshipName).isAParentNavigation()) {
                return setParentField(relationshipName, fabricatedChildren);
            }
            return setDirectChildren(relationshipName, fabricatedChildren);
        }

        public sfab_FabricatedSObject addChild(String relationshipName, sfab_FabricatedSObject fabricatedChild) {

            if (new sfab_FieldNameSplitter(relationshipName).isAParentNavigation()) {
                addParentChild(relationshipName, fabricatedChild);
            } else {
                childFieldIsChildRelationship(relationshipName);
                checkTypeIsValidForChildRelationship(relationshipName, fabricatedChild);
                if (!nodeExists(relationshipName)) {
                    setNode(relationshipName, new sfab_ChildRelationshipNode(relationshipName));
                }
                getChildRelationshipNode(relationshipName).addChild(fabricatedChild);
            }
            return this;
        }

        public SObject toSObject() {
            SObject newObject = (SObject) JSON.deserialize(JSON.serialize(serialize()), sType);
            postBuildProcess(newObject);
            return newObject;
        }

        private void postBuildProcess(SObject objectToProcess) {
            for (String nodeName : nodes.keySet()) {
                nodes.get(nodeName).postBuildProcess(objectToProcess);
            }
        }

        private virtual Map<String, Object> serialize() {
            Map<String, Object> fields = new Map<String, Object>();
            for (sfab_FabricatedSObjectNode node : nodes.values()) {
                fields.putAll(node.serialize());
            }
            return fields;
        }

        public String getSobjectName() {
            return String.valueOf(sType);
        }

        private sfab_FieldNameSplitter defaultParentField(String fieldName) {

            sfab_FieldNameSplitter fieldNameSplitter = new sfab_FieldNameSplitter(fieldName);
            String parentFieldName = fieldNameSplitter.getParentFieldName();

            checkFieldIsParentRelationship(parentFieldName);

            if (!nodeExists(parentFieldName)) {
                try {
                    set(parentFieldName, objectDescriber.buildFabricatedObjectForRelationship(getSobjectName(), parentFieldName));
                } catch (Exception e) {
                    throw new ParentRelationshipObjectCannotBeAutoCreatedException('Could not auto-assign an object for the field ' + fieldName + ': ' + e.getMessage());
                }
            }

            return fieldNameSplitter;
        }

        private sfab_FabricatedSObject setDirectField(String fieldName, Object value) {

            Schema.SObjectField theField = objectDescriber.getField(getSobjectName(), fieldName);

            if (theField == null) {

                if (objectDescriber.objectHasParentRelationshipNamed(getSobjectName(), fieldName)) {
                    throw new FieldIsNotSimpleFieldException('The field ' + getSobjectName() + '.' + fieldName + ' cannot to set to a primitive, it is a parent relationship field');
                }

                if (objectDescriber.objectHasChildRelationshipNamed(getSobjectName(), fieldName)) {
                    throw new FieldIsNotSimpleFieldException('The field ' + getSobjectName() + '.' + fieldName + ' cannot to set to a primitive, it is a child relationship field');
                }

                throw new FieldDoesNotExistException('The field ' + getSobjectName() + '.' + fieldName + ' does not exist');
            }

            return setNode(fieldName, new sfab_FieldValuePairNode(theField, value));
        }

        private sfab_FabricatedSObject setDirectParent(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
            checkFieldIsParentRelationship(relationshipName);
            checkTypeIsValidForParentRelationship(relationshipName, fabricatedParent);
            return setNode(relationshipName, new sfab_ParentRelationshipNode(relationshipName, fabricatedParent));
        }

        private sfab_FabricatedSObject setDirectChildren(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
            childFieldIsChildRelationship(relationshipName);
            checkTypeIsValidForChildRelationship(relationshipName, fabricatedChildren);
            return setNode(relationshipName, new sfab_ChildRelationshipNode(relationshipName, fabricatedChildren));
        }

        private sfab_FabricatedSObject setParentField(String fieldName, Object value) {
            sfab_FieldNameSplitter fields = defaultParentField(fieldName);
            getParentRelationshipNode(fields.getParentFieldName()).set(fields.getChildFieldName(), value);
            return this;
        }

        private sfab_FabricatedSObject addParentChild(String fieldName, sfab_FabricatedSObject fabricatedChild) {
            sfab_FieldNameSplitter fields = defaultParentField(fieldName);
            getParentRelationshipNode(fields.getParentFieldName()).add(fields.getChildFieldName(), fabricatedChild);
            return this;
        }

        private Boolean nodeExists(String nodeName) {
            return nodes.containsKey(nodeName);
        }

        private sfab_FabricatedSObject setNode(String nodeName, sfab_FabricatedSObjectNode node) {
            nodes.put(nodeName, node);
            return this;
        }

        private sfab_FabricatedSObjectNode getNode(String nodeName) {
            if (!nodeExists(nodeName)) {
                throw new NodeNotSetException('Attempt to get the value of node "' + nodeName + '" when it was not set');
            }
            return nodes.get(nodeName);
        }

        private sfab_ParentRelationshipNode getParentRelationshipNode(String relationshipName) {
            return ((sfab_ParentRelationshipNode) getNode(relationshipName));
        }

        private sfab_ChildRelationshipNode getChildRelationshipNode(String relationshipName) {
            return ((sfab_ChildRelationshipNode) getNode(relationshipName));
        }

        private void checkFieldIsParentRelationship(String parentFieldName) {
            if (!objectDescriber.objectHasParentRelationshipNamed(getSobjectName(), parentFieldName)) {
                if (objectDescriber.objectHasSimpleFieldNamed(getSobjectName(), parentFieldName)
                    || objectDescriber.objectHasChildRelationshipNamed(getSobjectName(), parentFieldName)) {
                    throw new FieldIsNotParentRelationshipException('The field ' + getSobjectName() + '.' + parentFieldName + ' is not a parent relationship');
                }

                throw new ParentRelationshipDoesNotExistException('The parent relationship ' + getSobjectName() + '.' + parentFieldName + ' does not exist');
            }
        }

        private void checkTypeIsValidForParentRelationship(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
            List<String> validObjectTypes = objectDescriber.getObjectTypesForParentRelationship(getSobjectName(), relationshipName);
            if (!validObjectTypes.contains(fabricatedParent.getSobjectName())) {
                throw new FieldIsADifferentTypeException('The field ' + getSobjectName() + '.' + relationshipName + ' is ' + String.join(validObjectTypes, ',') + ', not ' + fabricatedParent.getSobjectName());
            }
        }

        private void checkTypeIsValidForChildRelationship(String relationshipName, sfab_FabricatedSObject fabricatedChild) {
            String validObjectType = objectDescriber.getObjectTypeForChildRelationship(getSobjectName(), relationshipName);
            if (validObjectType != fabricatedChild.getSobjectName()) {
                throw new FieldIsADifferentTypeException('The relationship ' + getSobjectName() + '.' + relationshipName + ' is ' + validObjectType + ', not ' + fabricatedChild.getSobjectName());
            }
        }

        private void checkTypeIsValidForChildRelationship(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
            for (sfab_FabricatedSObject thisChild : fabricatedChildren) {
                checkTypeIsValidForChildRelationship(relationshipName, thisChild);
            }
        }

        private void childFieldIsChildRelationship(String childRelationshipName) {

            if (!objectDescriber.objectHasChildRelationshipNamed(getSobjectName(), childRelationshipName)) {
                if (objectDescriber.objectHasSimpleFieldNamed(getSobjectName(), childRelationshipName)
                    || objectDescriber.objectHasParentRelationshipNamed(getSobjectName(), childRelationshipName)) {
                    throw new FieldIsNotChildRelationshipException('The field ' + getSobjectName() + '.' + childRelationshipName + ' is not a child relationship');
                }

                throw new ChildRelationshipDoesNotExistException('The child relationship ' + getSobjectName() + '.' + childRelationshipName + ' does not exist');
            }
        }
    }

    public class FieldDoesNotExistException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}
    public class ChildRelationshipDoesNotExistException extends Exception {}
    public class FieldIsNotSimpleFieldException extends Exception {}
    public class FieldIsNotParentRelationshipException extends Exception {}
    public class FieldIsNotChildRelationshipException extends Exception {}
    public class FieldIsADifferentTypeException extends Exception {}
    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}
    public class NodeNotSetException extends Exception {}

    public class sfab_ChildRelationshipNode implements sfab_FabricatedSObjectNode {
        @TestVisible private String fieldName;
        @TestVisible private List<sfab_FabricatedSObject> children;

        public sfab_ChildRelationshipNode(String fieldName) {
            this.fieldName = fieldName;
            this.children = new List<sfab_FabricatedSObject>();
        }

        public sfab_ChildRelationshipNode(String fieldName, List<sfab_FabricatedSObject> children) {
            this.fieldName = fieldName;
            this.children = children;
        }

        public sfab_ChildRelationshipNode addChild(sfab_FabricatedSObject child) {
            this.children.add(child);
            return this;
        }

        public String getName() {
            return fieldName;
        }

        public Integer getNumberOfChildren() {
            return children.size();
        }

        public List<sfab_FabricatedSObject> getChildren() {
            return children;
        }

        public Map<String, Object> serialize() {
            List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();

            for (sfab_FabricatedSObject child : children) {
                serializedChildren.add(child.serialize());
            }

            return new Map<String, Object>{
                fieldName => new Map<String, Object>{
                    'totalSize' => children.size(),
                    'done' => true,
                    'records' => serializedChildren
                }
            };
        }

        public void postBuildProcess(Object objectToProcess) {
            // Note: this relies on the deserialization of the Fabricated SObject returning the
            // child objects in same order as the input map, otherwise the Blob field values
            // will be applied to the wrong objects.  As far as we can tell, this is reliable
            // at the time of writing.  If it becomes not the case, this will need re-writing
            List<SObject> childSobjects = ((SObject) objectToProcess).getSObjects(fieldName);
            for (Integer i = 0; i < childSobjects.size(); i++) {
                children[i].postBuildProcess(childSobjects[i]);
            }
        }
    }

    public interface sfab_FabricatedSObjectNode {
        Map<String, Object> serialize();
        void postBuildProcess(Object objectToProcess);
        String getName();
    }

    public class sfab_FabricatedSObjectNodeStub implements sfab_FabricatedSObjectNode {
        public Boolean serializeInvoked = false;
        public Map<String, Object> serializedNode;
        private String name;

        public sfab_FabricatedSObjectNodeStub(String name) {
            serializedNode = new Map<String, Object>();
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public sfab_FabricatedSObjectNodeStub(Map<String, Object> serializedNode) {
            this.serializedNode = serializedNode;
        }

        public Map<String, Object> serialize() {
            serializeInvoked = true;
            return serializedNode;
        }

        public void postBuildProcess(Object objectToProcess) {
        }
    }

    public class sfab_FabricatedSObjectStub extends sfab_FabricatedSObject {
        private Map<String, Object> serializedMap;
        @testVisible private Boolean serializeInvoked = false;

        public sfab_FabricatedSObjectStub(Type sType) {
            super(sType);
            this.serializedMap = new Map<String, Object>();
        }

        public sfab_FabricatedSObjectStub(Type sType, Map<String, Object> serializedMap) {
            super(sType);
            this.serializedMap = serializedMap;
        }

        public override Map<String, Object> serialize() {
            serializeInvoked = true;
            return serializedMap;
        }
    }

    public class sfab_FieldValuePairNode implements sfab_FabricatedSObjectNode {
        @testVisible protected Schema.SObjectField field;
        @testVisible protected Object value;

        public sfab_FieldValuePairNode(Schema.SObjectField field, Object value) {
            this.field = field;
            this.value = value;
        }

        public String getName() {
            return field?.getDescribe().getName();
        }

        public Object getValue() {
            return value;
        }

        public Map<String, Object> serialize() {
            if (fieldIsBlob()) {
                return new Map<String, Object>(); // is handled by the post process instead as deserializing a blob field does not work (API 50)
            } else {
                return new Map<String, Object>{
                    getName() => value
                };
            }
        }

        public void postBuildProcess(Object objectToProcess) {
            if (fieldIsBlob()) {
                Blob valueToSet;
                if (value instanceOf Blob) {
                    valueToSet = (Blob) value;
                } else if (value instanceOf String) {
                    valueToSet = Blob.valueOf((String) value);
                }
                ((SObject) objectToProcess).put(field, valueToSet);
            }
        }

        private Boolean fieldIsBlob() {
            return field.getDescribe().getType() == Schema.DisplayType.BASE64;
        }
    }

    static Map<String, SingleObjectDescriber> singleObjectDescribers = new Map<String, SingleObjectDescriber>();

    public with sharing class sfab_ObjectDescriber {

        public SObjectField getField(String objectName, String fieldName) {
            ensureSingleObjectDescriberIsInitialised(objectName);
            return getObjectDescriber(objectName)?.getField(fieldName);
        }

        public Boolean objectHasSimpleFieldNamed(String objectName, String fieldName) {
            ensureSingleObjectDescriberIsInitialised(objectName);
            return getObjectDescriber(objectName)?.hasSimpleFieldNamed(fieldName);
        }

        public Boolean objectHasParentRelationshipNamed(String objectName, String relationshipName) {
            ensureSingleObjectDescriberIsInitialised(objectName);
            return getObjectDescriber(objectName)?.hasParentRelationshipNamed(relationshipName);
        }

        public List<String> getObjectTypesForParentRelationship(String objectName, String relationshipName) {
            ensureSingleObjectDescriberIsInitialised(objectName);
            return getObjectDescriber(objectName)?.getValidObjectsForParentRelationship(relationshipName);
        }

        public Boolean objectHasChildRelationshipNamed(String objectName, String relationshipName) {
            ensureSingleObjectDescriberIsInitialised(objectName);
            return getObjectDescriber(objectName)?.hasChildRelationshipNamed(relationshipName);
        }

        public String getObjectTypeForChildRelationship(String objectName, String relationshipName) {
            ensureSingleObjectDescriberIsInitialised(objectName);
            return getObjectDescriber(objectName)?.getValidObjectForChildRelationship(relationshipName);
        }

        // TODO: should this actually be in FabricatedObject?  At this point we are no longer describing the object!
        public sfab_FabricatedSObject buildFabricatedObjectForRelationship(String objectName, String relationshipName) {

            if (String.isEmpty(objectName)) {
                throw new ParentRelationshipDoesNotExistException('Cannot automatically create a Fabricated Object for the relationship because the object name has not been specified');
            }

            if (String.isEmpty(relationshipName)) {
                throw new ParentRelationshipDoesNotExistException('Cannot automatically create a Fabricated Object for the relationship because the relationship name has not been specified');
            }

            ensureSingleObjectDescriberIsInitialised(objectName);
            SingleObjectDescriber relationshipDescriber = getObjectDescriber(objectName);

            if (!relationshipDescriber.objectExists()) {
                throw new ParentRelationshipDoesNotExistException('Cannot automatically create a Fabricated Object for the relationship ' + objectName + '.' + relationshipName + ' because the object type does not exist');
            }
            if (!relationshipDescriber.hasParentRelationshipNamed(relationshipName)) {
                throw new ParentRelationshipDoesNotExistException('Cannot automatically create a Fabricated Object for the relationship ' + objectName + '.' + relationshipName + ' because the relationship does not exist');
            }

            return relationshipDescriber.buildFabricatedObjectForRelationship(relationshipName);
        }

        private void ensureSingleObjectDescriberIsInitialised(String objectName) {
            if (!singleObjectDescribers.containsKey(objectName)) {
                singleObjectDescribers.put(objectName, new SingleObjectDescriber(objectName));
            }
        }

        private SingleObjectDescriber getObjectDescriber(String objectName) {
            return singleObjectDescribers.get(objectName);
        }
    }

    public class sfab_ParentRelationshipNode implements sfab_FabricatedSObjectNode {
        @testVisible private String fieldName;
        @testVisible private sfab_FabricatedSObject parent;

        public sfab_ParentRelationshipNode(String fieldName, sfab_FabricatedSObject parent) {
            this.fieldName = fieldName;
            this.parent = parent;
        }

        public String getName() {
            return fieldName;
        }

        public sfab_FabricatedSObject getParent() {
            return parent;
        }

        public sfab_FabricatedSObject set(String fieldName, Object value) {
            return parent.set(fieldName, value);
        }

        public sfab_FabricatedSObject add(String fieldName, sfab_FabricatedSObject fabricatedChild) {
            return parent.add(fieldName, fabricatedChild);
        }

        public Map<String, Object> serialize() {
            return new Map<String, Object>{
                fieldName => parent.serialize()
            };
        }

        public void postBuildProcess(Object objectToProcess) {
            parent.postBuildProcess(((SObject) objectToProcess).getSObject(fieldName));
        }

    }

    /**
    * Internal class that interprets a field name and determines
    * if it represents a parent.child specification
    */
    class sfab_FieldNameSplitter {

        private String fullFieldName;

        public sfab_FieldNameSplitter(String fullFieldName) {
            this.fullFieldName = fullFieldName;
        }

        /**
        * Internal method that should not be called directly.
        * Returns the parent field component of the current field name
        */
        public String getParentFieldName() {
            return fullFieldName.substringBefore('.');
        }

        /**
        * Internal method that should not be called directly.
        * Returns the child field component of the current field name
        */
        public String getChildFieldName() {
            return fullFieldName.substringAfter('.');
        }

        /**
        * Internal method that should not be called directly.
        * States if the current field name represents a navigation to a parent field
        */
        public Boolean isAParentNavigation() {
            return fullFieldName.contains('.');
        }
    }

    public class SingleObjectDescriber {
        private String objectName;

        Boolean fieldsInitialised = false;

        private Schema.DescribeSObjectResult objectDescribe {
            get {
                if (objectDescribe == null) {
                    objectDescribe = Schema.getGlobalDescribe()
                        ?.get(objectName)
                        ?.getDescribe();
                }
                return objectDescribe;
            }
            set;
        }

        private Map<String, SObjectField> fields {
            get {
                if (!fieldsInitialised) {
                    fieldsInitialised = true;
                    fields = objectDescribe
                        ?.fields
                        ?.getMap();
                }
                return fields;
            }
            set;
        }

        private Map<String, ParentRelationship> parentRelationships {
            get {
                if (parentRelationships == null) {
                    parentRelationships = new Map<String, ParentRelationship>();

                    if (fields != null) {
                        for (SObjectField thisField : fields.values()) {
                            ParentRelationship relationship = new ParentRelationship()
                                .setChildObjectName(objectName)
                                .setFieldDescribe(thisField.getDescribe());
                            if (relationship.isValid()) {
                                parentRelationships.put(relationship.getName(), relationship);
                            }
                        }
                    }
                }
                return parentRelationships;
            }
            set;
        }

        private Map<String, ChildRelationship> childRelationships {
            get {
                if (childRelationships == null) {

                    List<Schema.ChildRelationship> schemaRelationships = objectDescribe?.getChildRelationships();
                    if (schemaRelationships == null) {
                        return new Map<String, ChildRelationship>();
                    }

                    childRelationships = new Map<String, ChildRelationship>();

                    for (Schema.ChildRelationship thisSchemaChildRelationship : schemaRelationships) {

                        ChildRelationship relationship = new ChildRelationship()
                            .setParentObjectName(objectName)
                            .setSchemaRelationship(thisSchemaChildRelationship);

                        if (relationship.isValid()) {
                            childRelationships.put(relationship.getName(), relationship);
                        }
                    }
                }
                return childRelationships;
            }
            set;
        }

        public SingleObjectDescriber(String objectName) {
            this.objectName = objectName;
        }

        public Boolean objectExists() {
            return fields != null;
        }

        public Boolean hasFieldNamed(String fieldName) {
            return objectExists() && fields.containsKey(fieldName);
        }

        public SObjectField getField(String fieldName) {
            if (!hasFieldNamed(fieldName)) {
                return null;
            }
            return fields.get(fieldName);
        }

        public Boolean hasSimpleFieldNamed(String fieldName) {
            return objectExists() && hasFieldNamed(fieldName) && !hasParentRelationshipNamed(fieldName) && !hasChildRelationshipNamed(fieldName);
        }

        public Boolean hasParentRelationshipNamed(String relationshipName) {
            return objectExists() && parentRelationships.containsKey(relationshipName);
        }

        public Boolean hasChildRelationshipNamed(String relationshipName) {
            return objectExists() && childRelationships.containsKey(relationshipName);
        }

        public List<String> getValidObjectsForParentRelationship(String relationshipName) {
            if (!hasParentRelationshipNamed(relationshipName)) {
                return new List<String>();
            }
            List<String> validObjects = getParentRelationshipNamed(relationshipName).getTargetObjectTypes();
            validObjects.sort();
            return validObjects;
        }

        public String getValidObjectForChildRelationship(String relationshipName) {
            if (!hasChildRelationshipNamed(relationshipName)) {
                return null;
            }
            return getChildRelationshipNamed(relationshipName)?.getChildObjectType();
        }

        public sfab_FabricatedSObject buildFabricatedObjectForRelationship(String relationshipName) {
            return getParentRelationshipNamed(relationshipName)?.buildFabricatedObject();
        }

        private ParentRelationship getParentRelationshipNamed(String relationshipName) {
            return parentRelationships.get(relationshipName);
        }

        private ChildRelationship getChildRelationshipNamed(String relationshipName) {
            return childRelationships.get(relationshipName);
        }
    }

    private class ParentRelationship {

        private String childObjectName;
        private Schema.DescribeFieldResult fieldDescribe;

        public ParentRelationship setFieldDescribe(Schema.DescribeFieldResult fieldDescribe) {
            this.fieldDescribe = fieldDescribe;
            return this;
        }

        public ParentRelationship setChildObjectName(String childObjectName) {
            this.childObjectName = childObjectName;
            return this;
        }

        public String getName() {
            return fieldDescribe.getRelationshipName();
        }

        public String getFullName() {
            return childObjectName + '.' + getName();
        }

        public List<String> getTargetObjectTypes() {

            if (!isValid()) {
                return new List<String>();
            }

            List<String> targetObjectTypes = new List<String>();
            for (Schema.SObjectType thisReferenceTo : fieldDescribe.getReferenceTo()) {
                targetObjectTypes.add(thisReferenceTo.getDescribe().getName());
            }
            return targetObjectTypes;
        }

        public sfab_FabricatedSObject buildFabricatedObject() {
            if (isPolymorphic()) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException('Cannot automatically create a Fabricated Object for the relationship ' + getFullName() + ' as it is polymorphic and so not possible to automatically ascertain which SObject to use');
            }
            return new sfab_FabricatedSObject(Type.forName(getTargetObjectTypes()[0]));
        }

        public Boolean isValid() {
            return fieldDescribe?.getReferenceTo()?.size() > 0;
        }

        private Boolean isPolymorphic() {
            return fieldDescribe.getReferenceTo().size() > 1;
        }
    }

    private class ChildRelationship {
        private Schema.ChildRelationship schemaRelationship;
        private String parentObjectName;

        public ChildRelationship setSchemaRelationship(Schema.ChildRelationship schemaRelationship) {
            this.schemaRelationship = schemaRelationship;
            return this;
        }

        public ChildRelationship setParentObjectName(String parentObjectName) {
            this.parentObjectName = parentObjectName;
            return this;
        }

        public String getName() {
            return schemaRelationship.getRelationshipName();
        }

        public String getChildObjectType() {
            return String.valueOf(schemaRelationship.getChildSObject());
        }

        // Some don't have names - and if they don't have names they can't possibly be
        // set by the fabricator, so must be invalid.
        public Boolean isValid() {
            return getName() != null;
        }
    }
}
