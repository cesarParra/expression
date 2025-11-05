public with sharing class CollectionUtils {
    public static List<Object> toObjectList(Iterable<Object> values) {
        List<Object> objects = new List<Object>();
        for (Object s : values) {
            objects.add(s);
        }
        return objects;
    }

    public static Boolean containsAllIgnoreCase(Set<String> source, Set<String> toCheck) {
        Set<String> lowerSource = new Set<String>();
        for (String s : source) {
            lowerSource.add(s.toLowerCase());
        }
        for (String to : toCheck) {
            if (!lowerSource.contains(to.toLowerCase())) {
                return false;
            }
        }
        return true;
    }
}
