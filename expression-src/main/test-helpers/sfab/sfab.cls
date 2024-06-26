public with sharing class sfab {
    public virtual class FabricatedSObject {
        private final Type sType;
        @TestVisible private Map<String, FabricatedSObjectNode> nodes = new Map<String, FabricatedSObjectNode>();

        final ObjectDescriber objectDescriber = new ObjectDescriber();

        public FabricatedSObject(Type sType) {
            this.sType = sType;
        }

        public FabricatedSObject(Type sType, Map<Schema.SObjectField, Object> fields) {
            this(sType);
            set(fields);
        }

        public FabricatedSObject(Type sType, Map<String, Object> fields) {
            this(sType);
            set(fields);
        }

        public FabricatedSObject shallowClone() {
            // Clones all populated fields except the child relationhips
            List<FabricatedSObjectNode> nodes = new List<FabricatedSObjectNode>();
            for (FabricatedSObjectNode node : this.nodes.values()) {
                if (!(node instanceof ChildRelationshipNode)) {
                    nodes.add(node);
                }
            }
            return new FabricatedSObject(sType, nodes);
        }

        @TestVisible
        protected FabricatedSObject(Type sType, List<FabricatedSObjectNode> nodes) {
            this.sType = sType;
            this.nodes = new Map<String, FabricatedSObjectNode>();
            for (FabricatedSObjectNode node : nodes) {
                setNode(node.getName(), node);
            }
        }

        public FabricatedSObject set(Schema.SObjectField field, Object value) {
            return setField(field, value);
        }

        public FabricatedSObject set(String fieldName, Object value) {
            // This looks like it duplicates the overloading of 'set', but unfortunately Apex determines the method to call
            // based on the static type of a parameter rather than the dynamic type.
            // I.E. if a passed parameter's value is declared as 'Object' it will always call the 'Object'
            // defined version of an overloaded method even when a more specific type matches for a given value.
            // This means that 'setParentField' will always call this version of the overloaded method regardless
            // of the contents of the value parameter.  So we need to manually check the instance type in the code.
            if (value instanceof List<FabricatedSObject>) {
                return setChildren(fieldName, (List<FabricatedSObject>) value);
            }

            if (value instanceof FabricatedSObject) {
                return setParent(fieldName, (FabricatedSObject) value);
            }

            return setField(fieldName, value);
        }

        public FabricatedSObject set(String relationshipName, FabricatedSObject fabricatedParent) {
            return setParent(relationshipName, fabricatedParent);
        }

        public FabricatedSObject add(String relationshipName, FabricatedSObject fabricatedChild) {
            return addChild(relationshipName, fabricatedChild);
        }

        public FabricatedSObject set(Map<Schema.SObjectField, Object> fields) {
            for (Schema.SObjectField field : fields.keySet()) {
                setField(field, fields.get(field));
            }
            return this;
        }

        public FabricatedSObject set(Map<String, Object> fields) {
            for (String fieldName : fields.keySet()) {
                set(fieldName, fields.get(fieldName));
            }
            return this;
        }

        public FabricatedSObject setField(Schema.SObjectField field, Object value) {
            return setDirectField(field.getDescribe().getName(), value);
        }

        public FabricatedSObject setField(String fieldName, Object value) {
            if (new FieldNameSplitter(fieldName).isAParentNavigation()) {
                return setParentField(fieldName, value);
            }
            return setDirectField(fieldName, value);
        }

        public FabricatedSObject setParent(String relationshipName, FabricatedSObject fabricatedParent) {
            if (new FieldNameSplitter(relationshipName).isAParentNavigation()) {
                return setParentField(relationshipName, fabricatedParent);
            }
            return setDirectParent(relationshipName, fabricatedParent);
        }

        public FabricatedSObject setChildren(String relationshipName, List<FabricatedSObject> fabricatedChildren) {
            if (new FieldNameSplitter(relationshipName).isAParentNavigation()) {
                return setParentField(relationshipName, fabricatedChildren);
            }
            return setDirectChildren(relationshipName, fabricatedChildren);
        }

        public FabricatedSObject addChild(String relationshipName, FabricatedSObject fabricatedChild) {

            if (new FieldNameSplitter(relationshipName).isAParentNavigation()) {
                addParentChild(relationshipName, fabricatedChild);
            } else {
                childFieldIsChildRelationship(relationshipName);
                checkTypeIsValidForChildRelationship(relationshipName, fabricatedChild);
                if (!nodeExists(relationshipName)) {
                    setNode(relationshipName, new ChildRelationshipNode(relationshipName));
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
            for (FabricatedSObjectNode node : nodes.values()) {
                fields.putAll(node.serialize());
            }
            return fields;
        }

        public String getSobjectName() {
            return String.valueOf(sType);
        }

        private FieldNameSplitter defaultParentField(String fieldName) {

            FieldNameSplitter fieldNameSplitter = new FieldNameSplitter(fieldName);
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

        private FabricatedSObject setDirectField(String fieldName, Object value) {

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

            return setNode(fieldName, new FieldValuePairNode(theField, value));
        }

        private FabricatedSObject setDirectParent(String relationshipName, FabricatedSObject fabricatedParent) {
            checkFieldIsParentRelationship(relationshipName);
            checkTypeIsValidForParentRelationship(relationshipName, fabricatedParent);
            return setNode(relationshipName, new ParentRelationshipNode(relationshipName, fabricatedParent));
        }

        private FabricatedSObject setDirectChildren(String relationshipName, List<FabricatedSObject> fabricatedChildren) {
            childFieldIsChildRelationship(relationshipName);
            checkTypeIsValidForChildRelationship(relationshipName, fabricatedChildren);
            return setNode(relationshipName, new ChildRelationshipNode(relationshipName, fabricatedChildren));
        }

        private FabricatedSObject setParentField(String fieldName, Object value) {
            FieldNameSplitter fields = defaultParentField(fieldName);
            getParentRelationshipNode(fields.getParentFieldName()).set(fields.getChildFieldName(), value);
            return this;
        }

        private FabricatedSObject addParentChild(String fieldName, FabricatedSObject fabricatedChild) {
            FieldNameSplitter fields = defaultParentField(fieldName);
            getParentRelationshipNode(fields.getParentFieldName()).add(fields.getChildFieldName(), fabricatedChild);
            return this;
        }

        private Boolean nodeExists(String nodeName) {
            return nodes.containsKey(nodeName);
        }

        private FabricatedSObject setNode(String nodeName, FabricatedSObjectNode node) {
            nodes.put(nodeName, node);
            return this;
        }

        private FabricatedSObjectNode getNode(String nodeName) {
            if (!nodeExists(nodeName)) {
                throw new NodeNotSetException('Attempt to get the value of node "' + nodeName + '" when it was not set');
            }
            return nodes.get(nodeName);
        }

        private ParentRelationshipNode getParentRelationshipNode(String relationshipName) {
            return ((ParentRelationshipNode) getNode(relationshipName));
        }

        private ChildRelationshipNode getChildRelationshipNode(String relationshipName) {
            return ((ChildRelationshipNode) getNode(relationshipName));
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

        private void checkTypeIsValidForParentRelationship(String relationshipName, FabricatedSObject fabricatedParent) {
            List<String> validObjectTypes = objectDescriber.getObjectTypesForParentRelationship(getSobjectName(), relationshipName);
            if (!validObjectTypes.contains(fabricatedParent.getSobjectName())) {
                throw new FieldIsADifferentTypeException('The field ' + getSobjectName() + '.' + relationshipName + ' is ' + String.join(validObjectTypes, ',') + ', not ' + fabricatedParent.getSobjectName());
            }
        }

        private void checkTypeIsValidForChildRelationship(String relationshipName, FabricatedSObject fabricatedChild) {
            String validObjectType = objectDescriber.getObjectTypeForChildRelationship(getSobjectName(), relationshipName);
            if (validObjectType != fabricatedChild.getSobjectName()) {
                throw new FieldIsADifferentTypeException('The relationship ' + getSobjectName() + '.' + relationshipName + ' is ' + validObjectType + ', not ' + fabricatedChild.getSobjectName());
            }
        }

        private void checkTypeIsValidForChildRelationship(String relationshipName, List<FabricatedSObject> fabricatedChildren) {
            for (FabricatedSObject thisChild : fabricatedChildren) {
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

    public class ChildRelationshipNode implements FabricatedSObjectNode {
        @TestVisible private String fieldName;
        @TestVisible private List<FabricatedSObject> children;

        public ChildRelationshipNode(String fieldName) {
            this.fieldName = fieldName;
            this.children = new List<FabricatedSObject>();
        }

        public ChildRelationshipNode(String fieldName, List<FabricatedSObject> children) {
            this.fieldName = fieldName;
            this.children = children;
        }

        public ChildRelationshipNode addChild(FabricatedSObject child) {
            this.children.add(child);
            return this;
        }

        public String getName() {
            return fieldName;
        }

        public Map<String, Object> serialize() {
            List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();

            for (FabricatedSObject child : children) {
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

    public interface FabricatedSObjectNode {
        Map<String, Object> serialize();
        void postBuildProcess(Object objectToProcess);
        String getName();
    }

    public class FabricatedSObjectNodeStub implements FabricatedSObjectNode {
        public Boolean serializeInvoked = false;
        public Map<String, Object> serializedNode;
        private final String name;

        public FabricatedSObjectNodeStub(String name) {
            serializedNode = new Map<String, Object>();
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public FabricatedSObjectNodeStub(Map<String, Object> serializedNode) {
            this.serializedNode = serializedNode;
        }

        public Map<String, Object> serialize() {
            serializeInvoked = true;
            return serializedNode;
        }

        public void postBuildProcess(Object objectToProcess) {
        }
    }

    public class FabricatedSObjectStub extends FabricatedSObject {
        private final Map<String, Object> serializedMap;
        @TestVisible private Boolean serializeInvoked = false;

        public FabricatedSObjectStub(Type sType) {
            super(sType);
            this.serializedMap = new Map<String, Object>();
        }

        public FabricatedSObjectStub(Type sType, Map<String, Object> serializedMap) {
            super(sType);
            this.serializedMap = serializedMap;
        }

        public override Map<String, Object> serialize() {
            serializeInvoked = true;
            return serializedMap;
        }
    }

    public class FieldValuePairNode implements FabricatedSObjectNode {
        @TestVisible protected Schema.SObjectField field;
        @TestVisible protected Object value;

        public FieldValuePairNode(Schema.SObjectField field, Object value) {
            this.field = field;
            this.value = value;
        }

        public String getName() {
            return field?.getDescribe().getName();
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
                if (value instanceof Blob) {
                    valueToSet = (Blob) value;
                } else if (value instanceof String) {
                    valueToSet = Blob.valueOf((String) value);
                }
                ((SObject) objectToProcess).put(field, valueToSet);
            }
        }

        private Boolean fieldIsBlob() {
            return field.getDescribe().getType() == Schema.DisplayType.BASE64;
        }
    }

    static final Map<String, SingleObjectDescriber> singleObjectDescribers = new Map<String, SingleObjectDescriber>();

    public with sharing class ObjectDescriber {
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
        public FabricatedSObject buildFabricatedObjectForRelationship(String objectName, String relationshipName) {

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

    public class ParentRelationshipNode implements FabricatedSObjectNode {
        @TestVisible private String fieldName;
        @TestVisible private FabricatedSObject parent;

        public ParentRelationshipNode(String fieldName, FabricatedSObject parent) {
            this.fieldName = fieldName;
            this.parent = parent;
        }

        public String getName() {
            return fieldName;
        }

        public FabricatedSObject set(String fieldName, Object value) {
            return parent.set(fieldName, value);
        }

        public FabricatedSObject add(String fieldName, FabricatedSObject fabricatedChild) {
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

    private class FieldNameSplitter {
        private final String fullFieldName;

        public FieldNameSplitter(String fullFieldName) {
            this.fullFieldName = fullFieldName;
        }

        public String getParentFieldName() {
            return fullFieldName.substringBefore('.');
        }

        public String getChildFieldName() {
            return fullFieldName.substringAfter('.');
        }

        public Boolean isAParentNavigation() {
            return fullFieldName.contains('.');
        }
    }

    public class SingleObjectDescriber {
        private final String objectName;

        Boolean fieldsInitialised = false;

        private final Schema.DescribeSObjectResult objectDescribe {
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

        private final Map<String, ParentRelationship> parentRelationships {
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

        private final Map<String, ChildRelationship> childRelationships {
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

        public FabricatedSObject buildFabricatedObjectForRelationship(String relationshipName) {
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

        public FabricatedSObject buildFabricatedObject() {
            if (isPolymorphic()) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException('Cannot automatically create a Fabricated Object for the relationship ' + getFullName() + ' as it is polymorphic and so not possible to automatically ascertain which SObject to use');
            }
            return new FabricatedSObject(Type.forName(getTargetObjectTypes()[0]));
        }

        public Boolean isValid() {
            Integer size = fieldDescribe?.getReferenceTo()?.size();
            return size != null && size > 0;
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

    public class FieldDoesNotExistException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}
    public class ChildRelationshipDoesNotExistException extends Exception {}
    public class FieldIsNotSimpleFieldException extends Exception {}
    public class FieldIsNotParentRelationshipException extends Exception {}
    public class FieldIsNotChildRelationshipException extends Exception {}
    public class FieldIsADifferentTypeException extends Exception {}
    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}
    public class NodeNotSetException extends Exception {}
}
