public with sharing class CollectionUtils {
    public static List<Object> toObjectList(Iterable<Object> values) {
        List<Object> objects = new List<Object>();
        for (Object s : values) {
            objects.add(s);
        }
        return objects;
    }
}
