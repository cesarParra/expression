@IsTest
private class sfabTest {
    @IsTest
    private static void serialize_expectSerializeInvokedOnChildren() {
        sfab.FabricatedSObjectStub child1 = new sfab.FabricatedSObjectStub(Account.class);
        sfab.FabricatedSObjectStub child2 = new sfab.FabricatedSObjectStub(Account.class);
        sfab.ChildRelationshipNode node = new sfab.ChildRelationshipNode('Accounts__r', new List<sfab.FabricatedSObject>{
            child1, child2
        });

        node.serialize();

        System.assert(child1.serializeInvoked);
        System.assert(child2.serializeInvoked);
    }

    @IsTest
    private static void serialize_expectDoneMapKey() {
        sfab.ChildRelationshipNode node = new sfab.ChildRelationshipNode('Accounts__r', new List<sfab.FabricatedSObject>());

        Map<String, Object> builtNode = node.serialize();

        System.assert(((Map<String, Object>) builtNode.get('Accounts__r')).containsKey('done'));
        System.assert((Boolean) ((Map<String, Object>) builtNode.get('Accounts__r')).get('done'));
    }

    @IsTest
    private static void serialize_expectTotalSizeMapKey() {
        sfab.ChildRelationshipNode node = new sfab.ChildRelationshipNode('Accounts__r', new List<sfab.FabricatedSObjectStub>{
            new sfab.FabricatedSObjectStub(Account.class),
            new sfab.FabricatedSObjectStub(Account.class)
        });

        Map<String, Object> builtNode = node.serialize();

        System.assert(((Map<String, Object>) builtNode.get('Accounts__r')).containsKey('totalSize'));
        System.assertEquals(2, ((Map<String, Object>) builtNode.get('Accounts__r')).get('totalSize'));
    }

    @IsTest
    private static void serialize_expectSerializedChildrenMap() {
        sfab.FabricatedSObjectStub child1 = new sfab.FabricatedSObjectStub(Account.class, new Map<String, Object>{
            'Name' => 'Foo-1'
        });
        sfab.FabricatedSObjectStub child2 = new sfab.FabricatedSObjectStub(Account.class, new Map<String, Object>{
            'Name' => 'Foo-2'
        });
        sfab.ChildRelationshipNode node = new sfab.ChildRelationshipNode('Accounts__r', new List<sfab.FabricatedSObject>{
            child1, child2
        });

        List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();
        serializedChildren.add(child1.serialize());
        serializedChildren.add(child2.serialize());

        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(serializedChildren, ((Map<String, Object>) builtNode.get('Accounts__r')).get('records'));
    }

    @IsTest
    private static void getName_expectTheName() {
        sfab.ChildRelationshipNode node = new sfab.ChildRelationshipNode('Accounts__r');
        System.assertEquals('Accounts__r', node.getName());
    }

    @IsTest
    private static void toSObject_expectSpecifiedSObjectType() {
        SObject sObj = new sfab.FabricatedSObject(Account.class).toSObject();
        System.assert(sObj instanceof Account);
    }

    @IsTest
    private static void toSObject_expectSerializeInvokedOnNodes() {
        sfab.FabricatedSObjectNodeStub node1 = new sfab.FabricatedSObjectNodeStub('node1');
        sfab.FabricatedSObjectNodeStub node2 = new sfab.FabricatedSObjectNodeStub('node2');
        SObject sObj = new sfab.FabricatedSObject(Account.class, new List<sfab.FabricatedSObjectNode>{
            node1, node2
        }).toSObject();
        System.assert(node1.serializeInvoked);
        System.assert(node2.serializeInvoked);
    }

    @IsTest
    private static void toSObject_expectProperties() {
        Map<String, Object> fields = new Map<String, Object>{
            'Id' => 'id-1', 'Name' => 'Foo'
        };
        sfab.FabricatedSObjectNodeStub node = new sfab.FabricatedSObjectNodeStub(fields);
        SObject sObj = new sfab.FabricatedSObject(Account.class, new List<sfab.FabricatedSObjectNode>{
            node
        }).toSObject();
        System.assertEquals(fields.get('Id'), sObj.Id);
        System.assertEquals(fields.get('Name'), sObj.get('Name'));
    }

