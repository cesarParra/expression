public with sharing class Q {
    private final String fromText;
    private final Set<String> fieldList = new Set<String>();
    private final List<QICondition> conditions = new List<QICondition>();
    private final List<Q> subQueries = new List<Q>();

    public Q(SObjectType fromType) {
        this.fromText = String.valueOf(fromType);
    }

    public Q(String fromText) {
        this.fromText = fromText;
    }

    public static QCondition condition(String fieldName) {
        QCondition cond = new QCondition(fieldName);
        return cond;
    }

    public Q add(QICondition cnd) {
        this.conditions.add(cnd);
        return this;
    }

    public Q addSubquery(Q qb) {
        this.subQueries.add(qb);
        return this;
    }

    public Q selectField(String field) {
        this.fieldList.add(field.toLowerCase());
        return this;
    }

    public Q selectFields(Set<String> fields) {
        for (String field : fields) {
            this.fieldList.add(field.toLowerCase());
        }
        return this;
    }

    public Set<String> getFields() {
        return this.fieldList;
    }

    public String buildSelect() {
        for (Q qb : this.subQueries) {
            this.fieldList.add('(' + qb.build() + ')');
        }

        if (!this.fieldList.isEmpty()) {
            return 'SELECT ' + String.join(new List<String>(this.fieldList), ', ');
        } else {
            return 'SELECT Id';
        }
    }

    public String buildConditions() {
        List<String> condList = new List<String>();

        for (QICondition cond : this.conditions) {
            condList.add(cond.build());
        }

        if (!this.conditions.isEmpty()) {
            return 'WHERE ' + String.join(condList, ' AND ');
        } else {
            return null;
        }
    }

    public String build() {
        List<String> queryParts = new List<String>();

        queryParts.add(this.buildSelect());
        queryParts.addAll(buildQueryConditions());

        return String.join(queryParts, ' ');
    }

    private List<String> buildQueryConditions() {
        List<String> queryParts = new List<String>{ 'FROM ' + this.fromText };

        if (!this.conditions.isEmpty()) {
            queryParts.add(this.buildConditions());
        }

        return queryParts;
    }

    public interface QICondition {
        String build();
    }

    public enum ComparisonOperator {
        EQUALS
    }

    public virtual class QCondition implements QICondition {
        private ComparisonOperator operatorValue;

        private String field {
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
            if (val instanceof String) {
                return '\'' + String.escapeSingleQuotes((String) val) + '\'';
            } else {
                return val;
            }
        }

        public QCondition equalsTo(Object value) {
            this.operatorValue = ComparisonOperator.EQUALS;
            this.fieldValue = value;
            return this;
        }

        public String build() {
            switch on operatorValue {
                when EQUALS {
                    return field + ' = ' + fieldValue;
                }
                when else {
                    return '';
                }
            }
        }
    }
}
