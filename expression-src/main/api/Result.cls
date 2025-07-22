/**
 * @description Represents the result of a bulk evaluation.
 */
global with sharing class Result {
    private final Object value;

    /**
     * @description Creates a new Result instance with the specified value.
     * @param value The value of the result.
     */
    public Result(Object value) {
        this.value = value;
    }

    /**
     * @description Gets the evaluated value of the Result.
     * @return The evaluated value of the Result.
     */
    global Object getValue() {
        return value;
    }
}
