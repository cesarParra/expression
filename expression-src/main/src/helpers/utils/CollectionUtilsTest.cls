@IsTest
private class CollectionUtilsTest {
    @IsTest
    static void canConvertAnyIterableToAListOfObjects() {
        Set<String> testSet = new Set<String>{
            'a', 'b', 'c'
        };

        List<Object> convertedList = CollectionUtils.toObjectList(testSet);

        Assert.areEqual(3, convertedList.size());
        Assert.isTrue(convertedList.contains('a'));
        Assert.isTrue(convertedList.contains('b'));
        Assert.isTrue(convertedList.contains('c'));
    }
}
