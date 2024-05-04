/**
 * @description QCondition is used to build WHERE for SOQL statements
 * @author Jean-Philippe Monette
 * @since 2017-03-21
 */
public virtual class QCondition implements QICondition {
    public enum ComparisonOperator {
        EQUALS,
        NOT_EQUALS,
        LESS_THAN,
        LESS_OR_EQUAL,
        GREATER_THAN,
        GREATER_OR_EQUAL,
        IS_LIKE,
        IS_IN,
        NOT_IN,
        INCLUDES,
        EXCLUDES
    }

    public ComparisonOperator operatorValue;

    public final String field {
        get {
            return String.escapeSingleQuotes(field);
        }
        private set;
    }

    public Object fieldValue {
        get {
            return fieldValue;
        }
        private set {
            fieldValue = value;
        }
    }

    public QCondition(String field) {
        this.field = field;
    }

    public QCondition equalsTo(Object value) {
        this.operatorValue = ComparisonOperator.EQUALS;
        this.fieldValue = value;
        return this;
    }

    public QCondition notEqualsTo(Object value) {
        this.operatorValue = ComparisonOperator.NOT_EQUALS;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLessThan(Object value) {
        this.operatorValue = ComparisonOperator.LESS_THAN;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLessOrEquals(Object value) {
        this.operatorValue = ComparisonOperator.LESS_OR_EQUAL;
        this.fieldValue = value;
        return this;
    }

    public QCondition isGreaterThan(Object value) {
        this.operatorValue = ComparisonOperator.GREATER_THAN;
        this.fieldValue = value;
        return this;
    }

    public QCondition isGreaterOrEquals(Object value) {
        this.operatorValue = ComparisonOperator.GREATER_OR_EQUAL;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLike(String value) {
        this.operatorValue = ComparisonOperator.IS_LIKE;
        this.fieldValue = value;
        return this;
    }

    public QCondition isIn(List<Object> values) {
        this.operatorValue = ComparisonOperator.IS_IN;
        this.fieldValue = values;
        return this;
    }

    public QCondition isNotIn(List<Object> values) {
        this.operatorValue = ComparisonOperator.NOT_IN;
        this.fieldValue = values;
        return this;
    }

    public QCondition isNull() {
        this.operatorValue = ComparisonOperator.EQUALS;
        this.fieldValue = null;
        return this;
    }

    public QCondition isNotNull() {
        this.operatorValue = ComparisonOperator.NOT_EQUALS;
        this.fieldValue = null;
        return this;
    }
}
