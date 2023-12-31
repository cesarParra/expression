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

    private ComparisonOperator operatorValue;

    private final String field {
        private get {
            return String.escapeSingleQuotes(field);
        }
        private set;
    }

    private Object fieldValue {
        private get {
            return formatFieldValue(fieldValue);
        }
        private set {
            fieldValue = value;
        }
    }
    public QCondition(String field) {
        this.field = field;
    }

    protected virtual Object formatFieldValue(Object val) {
        if (val instanceof List<Object>) {
            List<String> values = new List<String>();
            for (Object value : (List<Object>) val) {
                if (value instanceof String) {
                    values.add('\'' + String.escapeSingleQuotes((String) value) + '\'');
                } else {
                    values.add((String) value);
                }
            }
            return String.join(values, ', ');
        }
        if (val instanceof String) {
            return '\'' + String.escapeSingleQuotes((String) val) + '\'';
        } else if (val instanceof Date) {
            String dateString = String.valueOf(val);
            return dateString.substring(0, dateString.indexOf(' '));
        } else if (val instanceof Datetime) {
            return ((Datetime) val).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        } else {
            return val;
        }
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

    public String build() {
        switch on operatorValue {
            when EQUALS {
                return field + ' = ' + fieldValue;
            }
            when NOT_EQUALS {
                return field + ' != ' + fieldValue;
            }
            when LESS_THAN {
                return field + ' < ' + fieldValue;
            }
            when LESS_OR_EQUAL {
                return field + ' <= ' + fieldValue;
            }
            when GREATER_THAN {
                return field + ' > ' + fieldValue;
            }
            when GREATER_OR_EQUAL {
                return field + ' >= ' + fieldValue;
            }
            when IS_LIKE {
                return field + ' LIKE ' + fieldValue;
            }
            when IS_IN {
                return field + ' IN (' + fieldValue + ')';
            }
            when NOT_IN {
                return field + ' NOT IN (' + fieldValue + ')';
            }
            when else {
                return '';
            }
        }
    }
}
