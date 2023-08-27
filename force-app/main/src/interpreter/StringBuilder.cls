public with sharing class StringBuilder {
    private String str;
    private Integer index;

    public StringBuilder() {
        str = '';
        index = 0;
    }

    public StringBuilder add(String s) {
        str += s;
        index += s.length();
        return this;
    }

    public override String toString() {
        return str;
    }
}
