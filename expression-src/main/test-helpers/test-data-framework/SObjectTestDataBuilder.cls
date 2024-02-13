/**
 * @description Provides base functionality for building SObject records for testing purposes. Any custom TestDataBuilder
 *              must extend this class as well as implement {@link ITestDataBuilder}.
 */
public abstract class SObjectTestDataBuilder implements ITestDataCallback {
    private static final TestDataBuilderCache builderCache = new TestDataBuilderCache();
    private static final History testDataHistory = new History();
    private static final List<LateBinding> allBindings = new List<LateBinding>();

    private List<ChildRelationship> registeredRelationships;
    protected Map<SObjectField, Object> customValueMap;
    private final Map<SObjectField, Object> defaultValueMapCached {
        get {
            if (defaultValueMapCached == null) {
                defaultValueMapCached = getDefaultValueMap();
            }
            return defaultValueMapCached;
        }
        set;
    }

    /**
     * @description Constructs a new SObjectTestDataBuilder.
     */
    public SObjectTestDataBuilder() {
        customValueMap = new Map<SObjectField, Object>();
        registeredRelationships = new List<ChildRelationship>();
    }

    /**
     * @description Factory method that creates a new {@link ITestDataBuilder} for the provided SObjectType.
     * @param objectType The SObjectType for which to create a {@link ITestDataBuilder} for.
     * @return New {@link ITestDataBuilder} instance.
     */
    public static ITestDataBuilder of(SObjectType objectType) {
        return builderCache.getFor(objectType) ?? new DefaultTestDataBuilder(objectType);
    }

    /**
     * @description Registers a custom TestDataBuilder for a specific SObjectType. The Type must be a class
     *              that both extends SObjectTestDataBuilder and implements {@link ITestDataBuilder}.
     *
     *              Use this method to force the usage of your provided TestDataBuilder instead of letting the
     *              `of` method automatically find a test data builder for it to use.
     * @param objectType The SObjectType for the builder.
     * @param builderType A class that both extends SObjectTestDataBuilder and implements {@link ITestDataBuilder}.
     */
    public static void registerBuilder(SObjectType objectType, Type builderType) {
        builderCache.register(objectType, builderType);
    }

    /**
     * @description Gets a record for the provided SObjectType. If a record has previously been created
     *              for the provided SObjectType then it will be used, saving a trip to the database, otherwise
     *              a new one will be created and the database will be called.
     * @param objectType The SObjectType to get a record for.
     * @return The SObject for the provided type.
     */
    public static SObject getAny(SObjectType objectType) {
        SObject previouslyInserted = testDataHistory.getA(objectType);
        if (previouslyInserted != null) {
            return previouslyInserted;
        }
        return of(objectType).registerNewForInsert();
    }

    /**
     * @description Returns any children record that might have been created through a `withChild` call
     *              for the specified record Id.
     * @param recordId The Id of the parent record.
     * @param objectType The SObjectType for the children.
     * @return A list with the children records.
     */
    public static List<SObject> getChildrenOfTypeById(Id recordId, SObjectType objectType) {
        return testDataHistory.getChildrenOfByType(recordId, objectType);
    }

    /**
     * @description Commits all registered records to the database.
     */
    public static void commitRecords() {
        List<LateBinding> allLateBindings = new List<LateBinding>();
        // Using this technique because throughout this process the allBindings list could be modified
        // if more parents need to be added up the chain when registerNewForInsert gets called.
        while (allBindings.size() > 0) {
            LateBinding binding = allBindings.remove(0);
            allLateBindings.add(binding);
            SObject parentRecord = binding.builder.registerNewForInsert();
            binding.setCreatedParent(parentRecord);
        }

        if (testDataHistory.isEmpty()) {
            return;
        }

        List<SObjectType> workTypes = getSObjectTypesToRegisterToUnitOfWorkInOrder(allLateBindings);
        TestDataUnitOfWork uOW = new TestDataUnitOfWork(workTypes,
            TestDataUnitOfWork.UnresolvedRelationshipBehavior.AttemptResolveOutOfOrder
        );

        for (HistoryItem item : testDataHistory.getAllNotInserted()) {
            uOW.registerNew(item.getRecord(), item.callback);
        }

        for (LateBinding binding : allLateBindings) {
            uOW.registerRelationship(binding.childRecord, binding.relationshipField, binding.parentRecord);
        }

        for (HistoryItem item : testDataHistory.getAllChildren()) {
            // If any of the records to insert have a relationship we register that as well
            uOW.registerRelationship(item.getRecord(), item.getRelationshipField(), item.getParentRecord());
        }
        uOW.commitWork();
    }

