/*
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * @description Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   http://martinfowler.com/eaaCatalog/unitOfWork.html
 *
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise,
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and
 *  remove any objects you delete."
 *
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls,
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 *
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done,
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 *
 * In an Apex context this pattern provides the following specific benefits
 * - Applies bulkfication to DML operations, insert, update and delete
 * - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 * - Honours dependency rules between records and updates dependent relationships automatically during the commit
 **/
@IsTest
public class TestDataUnitOfWork {
    /**
     * @description Unit of work has two ways of resolving registered relationships that require an update to resolve (e.g. parent
     * and child are same sobject type, or the parent is inserted after the child):
     *
     * AttemptResolveOutOfOrder - Update child to set the relationship (e.g. insert parent, insert child, update child)
     * IgnoreOutOfOrder (default behaviour) - Do not set the relationship (e.g. leave lookup null)
     */
    public enum UnresolvedRelationshipBehavior {
        AttemptResolveOutOfOrder, IgnoreOutOfOrder
    }

    private static final UnresolvedRelationshipBehavior DEFAULT_UNRESOLVED_RELATIONSHIP_BEHAVIOR =
        UnresolvedRelationshipBehavior.IgnoreOutOfOrder;

    protected List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();
    protected Map<String, List<NewSObjectAndCallback>> m_newListByType = new Map<String, List<NewSObjectAndCallback>>();
    protected Map<String, Map<Id, SObject>> m_dirtyMapByType = new Map<String, Map<Id, SObject>>();
    protected Map<String, Relationships> m_relationships = new Map<String, Relationships>();

    private class NewSObjectAndCallback {
        public SObject Record { get; private set; }
        public ITestDataCallback Callback { get; set; }

        public NewSObjectAndCallback(SObject record, ITestDataCallback callback) {
            this.Record = record;
            this.Callback = callback;
        }
    }

    protected IDML m_dml;

    protected final UnresolvedRelationshipBehavior m_unresolvedRelationshipBehaviour;

    public interface IDML {
        void dmlInsert(List<SObject> objList);
        void dmlUpdate(List<SObject> objList);
    }

    public virtual class SimpleDML implements IDML {
        public virtual void dmlInsert(List<SObject> objList) {
            insert objList;
        }
        public virtual void dmlUpdate(List<SObject> objList) {
            update objList;
        }
    }

