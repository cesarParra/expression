public virtual with sharing class Arity {
    private final Integer min;
    private final Integer max;

    protected Arity(Integer min, Integer max) {
        this.min = min;
        this.max = max;
    }

    public static Arity between(Integer min, Integer max) {
        return new Arity(min, max);
    }

    public static Arity exactly(Integer n) {
        return new Arity(n, n);
    }

    public static Arity atLeast(Integer n) {
        return new Arity(n, null);
    }

    public virtual Boolean isSatisfiedBy(Integer n) {
        return (min == null || n >= min) && (max == null || n <= max);
    }

    public override virtual String toString() {
        if (min == null && max == null) {
            return 'any number of';
        } else if (min == null) {
            return 'at most ' + max;
        } else if (max == null) {
            return 'at least ' + min;
        } else if (min == max) {
            return 'exactly ' + min;
        } else {
            return 'between ' + min + ' and ' + max;
        }
    }
}
