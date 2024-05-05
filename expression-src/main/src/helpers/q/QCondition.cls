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
        NOT_IN
    }

    public ComparisonOperator OperatorValue { get; private set; }

    public final String Field {
        get {
            return String.escapeSingleQuotes(Field);
        }
        private set;
    }

    public Object FieldValue {
        get {
            return FieldValue;
        }
        private set {
            FieldValue = value;
        }
    }

    public QCondition(String Field) {
        this.Field = Field;
    }

    public QCondition equalsTo(Object value) {
        this.OperatorValue = ComparisonOperator.EQUALS;
        this.FieldValue = value;
        return this;
    }

    public QCondition notEqualsTo(Object value) {
        this.OperatorValue = ComparisonOperator.NOT_EQUALS;
        this.FieldValue = value;
        return this;
    }

    public QCondition isLessThan(Object value) {
        this.OperatorValue = ComparisonOperator.LESS_THAN;
        this.FieldValue = value;
        return this;
    }

    public QCondition isLessOrEquals(Object value) {
        this.OperatorValue = ComparisonOperator.LESS_OR_EQUAL;
        this.FieldValue = value;
        return this;
    }

    public QCondition isGreaterThan(Object value) {
        this.OperatorValue = ComparisonOperator.GREATER_THAN;
        this.FieldValue = value;
        return this;
    }

    public QCondition isGreaterOrEquals(Object value) {
        this.OperatorValue = ComparisonOperator.GREATER_OR_EQUAL;
        this.FieldValue = value;
        return this;
    }

    public QCondition isLike(String value) {
        this.OperatorValue = ComparisonOperator.IS_LIKE;
        this.FieldValue = value;
        return this;
    }

    public QCondition isIn(List<Object> values) {
        this.OperatorValue = ComparisonOperator.IS_IN;
        this.FieldValue = values;
        return this;
    }

    public QCondition isNotIn(List<Object> values) {
        this.OperatorValue = ComparisonOperator.NOT_IN;
        this.FieldValue = values;
        return this;
    }

    public QCondition isNull() {
        this.OperatorValue = ComparisonOperator.EQUALS;
        this.FieldValue = null;
        return this;
    }

    public QCondition isNotNull() {
        this.OperatorValue = ComparisonOperator.NOT_EQUALS;
        this.FieldValue = null;
        return this;
    }
}