    /**
     * @description Constructs a new UnitOfWork to support work against the given object list
     * @param sObjectTypes A list of objects given in dependency order (least dependent first)
     */
    public TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes) {
        this(sObjectTypes, new SimpleDML());
    }

    /**
     * @description Constructs a new UnitOfWork to support work against the given object list
     * @param sObjectTypes A list of objects given in dependency order (least dependent first)
     * @param unresolvedRelationshipBehavior If AttemptOutOfOrderRelationships and a relationship is registered
     *                                       where a parent is inserted after a child then will update the child
     *                                       post-insert to set the relationship. If IgnoreOutOfOrder then
     *                                       relationship will not be set.
     */
    public TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes,
        UnresolvedRelationshipBehavior unresolvedRelationshipBehavior) {
        this(sObjectTypes, new SimpleDML(), unresolvedRelationshipBehavior);
    }

    /**
     * @description Constructs a new UnitOfWork to support work against the given object list
     * @param sObjectTypes A list of objects given in dependency order (least dependent first)
     * @param dml Modify the database via this class
     */
    public TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml) {
        this(sObjectTypes, dml, DEFAULT_UNRESOLVED_RELATIONSHIP_BEHAVIOR);
    }

    /**
     * @description Constructs a new UnitOfWork to support work against the given object list
     * @param sObjectTypes A list of objects given in dependency order (least dependent first)
     * @param dml Modify the database via this class
     * @param unresolvedRelationshipBehavior If AttemptOutOfOrderRelationships and a relationship is registered
     *                                       where a parent is inserted after a child then will update the child
     *                                       post-insert to set the relationship. If IgnoreOutOfOrder then relationship
     *                                       will not be set.
     */
    public TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml,
        UnresolvedRelationshipBehavior unresolvedRelationshipBehavior) {

        m_unresolvedRelationshipBehaviour = unresolvedRelationshipBehavior;
        m_sObjectTypes = sObjectTypes.clone();

        for (Schema.SObjectType sObjectType : m_sObjectTypes) {
            // register the type
            handleRegisterType(sObjectType);
        }

        m_relationships.put(Messaging.SingleEmailMessage.class.getName(),
            new Relationships(unresolvedRelationshipBehavior));

        m_dml = dml;
    }

    public virtual void onCommitWorkStarting() {
    }
    public virtual void onCommitWorkFinishing() {
    }

    /**
     * @description Registers the type to be used for DML operations
     * @param sObjectType - The type to register
     */
    private void handleRegisterType(Schema.SObjectType sObjectType) {
        String sObjectName = sObjectType.getDescribe().getName();

        // add type to dml operation tracking
        m_newListByType.put(sObjectName, new List<NewSObjectAndCallback>());
        m_dirtyMapByType.put(sObjectName, new Map<Id, SObject>());
        m_relationships.put(sObjectName, new Relationships(m_unresolvedRelationshipBehaviour));
    }

    /**
     * @description Register a newly created SObject instance to be inserted when commitWork is called
     * @param record A newly created SObject instance to be inserted during commitWork
     * @param callback TestDataCallback.ITestDataCallback to be called before and after record insert.
     **/
    public void registerNew(SObject record, ITestDataCallback callback) {
        if (record.Id != null) {
            throw new UnitOfWorkException('Only new records can be registered as new');
        }

        String sObjectType = record.getSObjectType().getDescribe().getName();

        assertForSupportedSObjectType(m_newListByType, sObjectType);

        m_newListByType.get(sObjectType).add(new NewSObjectAndCallback(record, callback));
    }

    /**
     * @description Register a relationship between two records that have yet to be inserted to the database. This information will be
     *  used during the commitWork phase to make the references only when related records have been inserted to the database.
     * @param record An existing or newly created record
     * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
     * @param relatedTo A SObject instance (yet to be committed to the database)
     */
    public void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo) {
        String sObjectType = record.getSObjectType().getDescribe().getName();

        assertForSupportedSObjectType(m_newListByType, sObjectType);

        m_relationships.get(sObjectType).add(record, relatedToField, relatedTo);
    }

    /**
     * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
     **/
    public void commitWork() {
        doCommitWork();
    }

    private void doCommitWork() {
        onCommitWorkStarting();
        insertDmlByType();
        onCommitWorkFinishing();
    }

    private void insertDmlByType() {
        for (Schema.SObjectType sObjectType : m_sObjectTypes) {
            m_relationships.get(sObjectType.getDescribe().getName()).resolve();
            List<SObject> recordsToInsert = new List<SObject>();
            for (NewSObjectAndCallback toInsert : m_newListByType.get(sObjectType.getDescribe().getName())) {
                recordsToInsert.add(toInsert.Record);
                toInsert.Callback.beforeInsert(toInsert.Record);
            }
            m_dml.dmlInsert(recordsToInsert);
            for (NewSObjectAndCallback toInsert : m_newListByType.get(sObjectType.getDescribe().getName())) {
                toInsert.Callback.afterInsert(toInsert.Record);
            }
        }

        // Resolve any unresolved relationships where parent was inserted after child, and so child lookup was not set
        if (m_unresolvedRelationshipBehaviour == UnresolvedRelationshipBehavior.AttemptResolveOutOfOrder) {
            for (Schema.SObjectType sObjectType : m_sObjectTypes) {
                Relationships relationships = m_relationships.get(sObjectType.getDescribe().getName());
                if (relationships.hasParentInsertedAfterChild()) {
                    List<SObject> childrenToUpdate = relationships.resolveParentInsertedAfterChild();
                    m_dml.dmlUpdate(childrenToUpdate);
                }
            }
        }
    }

    private static void assertForSupportedSObjectType(Map<String, Object> theMap, String sObjectType) {
        if (!theMap.containsKey(sObjectType)) {
            throw new UnitOfWorkException(
                String.format(
                    'SObject type {0} is not supported by this unit of work',
                    new List<String>{
                        sObjectType
                    }
                )
            );
        }
    }

    private class Relationships {
        private final List<IRelationship> m_relationships = new List<IRelationship>();
        private final List<RelationshipPermittingOutOfOrderInsert> m_parentInsertedAfterChildRelationships =
            new List<RelationshipPermittingOutOfOrderInsert>();
        private final UnresolvedRelationshipBehavior m_unresolvedRelationshipBehaviour;

        /**
         * @description Unit of work has two ways of resolving registered relationships that require an update to resolve (e.g.
         * parent and child are same sobject type, or the parent is inserted after the child):
         *
         * AttemptResolveOutOfOrder - Update child to set the relationship (e.g. insert parent, insert child, update
         *                              child)
         * IgnoreOutOfOrder (default behaviour) - Do not set the relationship (e.g. leave lookup null)
         * @param unresolvedRelationshipBehaviour The behaviour to use when encountering unresolved relationships
         */
        public Relationships(UnresolvedRelationshipBehavior unresolvedRelationshipBehaviour) {
            m_unresolvedRelationshipBehaviour = unresolvedRelationshipBehaviour;
        }

        public void resolve() {
            // Resolve relationships
            for (IRelationship relationship : m_relationships) {
                //relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
                relationship.resolve();

                // Check if parent is inserted after the child
                if (m_unresolvedRelationshipBehaviour == UnresolvedRelationshipBehavior.AttemptResolveOutOfOrder &&
                    !((RelationshipPermittingOutOfOrderInsert) relationship).Resolved) {
                    m_parentInsertedAfterChildRelationships.add((RelationshipPermittingOutOfOrderInsert) relationship);
                }
            }
        }

        /**
         * @description
         * @return true if there are unresolved relationships
         */
        public Boolean hasParentInsertedAfterChild() {
            return !m_parentInsertedAfterChildRelationships.isEmpty();
        }

        /**
         * @description Call this after all records in the UOW have been inserted to set the lookups on the children that were
         * inserted before the parent was inserted
         * @return The child records to update in order to set the lookups
         * @throws UnitOfWorkException if the parent still does not have an ID - can occur if parent is not registered
         */
        public List<SObject> resolveParentInsertedAfterChild() {
            for (RelationshipPermittingOutOfOrderInsert relationship : m_parentInsertedAfterChildRelationships) {
                relationship.resolve();
                if (!relationship.Resolved) {
                    throw new UnitOfWorkException('Error resolving relationship where parent is inserted after child.' +
                        ' The parent has not been inserted. Is it registered with a unit of work?');
                }
            }
            return getChildRecordsWithParentInsertedAfter();
        }

        /**
         * @description Call after calling resolveParentInsertedAfterChild()
         * @return The child records to update in order to set the lookups
         */
        private List<SObject> getChildRecordsWithParentInsertedAfter() {
            // Get rid of dupes
            Map<Id, SObject> recordsToUpdate = new Map<Id, SObject>();
            for (RelationshipPermittingOutOfOrderInsert relationship : m_parentInsertedAfterChildRelationships) {
                SObject childRecord = relationship.Record;
                SObject recordToUpdate = recordsToUpdate.get(childRecord.Id);
                if (recordToUpdate == null) {
                    recordToUpdate = childRecord.getSObjectType().newSObject(childRecord.Id);
                }
                recordToUpdate.put(relationship.RelatedToField, childRecord.get(relationship.RelatedToField));
                recordsToUpdate.put(recordToUpdate.Id, recordToUpdate);
            }
            return recordsToUpdate.values();
        }

        public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo) {
            // Relationship to resolve
            if (m_unresolvedRelationshipBehaviour == UnresolvedRelationshipBehavior.IgnoreOutOfOrder) {
                Relationship relationship = new Relationship();
                relationship.Record = record;
                relationship.RelatedToField = relatedToField;
                relationship.RelatedTo = relatedTo;
                m_relationships.add(relationship);
            } else {
                RelationshipPermittingOutOfOrderInsert relationship = new RelationshipPermittingOutOfOrderInsert();
                relationship.Record = record;
                relationship.RelatedToField = relatedToField;
                relationship.RelatedTo = relatedTo;
                m_relationships.add(relationship);
            }
        }
    }

    private interface IRelationship {
        void resolve();
    }

    private class Relationship implements IRelationship {
        public SObject Record;
        public Schema.SObjectField RelatedToField;
        public SObject RelatedTo;

        public void resolve() {
            this.Record.put(this.RelatedToField, this.RelatedTo.Id);
        }
    }

    /**
     * @description Similar to Relationship, but has a Resolved property that is set to false when relationship is not resolved
     * because RelatedTo does not have an ID and/or resolve() has not been called.
     */
    private class RelationshipPermittingOutOfOrderInsert implements IRelationship {
        public SObject Record;
        public Schema.SObjectField RelatedToField;
        public SObject RelatedTo;
        public Boolean Resolved = false;

        public void resolve() {
            if (RelatedTo.Id == null) {
                /*
                If relationship is between two records in same table then update is always required to set the lookup,
                so no warning is needed. Otherwise the caller may be able to be more efficient by reordering the order
                that the records are inserted, so alert the caller of this.
                */
                if (RelatedTo.getSObjectType() != Record.getSObjectType()) {
                    System.debug(System.LoggingLevel.WARN, 'Inefficient use of register relationship, related to ' +
                        'record should be first in dependency list to save an update; parent should be inserted ' +
                        'before child so child does not need an update. In unit of work initialization put ' +
                        '' + RelatedTo.getSObjectType() + ' before ' + Record.getSObjectType());
                }
                Resolved = false;
            } else {
                Record.put(RelatedToField, RelatedTo.Id);
                Resolved = true;
            }
        }
    }

    /**
     * @description UnitOfWork Exception
     **/
    public class UnitOfWorkException extends Exception {
    }
}
