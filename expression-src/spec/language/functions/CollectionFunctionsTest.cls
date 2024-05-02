@IsTest
private class CollectionFunctionsTest {
    @IsTest
    private static void listFunctionReturnsAListContainingAllArguments() {
        Object result = Evaluator.run('LIST(1, 2, 3)');
        Assert.isTrue(result instanceof List<Object>);
        Assert.areEqual(1, ((List<Object>) result)[0]);
        Assert.areEqual(2, ((List<Object>) result)[1]);
        Assert.areEqual(3, ((List<Object>) result)[2]);
    }

    @IsTest
    private static void averageFunctionReturnsTheAverage() {
        Assert.areEqual(2, Evaluator.run('AVERAGE(LIST(1, 2, 3))'));
    }

    @IsTest
    private static void averageFunctionReturnsTheAverageOfASet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<Integer>{
                1, 2, 3
            }
        };

        Assert.areEqual(2, Evaluator.run('AVERAGE(@extra)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void maxFunctionAcceptsAListAsAsArgument() {
        Assert.areEqual(3, Evaluator.run('MAX(LIST(1, 2, 3))'));
    }

    @IsTest
    private static void mapFunctionReturnsGivenAChildRelationshipAndAFieldName() {
        Account account = new Account(Name = 'Test');
        insert account;
        Contact contact1 = new Contact(LastName = 'Test1', AccountId = account.Id);
        Contact contact2 = new Contact(LastName = 'Test2', AccountId = account.Id);
        insert new List<SObject>{
            contact1, contact2
        };
        Account accountWithContacts = [SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account WHERE Id = :account.Id];

        List<Object> result = (List<Object>) Evaluator.run('MAP(Contacts, LastName)', accountWithContacts);

        Assert.areEqual(2, result.size());
        Assert.areEqual('Test1', result[0]);
        Assert.areEqual('Test2', result[1]);
    }

    @IsTest
    private static void mapFunctionWorksOnSets() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<String>{
                'a', 'b', 'c'
            }
        };

        List<Object> result = (List<Object>) Evaluator.run('MAP(@extra, upper($current))',
            new Configuration().withCustomContext(extraContext));

        Assert.areEqual(3, result.size());
        Assert.isTrue(result.contains('A'));
        Assert.isTrue(result.contains('B'));
        Assert.isTrue(result.contains('C'));
    }

    @IsTest
    private static void canCombineListFunctionsWithMap() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        Decimal result = (Decimal) Evaluator.run('AVERAGE(MAP(ChildAccounts, NumberOfEmployees))', parentAccountWithChildren);

        Assert.areEqual(15, result);
    }

    @IsTest
    private static void sizeFunctionReturnsAListSize() {
        Assert.areEqual(3, Evaluator.run('SIZE(LIST(1, 2, 3))'));
    }

    @IsTest
    private static void sizeFunctionReturnsAMapSize() {
        Assert.areEqual(2, Evaluator.run('SIZE({"a": 1, "b": 2})'));
    }

    @IsTest
    private static void sizeFunctionReturnsASetSize() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<String>{
                'a', 'b', 'c'
            }
        };

        Assert.areEqual(3, Evaluator.run('SIZE(@extra)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void canMapARegularListToASingleValue() {
        List<Object> result = (List<Object>) Evaluator.run('MAP(LIST("a", "b", "c"), upper($current))');
        Assert.areEqual('A', result[0]);
        Assert.areEqual('B', result[1]);
        Assert.areEqual('C', result[2]);
    }

    @IsTest
    private static void canMapToAnObjectLiteral() {
        List<Object> result = (List<Object>) Evaluator.run('MAP(LIST("a", "b", "c"), {$index: $current})');
        Assert.areEqual('a', ((Map<Object, Object>) result[0]).get(0));
        Assert.areEqual('b', ((Map<Object, Object>) result[1]).get(1));
        Assert.areEqual('c', ((Map<Object, Object>) result[2]).get(2));
    }

    @IsTest
    private static void isEmptyReturnsTrueForAnEmptyList() {
        Assert.areEqual(true, Evaluator.run('ISEMPTY([])'));
    }

    @IsTest
    private static void isEmptyReturnsFalseForANonEmptyList() {
        Assert.areEqual(false, Evaluator.run('ISEMPTY([1])'));
    }

    @IsTest
    private static void isEmptyReturnsTrueForAnEmptyMap() {
        Assert.areEqual(true, Evaluator.run('ISEMPTY({})'));
    }

    @IsTest
    private static void isEmptyReturnsFalseForANonEmptyMap() {
        Assert.areEqual(false, Evaluator.run('ISEMPTY({"a": 1})'));
    }

    @IsTest
    private static void isEmptyReturnsTrueForAnEmptySet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<String>()
        };

        Assert.areEqual(true, Evaluator.run('ISEMPTY(@extra)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void isEmptyReturnsFalseForANonEmptySet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<String>{
                'a'
            }
        };

        Assert.areEqual(false, Evaluator.run('ISEMPTY(@extra)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void appendFunctionAppendsToAList() {
        List<Object> result = (List<Object>) Evaluator.run('APPEND([1, 2], 3)');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
    }

    @IsTest
    private static void appendFunctionAppendsToASet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<String>{
                'a', 'b'
            }
        };

        List<Object> result = (List<Object>) Evaluator.run('APPEND(@extra, "c")',
            new Configuration().withCustomContext(extraContext));

        Assert.areEqual(3, result.size());
        Assert.isTrue(result.contains('a'));
        Assert.isTrue(result.contains('b'));
        Assert.isTrue(result.contains('c'));
    }

    @IsTest
    private static void sortFunctionSortsAList() {
        List<Object> result = (List<Object>) Evaluator.run('SORT([3, 2, 1])');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
    }

    @IsTest
    private static void sortFunctionSortsASet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<Integer>{
                3, 2, 1
            }
        };

        List<Object> result = (List<Object>) Evaluator.run('SORT(@extra)',
            new Configuration().withCustomContext(extraContext));

        Assert.areEqual(3, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
    }

    @IsTest
    private static void canSortAListOfMapByAField() {
        List<Object> result = (List<Object>) Evaluator.run('SORT([{"a": 3}, {"a": 2}, {"a": 1}], "a")');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, ((Map<Object, Object>) result[0]).get('a'));
        Assert.areEqual(2, ((Map<Object, Object>) result[1]).get('a'));
        Assert.areEqual(3, ((Map<Object, Object>) result[2]).get('a'));
    }

    @IsTest
    private static void canSortAListOfMapByAFieldInAscendingOrder() {
        List<Object> result = (List<Object>) Evaluator.run('SORT([{"a": 3}, {"a": 2}, {"a": 1}], "a", "asc")');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, ((Map<Object, Object>) result[0]).get('a'));
        Assert.areEqual(2, ((Map<Object, Object>) result[1]).get('a'));
        Assert.areEqual(3, ((Map<Object, Object>) result[2]).get('a'));
    }

    @IsTest
    private static void canSortAListOfMapByAFieldInDescendingOrder() {
        List<Object> result = (List<Object>) Evaluator.run('SORT([{"a": 3}, {"a": 2}, {"a": 1}], "a", "desc")');
        Assert.areEqual(3, result.size());
        Assert.areEqual(3, ((Map<Object, Object>) result[0]).get('a'));
        Assert.areEqual(2, ((Map<Object, Object>) result[1]).get('a'));
        Assert.areEqual(1, ((Map<Object, Object>) result[2]).get('a'));
    }

    @IsTest
    private static void whenSortingIfAMapDoesNotContainTheFieldItIsSortedAtTheEnd() {
        List<Object> result = (List<Object>) Evaluator.run('SORT([{"a": 3}, {"a": 2}, {"b": 1}], "a")');
        Assert.areEqual(3, result.size());
        Assert.areEqual(2, ((Map<Object, Object>) result[0]).get('a'));
        Assert.areEqual(3, ((Map<Object, Object>) result[1]).get('a'));
        Assert.areEqual(1, ((Map<Object, Object>) result[2]).get('b'));
    }

    @IsTest
    private static void canSortBySObjectField() {
        Account account1 = new Account(Name = 'A');
        Account account2 = new Account(Name = 'C');
        Account account3 = new Account(Name = 'B');

        insert new List<SObject>{
            account1, account2, account3
        };

        List<Object> result = (List<Object>) Evaluator.run('QUERY(Account[Name]) -> SORT("Name")');

        Assert.areEqual(3, result.size());
        Assert.areEqual('A', ((Account) result[0]).Name);
        Assert.areEqual('B', ((Account) result[1]).Name);
        Assert.areEqual('C', ((Account) result[2]).Name);
    }

    @IsTest
    private static void canSortBySObjectFieldInDescendingOrder() {
        Account account1 = new Account(Name = 'A');
        Account account2 = new Account(Name = 'C');
        Account account3 = new Account(Name = 'B');

        insert new List<SObject>{
            account1, account2, account3
        };

        List<Object> result = (List<Object>) Evaluator.run('QUERY(Account["Name"]) -> SORT("Name", "desc")');

        Assert.areEqual(3, result.size());
        Assert.areEqual('C', ((Account) result[0]).Name);
        Assert.areEqual('B', ((Account) result[1]).Name);
        Assert.areEqual('A', ((Account) result[2]).Name);
    }

    @IsTest
    private static void canSortBySObjectFieldInAscendingOrder() {
        Account account1 = new Account(Name = 'A');
        Account account2 = new Account(Name = 'C');
        Account account3 = new Account(Name = 'B');

        insert new List<SObject>{
            account1, account2, account3
        };

        List<Object> result = (List<Object>) Evaluator.run('QUERY(Account[Name]) -> SORT("Name", "asc")');

        Assert.areEqual(3, result.size());
        Assert.areEqual('A', ((Account) result[0]).Name);
        Assert.areEqual('B', ((Account) result[1]).Name);
        Assert.areEqual('C', ((Account) result[2]).Name);
    }

    @IsTest
    private static void canSortSObjectByField_nullsArePlacedLast() {
        Account account1 = new Account(Name = 'A', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'B', NumberOfEmployees = 20);
        Account account3 = new Account(Name = 'C', NumberOfEmployees = 30);
        Account account4 = new Account(Name = 'D', NumberOfEmployees = null);

        insert new List<SObject>{
            account1, account2, account3, account4
        };

        List<Object> result = (List<Object>) Evaluator.run('Query(Account["Name", "NumberOfEmployees"]) -> SORT("NumberOfEmployees")');

        Assert.areEqual(4, result.size());
        Assert.areEqual('A', ((Account) result[0]).Name);
        Assert.areEqual('B', ((Account) result[1]).Name);
        Assert.areEqual('C', ((Account) result[2]).Name);
        Assert.areEqual('D', ((Account) result[3]).Name);
    }

    @IsTest
    private static void fieldResolutionWorksWhenUsingTheSortFunction() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 20);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 10);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run('SORT(ChildAccounts, NumberOfEmployees, "asc")', parentAccount.Id);

        Assert.areEqual(2, result.size());
        Assert.areEqual(10, ((Account) result[0]).NumberOfEmployees);
        Assert.areEqual(20, ((Account) result[1]).NumberOfEmployees);
    }

    @IsTest
    private static void reverseFunctionReversesAList() {
        List<Object> result = (List<Object>) Evaluator.run('REVERSE([1, 2, 3])');
        Assert.areEqual(3, result.size());
        Assert.areEqual(3, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(1, result[2]);
    }

    @IsTest
    private static void distinctFunctionReturnsDistinctValues() {
        List<Object> result = (List<Object>) Evaluator.run('DISTINCT([1, 2, 1, 3, 2, 4])');
        Assert.areEqual(4, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
        Assert.areEqual(4, result[3]);
    }

    @IsTest
    private static void keysFunctionReturnsTheKeysOfAMap() {
        List<Object> result = (List<Object>) Evaluator.run('KEYS({"a": 1, "b": 2})');
        Assert.areEqual(2, result.size());
        Assert.areEqual('a', result[0]);
        Assert.areEqual('b', result[1]);
    }

    @IsTest
    private static void getFunctionReturnsAMapValue() {
        Assert.areEqual(1, Evaluator.run('GET({"a": 1, "b": 2}, "a")'));
    }

    @IsTest
    private static void getFunctionReturnsAField() {
        Account account = new Account(Name = 'Test');
        insert account;

        String formula = 'QUERY(Account["Name"]) -> FIRST() -> GET("Name")';
        Object result = Evaluator.run(formula);

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void valuesFunctionReturnsTheValuesOfAMap() {
        List<Object> result = (List<Object>) Evaluator.run('VALUES({"a": 1, "b": 2})');
        Assert.areEqual(2, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
    }

    @IsTest
    private static void whereFunctionAllowsForValuesToBeFiltered() {
        List<Object> result = (List<Object>) Evaluator.run('WHERE([1, 2, 3, 4], $current > 2)');
        Assert.areEqual(2, result.size());
        Assert.areEqual(3, result[0]);
        Assert.areEqual(4, result[1]);
    }

    @IsTest
    private static void whereFunctionAllowsForASetOfValuesToBeFiltered() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<String>{
                'a', 'b', 'c'
            }
        };

        List<Object> result = (List<Object>) Evaluator.run('WHERE(@extra, $current != "b")',
            new Configuration().withCustomContext(extraContext));

        Assert.areEqual(2, result.size());
        Assert.isTrue(result.contains('a'));
        Assert.isTrue(result.contains('c'));
    }

    @IsTest
    private static void whereFunctionAllowsToFilterByFieldsOnChildRecords_usingRecord() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees, Parent.Name FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        List<Object> result = (List<Object>) Evaluator.run('WHERE(ChildAccounts, NumberOfEmployees > 10)', parentAccountWithChildren);

        Assert.areEqual(1, result.size());
        Assert.areEqual(20, ((Account) result[0]).NumberOfEmployees);
    }

    @IsTest
    private static void whereFunctionAllowsToFilterByFieldsOnChildRecords_usingId() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run('WHERE(ChildAccounts, NumberOfEmployees > 10)', parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual(20, ((Account) result[0]).NumberOfEmployees);
    }

    @IsTest
    private static void combiningWhereAndMap() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run('MAP(WHERE(ChildAccounts, NumberOfEmployees > 10), Name)', parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Child2', result[0]);
    }

    @IsTest
    private static void combiningWhereAndMap_withRelationshipsBetweenDifferentSObjectTypes() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        String expr = 'MAP(WHERE(Contacts, BEGINS(LastName, "C")), Name)';
        List<Object> result = (List<Object>) Evaluator.run(expr, parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Child', result[0]);
    }

    @IsTest
    private static void nestingWheres() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        Account childAccount3 = new Account(Name = 'Child3', ParentId = parentAccount.Id, NumberOfEmployees = 30, AnnualRevenue = 300);
        insert new List<SObject>{
            childAccount1, childAccount2, childAccount3
        };

        List<Object> result = (List<Object>) Evaluator.run('MAP(WHERE(WHERE(ChildAccounts, NumberOfEmployees > 10), AnnualRevenue > 200), Name)', parentAccount.Id);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Child3', result[0]);
    }

    @IsTest
    private static void firstFunctionReturnsTheFirstElementOfAList() {
        Assert.areEqual(1, Evaluator.run('FIRST([1, 2, 3])'));
    }

    @IsTest
    private static void firstFunctionReturnsNullIfTheListIsEmpty() {
        Assert.isNull(Evaluator.run('FIRST([])'));
    }

    @IsTest
    private static void lastFunctionReturnsTheLastElementOfAList() {
        Assert.areEqual(3, Evaluator.run('LAST([1, 2, 3])'));
    }

    @IsTest
    private static void lastFunctionReturnsNullIfTheListIsEmpty() {
        Assert.isNull(Evaluator.run('LAST([])'));
    }

    @IsTest
    private static void reduceCanSumAListOfNumbers() {
        Assert.areEqual(6, Evaluator.run('REDUCE([1, 2, 3], $current + $accumulator, 0)'));
    }

    @IsTest
    private static void reduceWorksOnASet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<Integer>{
                1, 2, 3
            }
        };

        Assert.areEqual(6, Evaluator.run('REDUCE(@extra, $current + $accumulator, 0)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void reduceWorksWithSObjectExpressions() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        Account childAccount3 = new Account(Name = 'Child3', ParentId = parentAccount.Id, NumberOfEmployees = 30, AnnualRevenue = 300);
        insert new List<SObject>{
            childAccount1, childAccount2, childAccount3
        };

        String formula = 'REDUCE(ChildAccounts, NumberOfEmployees + $accumulator, 0)';
        Object result = Evaluator.run(formula, parentAccount.Id);

        Assert.areEqual(60, result);
    }

    @IsTest
    private static void reduceToMap() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        Account childAccount3 = new Account(Name = 'Child3', ParentId = parentAccount.Id, NumberOfEmployees = 30, AnnualRevenue = 300);
        insert new List<SObject>{
            childAccount1, childAccount2, childAccount3
        };

        String formula = 'REDUCE(ChildAccounts, ' +
            '{"employees": NumberOfEmployees + GET($accumulator, "employees"), "revenue": AnnualRevenue + GET($accumulator, "revenue")}, ' +
            '{"employees": 0, "revenue": 0}' +
            ')';
        Object result = Evaluator.run(formula, parentAccount.Id);

        Assert.areEqual(60, ((Map<Object, Object>) result).get('employees'));
        Assert.areEqual(600, ((Map<Object, Object>) result).get('revenue'));
    }

    @IsTest
    private static void putFunctionAddsAKeyAndValueToAMap() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('PUT({}, "a", 1)');
        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result.get('a'));
    }

    @IsTest
    private static void putFunctionThrowsExceptionWhenFirstArgumentIsNotAMap() {
        try {
            Evaluator.run('PUT(1, "a", 1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void atFunctionReturnsTheValueAtTheGivenIndex() {
        Assert.areEqual(2, Evaluator.run('AT([1, 2, 3], 1)'));
    }

    @IsTest
    private static void atFunctionThrowsExceptionWhenFirstArgumentIsNotAList() {
        try {
            Evaluator.run('AT(1, 1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void atFunctionThrowsExceptionWhenSecondArgumentIsNotANumber() {
        try {
            Evaluator.run('AT([1, 2, 3], "a")');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void atFunctionReturnsNullIfTheListIsEmpty() {
        Assert.isNull(Evaluator.run('AT([], 0)'));
    }

    @IsTest
    private static void atFunctionReturnsNullIfTheIndexIsOutOfBounds() {
        Assert.isNull(Evaluator.run('AT([1, 2, 3], 3)'));
    }

    @IsTest
    private static void anyFunctionReturnsTrueIfAnyElementMatchesThePredicate() {
        Assert.isTrue((Boolean) Evaluator.run('ANY([1, 2, 3], $current > 2)'));
    }

    @IsTest
    private static void anyFunctionReturnsFalseIfNoElementMatchesThePredicate() {
        Assert.isFalse((Boolean) Evaluator.run('ANY([1, 2, 3], $current > 3)'));
    }

    @IsTest
    private static void anyFunctionReturnsFalseIfTheListIsEmpty() {
        Assert.isFalse((Boolean) Evaluator.run('ANY([], $current > 3)'));
    }

    @IsTest
    private static void anyWorksOnASet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<Integer>{
                1, 2, 3
            }
        };

        Assert.isTrue((Boolean) Evaluator.run('ANY(@extra, $current > 2)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void anyFunctionThrowsAnExceptionIfTheFirstArgumentIsNotAnIterable() {
        try {
            Evaluator.run('ANY(1, $current > 3)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void anyFunctionThrowsAnExceptionIfThePredicateDoesNotEvaluateToABoolean() {
        try {
            Evaluator.run('ANY([1, 2, 3], $current)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void sumFunctionReturnsTheSumOfTheList() {
        Assert.areEqual(6, Evaluator.run('SUM([1, 2, 3])'));
    }

    @IsTest
    private static void sumFunctionEvaluatesToZeroWhenTheListIsEmpty() {
        Assert.areEqual(0, Evaluator.run('SUM([])'));
    }

    @IsTest
    private static void sumFunctionWorksOnASet() {
        Map<String, Object> extraContext = new Map<String, Object>{
            'extra' => new Set<Integer>{
                1, 2, 3
            }
        };

        Assert.areEqual(6, Evaluator.run('SUM(@extra)',
            new Configuration().withCustomContext(extraContext)));
    }

    @IsTest
    private static void sumFunctionThrowsAnExceptionIfAListIsNotReceived() {
        try {
            Evaluator.run('SUM(1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void sumFunctionThrowsAnExceptionIfAnyOfTheElementsInTheListIsNotANumber() {
        try {
            Evaluator.run('SUM([1, 2, "a"])');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void everyFunctionReturnsTrueIfEveryElementMatchesThePredicate() {
        Assert.isTrue((Boolean) Evaluator.run('EVERY([1, 2, 3], $current > 0)'));
    }

    @IsTest
    private static void everyFunctionReturnsFalseIfAnyElementDoesNotMatchThePredicate() {
        Assert.isFalse((Boolean) Evaluator.run('EVERY([1, 2, 3], $current > 1)'));
    }

    @IsTest
    private static void everyFunctionReturnsFalseIfTheListIsEmpty() {
        Assert.isFalse((Boolean) Evaluator.run('EVERY([], $current > 3)'));
    }

    @IsTest
    private static void everyFunctionThrowsAnExceptionIfTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('EVERY(1, $current > 3)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void everyFunctionThrowsAnExceptionIfThePredicateDoesNotEvaluateToABoolean() {
        try {
            Evaluator.run('EVERY([1, 2, 3], $current)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void expandFunctionExpandsEachElementOfTheListIntoTheResolvedExpression() {
        String formula = 'EXPAND([1, 3, 0, 2], [{"value": $current}])';
        List<Object> result = (List<Object>) Evaluator.run(formula);
        Assert.areEqual(4, result.size());
        Assert.areEqual(1, ((Map<Object, Object>) result[0]).get('value'));
        Assert.areEqual(3, ((Map<Object, Object>) result[1]).get('value'));
        Assert.areEqual(0, ((Map<Object, Object>) result[2]).get('value'));
        Assert.areEqual(2, ((Map<Object, Object>) result[3]).get('value'));
    }

    @IsTest
    private static void expandFunctionThrowsAnExceptionIfTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('EXPAND(1, [{"value": $current}])');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void expandFunctionReturnsAnEmptyListIfAnEmptyListIsReceived() {
        List<Object> result = (List<Object>) Evaluator.run('EXPAND([], [{"value": $current}])');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void expandFunctionThrowsAnExceptionIfTheSecondArgumentDoesNotEvaluateToAList() {
        try {
            Evaluator.run('EXPAND([1, 2, 3], 1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void firstWhereFunctionReturnsTheFirstElementThatMatchesThePredicate() {
        Assert.areEqual(2, Evaluator.run('FIRSTWHERE([1, 2, 3], $current > 1)'));
    }

    @IsTest
    private static void firstWhereThrowsAnExceptionIfTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('FIRSTWHERE(1, $current > 1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void firstWhereThrowsAnExceptionIfThePredicateDoesNotEvaluateToABoolean() {
        try {
            Evaluator.run('FIRSTWHERE([1, 2, 3], $current)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void firstWhereReturnsNullIfTheListIsEmpty() {
        Assert.isNull(Evaluator.run('FIRSTWHERE([], $current > 1)'));
    }

    @IsTest
    private static void firstWhereReturnsNullIfNoElementMatchesThePredicate() {
        Assert.isNull(Evaluator.run('FIRSTWHERE([1, 2, 3], $current > 3)'));
    }

    @IsTest
    private static void followedByAppendsAListToAnother() {
        List<Object> result = (List<Object>) Evaluator.run('[1, 2] -> FOLLOWEDBY([3, 4])');
        Assert.areEqual(4, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
        Assert.areEqual(4, result[3]);
    }

    @IsTest
    private static void followedByThrowsAnErrorWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('1 -> FOLLOWEDBY([3, 4])');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void followedByThrowsAnErrorWhenTheSecondArgumentIsNotAList() {
        try {
            Evaluator.run('[1, 2] -> FOLLOWEDBY(1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void joinFunctionJoinsAListIntoAString() {
        Assert.areEqual('1, 2, 3', Evaluator.run('JOIN([1, 2, 3], ", ")'));
    }

    @IsTest
    private static void joinFunctionThrowsAnErrorWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('JOIN(1, ", ")');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void joinFunctionThrowsAnErrorWhenTheSecondArgumentIsNotAString() {
        try {
            Evaluator.run('JOIN([1, 2, 3], 1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void lastWhereFunctionReturnsTheLastElementThatMatchesThePredicate() {
        Assert.areEqual(3, Evaluator.run('LASTWHERE([1, 2, 3], $current > 1)'));
    }

    @IsTest
    private static void lastWhereReturnsNullWhenTheListIsEmpty() {
        Assert.isNull(Evaluator.run('LASTWHERE([], $current > 1)'));
    }

    @IsTest
    private static void lastWhereReturnsNullWhenNoElementMatchesThePredicate() {
        Assert.isNull(Evaluator.run('LASTWHERE([1, 2, 3], $current > 3)'));
    }

    @IsTest
    private static void lastWhereThrowsAnExceptionWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('LASTWHERE(1, $current > 1)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void lastWhereThrowsAnExceptionWhenTheSecondArgumentDoesNotEvaluateToABoolean() {
        try {
            Evaluator.run('LASTWHERE([1, 2, 3], $current)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void skipFunctionSkipsTheFirstNElementsOfAList() {
        List<Object> result = (List<Object>) Evaluator.run('SKIP([1, 2, 3, 4], 2)');
        Assert.areEqual(2, result.size());
        Assert.areEqual(3, result[0]);
        Assert.areEqual(4, result[1]);
    }

    @IsTest
    private static void skipFunctionThrowsAnExceptionWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('SKIP(1, 2)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void skipFunctionThrowsAnExceptionWhenTheSecondArgumentIsNotANumber() {
        try {
            Evaluator.run('SKIP([1, 2, 3, 4], "a")');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void skipFunctionReturnsAnEmptyListWhenTheListIsEmpty() {
        List<Object> result = (List<Object>) Evaluator.run('SKIP([], 2)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void skipFunctionReturnsAnEmptyListWhenTheNumberIsNegative() {
        List<Object> result = (List<Object>) Evaluator.run('SKIP([1, 2, 3, 4], -2)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void skipFunctionReturnsAnEmptyListWhenTheNumberIsGreaterThanTheSizeOfTheList() {
        List<Object> result = (List<Object>) Evaluator.run('SKIP([1, 2, 3, 4], 5)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void skipWhileFunctionSkipsElementsWhileThePredicateIsTrue() {
        List<Object> result = (List<Object>) Evaluator.run('SKIPWHILE([1, 2, 3, 4], $current < 3)');
        Assert.areEqual(2, result.size());
        Assert.areEqual(3, result[0]);
        Assert.areEqual(4, result[1]);
    }

    @IsTest
    private static void skipWhileThrowsAnExceptionWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('SKIPWHILE(1, $current < 3)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void skipWhileThrowsAnExceptionWhenTheSecondArgumentDoesNotEvaluateToABoolean() {
        try {
            Evaluator.run('SKIPWHILE([1, 2, 3, 4], $current)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void skipWhileReturnsAnEmptyListWhenTheListIsEmpty() {
        List<Object> result = (List<Object>) Evaluator.run('SKIPWHILE([], $current < 3)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void skipWhileReturnsAnEmptyWhenThePredicateIsNeverFalse() {
        List<Object> result = (List<Object>) Evaluator.run('SKIPWHILE([1, 2, 3, 4], $current < 5)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void takeFunctionTakesTheFirstNElementsOfAList() {
        List<Object> result = (List<Object>) Evaluator.run('TAKE([1, 2, 3, 4], 2)');
        Assert.areEqual(2, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
    }

    @IsTest
    private static void takeFunctionThrowsAnExceptionWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('TAKE(1, 2)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void takeFunctionThrowsAnExceptionWhenTheSecondArgumentIsNotANumber() {
        try {
            Evaluator.run('TAKE([1, 2, 3, 4], "a")');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void takeFunctionReturnsAnEmptyListWhenTheListIsEmpty() {
        List<Object> result = (List<Object>) Evaluator.run('TAKE([], 2)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void takeFunctionReturnsAnEmptyListWhenTheNumberIsNegative() {
        List<Object> result = (List<Object>) Evaluator.run('TAKE([1, 2, 3, 4], -2)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void takeFunctionReturnsTheWholeListWhenTheNumberIsGreaterThanTheSizeOfTheList() {
        List<Object> result = (List<Object>) Evaluator.run('TAKE([1, 2, 3, 4], 5)');
        Assert.areEqual(4, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
        Assert.areEqual(4, result[3]);
    }

    @IsTest
    private static void takeWhileFunctionTakesElementsWhileThePredicateIsTrue() {
        List<Object> result = (List<Object>) Evaluator.run('TAKEWHILE([1, 2, 3, 4], $current < 3)');
        Assert.areEqual(2, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
    }

    @IsTest
    private static void takeWhileThrowsAnExceptionWhenTheFirstArgumentIsNotAList() {
        try {
            Evaluator.run('TAKEWHILE(1, $current < 3)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void takeWhileThrowsAnExceptionWhenTheSecondArgumentDoesNotEvaluateToABoolean() {
        try {
            Evaluator.run('TAKEWHILE([1, 2, 3, 4], $current)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void takeWhileReturnsAnEmptyListWhenTheListIsEmpty() {
        List<Object> result = (List<Object>) Evaluator.run('TAKEWHILE([], $current < 3)');
        Assert.areEqual(0, result.size());
    }

    @IsTest
    private static void takeWhileReturnsTheWholeListWhenThePredicateIsNeverFalse() {
        List<Object> result = (List<Object>) Evaluator.run('TAKEWHILE([1, 2, 3, 4], $current < 5)');
        Assert.areEqual(4, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
        Assert.areEqual(4, result[3]);
    }

    @IsTest
    private static void rangeFunctionReturnsAListOfNumbers() {
        List<Object> result = (List<Object>) Evaluator.run('RANGE(1, 3)');
        Assert.areEqual(3, result.size());
        Assert.areEqual(1, result[0]);
        Assert.areEqual(2, result[1]);
        Assert.areEqual(3, result[2]);
    }

    @IsTest
    private static void rangeThrowsAnExceptionWhenTheFirstArgumentIsNotANumber() {
        try {
            Evaluator.run('RANGE("a", 3)');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void rangeThrowsAnExceptionWhenTheSecondArgumentIsNotANumber() {
        try {
            Evaluator.run('RANGE(1, "a")');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void rangeReturnsAnEmptyListWhenTheFirstArgumentIsGreaterThanTheSecond() {
        List<Object> result = (List<Object>) Evaluator.run('RANGE(3, 1)');
        Assert.areEqual(0, result.size());
    }
}
