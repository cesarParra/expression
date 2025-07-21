global with sharing class Result {
    private final Object value;

    public Result(Object value) {
        this.value = value;
    }

    global Object getValue() {
        return value;
    }
}