    /**
     * @description Returns a new LateBinding instance of the specified SObjectType.
     * @param objectType The SObjectType for the LateBinding instance.
     * @return New LateBinding instance.
     */
    public static LateBinding lateBinding(SObjectType objectType) {
        return new LateBinding(objectType);
    }

    /**
     * @description Returns the SObjectType for this builder.
     * @return The SObjectType for this builder.
     */
    public abstract SObjectType getSObjectType();

    private static List<SObjectType> getSObjectTypesToRegisterToUnitOfWorkInOrder(List<LateBinding> allLateBindingsTemp) {
        List<SObjectType> workTypes = new List<SObjectType>();
        for (Integer i = allLateBindingsTemp.size() - 1; i >= 0; i--) {
            // Using the reverse order of the parents, as the last records are the top-most parents
            SObjectType currentType = allLateBindingsTemp[i].parentRecord.getSObjectType();
            if (!workTypes.contains(currentType)) {
                workTypes.add(currentType);
            }
        }

        // Registering anything else that might not have been including through bindings (simpler relationships)
        for (SObjectType loggedType : testDataHistory.getSObjectTypes()) {
            if (!workTypes.contains(loggedType)) {
                workTypes.add(loggedType);
            }
        }
        return workTypes;
    }

    protected SObjectTestDataBuilder withChildData(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        this.registeredRelationships.add(new ChildRelationship(childBuilder, relationshipField));
        return this;
    }

    /**
     * @description Override this method if you want any logic to be executed before inserting the SObject
     *              for this builder into the database.
     * @param record The SObject that will be inserted into the database.
     */
    public virtual void beforeInsert(SObject record) {}

    /**
     * @description Override this method if you want any logic to be executed after inserting the SObject
     *              for this builder into the database.
     * @param record The SObject that will be inserted into the database.
     */
    public virtual void afterInsert(SObject record) {}

    protected LateBinding bindTo(ITestDataBuilder builder) {
        return new LateBinding(builder);
    }

    protected SObjectTestDataBuilder withData(SObjectField field, Object value) {
        this.customValueMap.put(field, value);
        return this;
    }