    @IsTest
    private static void setField_whenFieldDoesNotExist_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField(Account.AccountNumber, 'Id-1');
        } catch (sfab.FieldDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Contact.AccountNumber does not exist'),
            'setField, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setField_whenStringFieldDoesNotExist_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField('Invalid', 'Id-1');
        } catch (sfab.FieldDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Invalid does not exist'),
            'setField, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setField_whenStringFieldIsParentRelationship_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField('Account', 'Is a parent relationship');
        } catch (sfab.FieldIsNotSimpleFieldException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Contact.Account cannot to set to a primitive, it is a parent relationship field'),
            'setField, when field is a parent relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setField_whenStringFieldIsChildRelationship_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField('Contacts', 'Is a child relationship');
        } catch (sfab.FieldIsNotSimpleFieldException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Contacts cannot to set to a primitive, it is a child relationship field'),
            'setField, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setField_whenStringNavigatingAndFieldDoesNotExist_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField('Account.Invalid', 'Id-1');
        } catch (sfab.FieldDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Invalid does not exist'),
            'setField, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setField_whenStringNavigatingAndFieldIsParentRelationship_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField('Account.Owner', 'Is a parent relationship');
        } catch (sfab.FieldIsNotSimpleFieldException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Owner cannot to set to a primitive, it is a parent relationship field'),
            'setField, when field is a parent relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setField_whenStringNavigatingAndFieldIsChildRelationship_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setField('Account.Contacts', 'Is a child relationship');
        } catch (sfab.FieldIsNotSimpleFieldException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Contacts cannot to set to a primitive, it is a child relationship field'),
            'setField, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldDoesNotExist_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Account', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.ParentRelationshipDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The parent relationship Account.Account does not exist'),
            'setParent, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldIsASimpleField_expectException() {

        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Name', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotParentRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Name is not a parent relationship'),
            'setParent, when field is a simple field, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldIsAChildRelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Contacts', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotParentRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Contacts is not a parent relationship'),
            'setParent, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldIsADifferentSobject_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Account', new sfab.FabricatedSObject(Contact.class));
        } catch (sfab.FieldIsADifferentTypeException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Contact.Account is Account, not Contact'),
            'setParent, when field is a different SObject, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldIsPolymorphicAndADifferentSobject_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Task.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Owner', new sfab.FabricatedSObject(Contact.class));
        } catch (sfab.FieldIsADifferentTypeException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Task.Owner is Group,User, not Contact'),
            'setParent, when field is polymorphic and for a different SObject, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldIsPolymorphicAndACorrectSobject_expectNoException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Task.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Owner', new sfab.FabricatedSObject(User.class));
        } catch (sfab.FieldIsADifferentTypeException e) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals('', exceptionMessage, 'setParent, when field is polymorphic and the passed SObject included, will not throw an exception (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldOnParentDoesNotExist_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Account.NotValid', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.ParentRelationshipDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The parent relationship Account.NotValid does not exist'),
            'setParent, when field on the parent does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldOnParentIsASimpleField_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Account.Name', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotParentRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Name is not a parent relationship'),
            'setParent, when field on the parent is a simple field, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setParent_whenFieldOnParentIsAChildRelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setParent('Account.Opportunities', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotParentRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Opportunities is not a parent relationship'),
            'setParent, when field on the parent is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldDoesNotExist_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Accounts', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(Account.class)
            });
        } catch (sfab.ChildRelationshipDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The child relationship Account.Accounts does not exist'),
            'setChildren, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldIsASimpleField_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Name', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(Account.class)
            });
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Name is not a child relationship'),
            'setChildren, when field is a simple field, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldIsAParentRelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Account', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(Account.class)
            });
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Contact.Account is not a child relationship'),
            'setChildren, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldIsADifferentSobject_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Contacts', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(User.class)
            });
        } catch (sfab.FieldIsADifferentTypeException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The relationship Account.Contacts is Contact, not User'),
            'setChildren, when field is a different SObject, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldOnParentDoesNotExist_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Account.Accounts', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(Account.class)
            });
        } catch (sfab.ChildRelationshipDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The child relationship Account.Accounts does not exist'),
            'setChildren, when field on parent does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldOnParentIsASimpleField_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Account.Name', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(Account.class)
            });
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Name is not a child relationship'),
            'setChildren, when field is a simple field, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void setChildren_whenFieldOnParentIsAParentRelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.setChildren('Account.Owner', new List<sfab.FabricatedSObject>{
                new sfab.FabricatedSObject(Account.class)
            });
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Owner is not a child relationship'),
            'setChildren, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldDoesNotExist_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Accounts', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.ChildRelationshipDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The child relationship Account.Accounts does not exist'),
            'addChild, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldIsADifferentObjectType_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Contacts', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsADifferentTypeException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The relationship Account.Contacts is Contact, not Account'),
            'addChild, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldIsASimpleField_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Name', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Name is not a child relationship'),
            'addChild, when field is a simple field, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldIsAParentRelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Account', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Contact.Account is not a child relationship'),
            'addChild, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldOnParentDoesNotExist_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Account.Accounts', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.ChildRelationshipDoesNotExistException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The child relationship Account.Accounts does not exist'),
            'addChild, when field on parent does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldOnParentIsASimpleField_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Account.Name', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Name is not a child relationship'),
            'addChild, when field is a simple field, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void addChild_whenFieldOnParentIsAParentRelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Contact.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.addChild('Account.Owner', new sfab.FabricatedSObject(Account.class));
        } catch (sfab.FieldIsNotChildRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('The field Account.Owner is not a child relationship'),
            'addChild, when field is a child relationship, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void set_whenStringFieldForParentNotARelationship_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Account.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.set('Name.NotARelationship', 'name is not a relationship');
        } catch (sfab.FieldIsNotParentRelationshipException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('Account.Name is not a parent relationship'), 'set, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void set_whenStringFieldForParentPolymorphic_expectException() {
        sfab.FabricatedSObject fabricatedSObject = new sfab.FabricatedSObject(Task.class);

        String exceptionMessage = '';
        try {
            fabricatedSObject.set('Owner.Username', 'cannot create polymorphic ones automatically');
        } catch (sfab.ParentRelationshipObjectCannotBeAutoCreatedException e) {
            exceptionMessage = e.getMessage();
        }
        System.assert(exceptionMessage.contains('Could not auto-assign an object for the field Owner'), 'set, when field does not exist, will throw an exception with a useful message (got "' + exceptionMessage + '")');
    }

    @IsTest
    private static void toSObject_whenBlobSetOnContentVersion_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.set('VersionData', Blob.valueOf('abc'));
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnAttachment_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(Attachment.class);
        fabricated.set('Body', Blob.valueOf('abc'));
        Attachment sobj = (Attachment) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.Body);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnDocument_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(Document.class);
        fabricated.set('Body', Blob.valueOf('abc'));
        Document sobj = (Document) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.Body);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnStaticResource_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(StaticResource.class);
        fabricated.set('Body', Blob.valueOf('abc'));
        StaticResource sobj = (StaticResource) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.Body);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnMailMergeTemplate_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(MailmergeTemplate.class);
        fabricated.set('Body', Blob.valueOf('abc'));
        MailmergeTemplate sobj = (MailmergeTemplate) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.Body);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnEventLogFile_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(EventLogFile.class);
        fabricated.set('LogFile', Blob.valueOf('abc'));
        EventLogFile sobj = (EventLogFile) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.LogFile);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnMobileApplicationDetail_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(MobileApplicationDetail.class);
        fabricated.set('ApplicationBinary', Blob.valueOf('abc'));
        MobileApplicationDetail sobj = (MobileApplicationDetail) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.ApplicationBinary);
    }

    @IsTest
    private static void toSObject_whenBlobSetViaField_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.set(ContentVersion.VersionData, Blob.valueOf('abc'));
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetViaSetField_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.setField('VersionData', Blob.valueOf('abc'));
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetViaSetFieldWithField_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.setField(ContentVersion.VersionData, Blob.valueOf('abc'));
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetToString_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.set('VersionData', 'abc');
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetToEmptyString_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.set('VersionData', '');
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(Blob.valueOf(''), sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetToNull_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentVersion.class);
        fabricated.set('VersionData', (String) null);
        ContentVersion sobj = (ContentVersion) fabricated.toSObject();
        System.assertEquals(null, sobj.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetOnParent_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated = new sfab.FabricatedSObject(ContentDocumentLink.class);
        fabricated.set('ContentDocument.LatestPublishedVersion.VersionData', Blob.valueOf('abc'));
        ContentDocumentLink sobj = (ContentDocumentLink) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('abc'), sobj.ContentDocument.LatestPublishedVersion.VersionData);
    }

    @IsTest
    private static void toSObject_whenBlobSetAndChildren_expectBlobValueSet() {
        sfab.FabricatedSObject fabricated =
            new sfab.FabricatedSObject(ContentDocument.class)
                .add('ContentVersions', new sfab.FabricatedSObject(ContentVersion.class)
                    .set('VersionData', Blob.valueOf('def')))
                .add('ContentVersions', new sfab.FabricatedSObject(ContentVersion.class)
                    .set('VersionData', Blob.valueOf('ghi')))
                .add('ContentVersions', new sfab.FabricatedSObject(ContentVersion.class)
                    .set('VersionData', Blob.valueOf('abc')));

        ContentDocument sobj = (ContentDocument) fabricated.toSObject();
        System.assertEquals(Blob.valueOf('def'), sobj.ContentVersions[0].VersionData);
        System.assertEquals(Blob.valueOf('ghi'), sobj.ContentVersions[1].VersionData);
        System.assertEquals(Blob.valueOf('abc'), sobj.ContentVersions[2].VersionData);
    }

    @IsTest
    private static void serialize_expectMap() {
        sfab.FieldValuePairNode node = new sfab.FieldValuePairNode(Account.Name, 'Foo');
        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(new Map<String, Object>{
            'Name' => 'Foo'
        }, builtNode);
    }

    @IsTest
    private static void getName_expectNameFromField() {
        sfab.FieldValuePairNode node = new sfab.FieldValuePairNode(Account.Name, 'Foo');
        System.assertEquals('Name', node.getName());
    }

    @IsTest
    private static void getName_whenNoField_expectNull() {
        sfab.FieldValuePairNode node = new sfab.FieldValuePairNode(null, 'Foo');
        System.assertEquals(null, node.getName());
    }
}