    protected virtual Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object>();
    }

    protected SObject registerSObjectForInsert() {
        return this.registerSObjectsForInsert(1)[0];
    }

    protected List<SObject> registerSObjectsForInsert(Integer numberOfRecordsToInsert) {
        return this.registerSObjects(numberOfRecordsToInsert, null, null);
    }

    protected List<SObject> registerSObjects(Integer numberOfRecordsToInsert, SObjectField parentRelationship, SObject relatedTo) {
        List<SObject> recordsToRegister = createNew(numberOfRecordsToInsert);
        testDataHistory.log(recordsToRegister, relatedTo, parentRelationship, this);
        registerChildren(recordsToRegister);
        lateBind(recordsToRegister);
        clear();
        return recordsToRegister;
    }

    private void lateBind(List<SObject> registeredRecords) {
        for (SObject currentRecord : registeredRecords) {
            for (SObjectField defaultField : defaultValueMapCached.keySet()) {
                if (!customValueMap.containsKey(defaultField)) {
                    // Skip any field that has been overridden through the custom value map
                    Object fieldValue = defaultValueMapCached.get(defaultField);
                    if (checkIfBinding(fieldValue)) {
                        attemptAddBinding((LateBinding)fieldValue, currentRecord, defaultField, false);
                    }
                }
            }

            for (SObjectField customField : customValueMap.keySet()) {
                if (customValueMap.get(customField) != null) {
                    Object fieldValue = customValueMap.get(customField);
                    if (checkIfBinding(fieldValue)) {
                        attemptAddBinding((LateBinding)fieldValue, currentRecord, customField, true);
                    }
                }
            }
        }
    }

    private static void attemptAddBinding(LateBinding binding, SObject record, SObjectField relationshipField, Boolean throwErrorIfRegistered) {
        for (HistoryItem item : testDataHistory.getAllNotInserted()) {
            // If the record is already logged with a parent relationship to the same field, then we do not
            // want to bind it.
            // This can happen if the record was logged as part of a withChild call for its parent
            if (item.getRecord() == record && item.getRelationshipField() == relationshipField) {
                if (throwErrorIfRegistered) {
                    String errorMessage = 'The record {0} is already registered to a parent through the field {1}. ' +
                        'make sure to avoid registering a parent to a record that is being created through withChild for the same field';
                    throw new SObjectTestDataBuilderException(String.format(errorMessage, new List<String> {
                        String.valueOf(record),
                        relationshipField.getDescribe().getName()
                    }));
                }
                return;
            }
        }

        binding.setRelationshipField(relationshipField);
        binding.setChildRecord(record);
        allBindings.add(binding);
    }

    private List<SObject> createNew(Integer numberOfRecords) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            SObject recordToInsert = build();
            recordsToInsert.add(recordToInsert);
        }
        return recordsToInsert;
    }

    private SObject build() {
        SObject instance = this.getSObjectType().newSObject(null, true);

        for (SObjectField defaultField : defaultValueMapCached.keySet()) {
            if (!customValueMap.containsKey(defaultField)) {
                // Skip any field that has been overridden through the custom value map
                Object fieldValue = defaultValueMapCached.get(defaultField);
                if (checkIfBinding(fieldValue)) {
                    continue;
                }
                instance.put(defaultField, fieldValue);
            }
        }

        for (SObjectField customField : customValueMap.keySet()) {
            if (customValueMap.get(customField) != null) {
                Object fieldValue = customValueMap.get(customField);
                if (checkIfBinding(fieldValue)) {
                    continue;
                }
                instance.put(customField, fieldValue);
            }
        }

        return instance;
    }

    private static Boolean checkIfBinding(Object fieldValue) {
        if (fieldValue instanceof LateBinding) {
            return true;
        }
        return false;
    }

    private void registerChildren(List<SObject> records) {
        for (SObject currentRecord : records) {
            for (ChildRelationship relationship : this.registeredRelationships) {
                SObjectTestDataBuilder relationshipAsTestData = (SObjectTestDataBuilder)relationship.ChildBuilder;
                relationshipAsTestData.registerSObjects(1, relationship.RelationshipField, currentRecord);
            }
        }
    }

    private void clear() {
        customValueMap = new Map<SObjectField, Object>();
        registeredRelationships = new List<ChildRelationship>();
    }

    private class TestDataBuilderCache {
        private Boolean initialized;
        private final Map<SObjectType, Type> builderTypeBySObjectType;

        public TestDataBuilderCache() {
            this.initialized = false;
            this.builderTypeBySObjectType = new Map<SObjectType, Type>();
        }

        public void register(SObjectType objectType, Type classType) {
            if (builderTypeBySObjectType.keySet().contains(objectType)) {
                // If already registered, skip.
                return;
            }
            this.builderTypeBySObjectType.put(objectType, classType);
        }

        public ITestDataBuilder getFor(SObjectType objectType) {
            if (this.initialized == false) {
                initializeCache();
            }

            Type builderType = this.builderTypeBySObjectType.get(objectType);
            if (builderType == null) {
                return null;
            }
            return (ITestDataBuilder)builderType.newInstance();
        }

        private void initializeCache() {
            List<ApexClass> testDataBuilderClass = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name LIKE '%TestDataBuilder%'];
            for (ApexClass currentClass : testDataBuilderClass) {
                try {
                    Type currentClassType = Type.forName(currentClass.NamespacePrefix, currentClass.Name);
                    Object currentClassInstance = currentClassType.newInstance();
                    if (currentClassInstance instanceof ITestDataBuilder && currentClassInstance instanceof SObjectTestDataBuilder) {
                        ITestDataBuilder builderInstance = (ITestDataBuilder)currentClassInstance;
                        this.register(builderInstance.getSObjectType(), currentClassType);
                    }
                } catch (Exception e) {
                    // An error might occur when creating the type. If it does we move on and don't add it to the cache.
                }
            }

            this.initialized = true;
        }
    }

    public class LateBinding {
        private final ITestDataBuilder builder;
        private SObjectField relationshipField;
        private SObject childRecord;
        private SObject parentRecord;

        public LateBinding(ITestDataBuilder builder) {
            this.builder = builder;
        }

        public LateBinding(SObjectType objectType) {
            this.builder = SObjectTestDataBuilder.of(objectType);
        }

        public LateBinding setRelationshipField(SObjectField field) {
            this.relationshipField = field;
            return this;
        }

        private void setChildRecord(SObject childRecord) {
            this.childRecord = childRecord;
        }

        private void setCreatedParent(SObject parentRecord) {
            this.parentRecord = parentRecord;
        }
    }

    private class ChildRelationship {
        public ITestDataBuilder ChildBuilder { get; private set; }
        public SObjectField RelationshipField { get; private set; }

        public ChildRelationship(ITestDataBuilder childBuilder, SObjectField relationshipField) {
            this.ChildBuilder = childBuilder;
            this.RelationshipField = relationshipField;
        }
    }

    private class History {
        final Map<SObjectType, List<HistoryItem>> recordsByType;

        public History() {
            this.recordsByType = new Map<SObjectType, List<HistoryItem>>();
        }

        public void log(List<SObject> insertedRecords, SObject parentRecord, SObjectField relationshipField,
            ITestDataCallback callback) {
            for (SObject insertedRecord : insertedRecords) {
                HistoryItem item = new HistoryItem(insertedRecord, parentRecord, relationshipField, callback);
                log(item);
            }
        }

        public SObject getA(SObjectType objectType) {
            List<HistoryItem> historiesForType = recordsByType.get(objectType);
            if (historiesForType != null) {
                return historiesForType[0].getRecord();
            }
            return null;
        }

        public Set<SObjectType> getSObjectTypes() {
            return this.recordsByType.keySet();
        }

        public Boolean isEmpty() {
            return this.getAll().isEmpty();
        }

        public List<HistoryItem> getAll() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (List<HistoryItem> currentItems : this.recordsByType.values()) {
                items.addAll(currentItems);
            }
            return items;
        }

        public List<HistoryItem> getAllNotInserted() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (List<HistoryItem> currentItems : this.recordsByType.values()) {
                for (HistoryItem currentItem : currentItems) {
                    if (!currentItem.hasRecordBeingInserted()) {
                        items.add(currentItem);
                    }
                }
            }
            return items;
        }

        public List<HistoryItem> getAllChildren() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (HistoryItem item : this.getAll()) {
                if (!item.isParent()) {
                    items.add(item);
                }
            }
            return items;
        }

        public List<SObject> getChildrenOfByType(Id recordId, SObjectType objectType) {
            List<SObject> children = new List<SObject>();
            List<HistoryItem> itemsByType = this.recordsByType.get(objectType);
            if (itemsByType == null) {
                // If no record of that type has been logged then there are no children.
                return children;
            }
            for (HistoryItem item : itemsByType) {
                if (item.getParentRecord()?.Id == recordId) {
                    children.add(item.getRecord());
                }
            }
            return children;
        }

        private void log(HistoryItem item) {
            List<HistoryItem> historiesByType = recordsByType.get(item.getRecord().getSObjectType()) ?? new List<HistoryItem>();
            historiesByType.add(item);
            recordsByType.put(item.getRecord().getSObjectType(), historiesByType);
        }
    }

    private class HistoryItem {
        private final SObject record;
        private final SObject parentRecord;
        private final SObjectField relationshipToParent;
        private final ITestDataCallback callback;

        public HistoryItem(SObject record, SObject parentRecord, SObjectField relationshipField,
            ITestDataCallback callback) {
            this.record = record;
            this.parentRecord = parentRecord;
            this.relationshipToParent = relationshipField;
            this.callback = callback;
        }

        public SObject getRecord() {
            return this.record;
        }

        public SObject getParentRecord() {
            return this.parentRecord;
        }

        public SObjectField getRelationshipField() {
            return this.relationshipToParent;
        }

        public Boolean isParent() {
            return this.parentRecord == null;
        }

        public Boolean hasRecordBeingInserted() {
            return this.record.Id != null;
        }
    }

    public class SObjectTestDataBuilderException extends Exception {}
}
