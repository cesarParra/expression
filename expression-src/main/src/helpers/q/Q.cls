/**
 * @description Q is used to build SOQL statements
 * @author Jean-Philippe Monette
 * @since 2017-03-21
 */
public class Q {
    private final String fromText;
    private Integer numberOfRows;
    private Integer numberOfRowsToSkip;

    private final Set<String> fieldList = new Set<String>();
    private final List<QOrder> orders = new List<QOrder>();
    private final List<QICondition> conditions = new List<QICondition>();
    private final List<Q> subQueries = new List<Q>();

    public Q(SObjectType fromType) {
        this.fromText = String.valueOf(fromType);
    }
    public Q(String fromText) {
        this.fromText = fromText;
    }


    public static QOrder orderBy(String fieldName) {
        QOrder od = new QOrder(fieldName);
        return od;
    }

    public static QCondition condition(String fieldName) {
        QCondition cond = new QCondition(fieldName);
        return cond;
    }

    public Q add(QOrder ob) {
        this.orders.add(ob);
        return this;
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
            this.fieldList.add(field);
        }
        return this;
    }

    public Q addLimit(Integer i) {
        this.numberOfRows = i;
        return this;
    }

    public Q addOffset(Integer i) {
        this.numberOfRowsToSkip = i;
        return this;
    }

    public static QConditionGroup orGroup() {
        QOrGroup orGroup = new QOrGroup();
        return orGroup;
    }

    public static QConditionGroup andGroup() {
        QAndGroup andGroup = new QAndGroup();
        return andGroup;
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

    public String buildOrderBy() {
        List<String> orderList = new List<String>();

        for (QOrder order : this.orders) {
            orderList.add(order.build());
        }

        if (!this.orders.isEmpty()) {
            return 'ORDER BY ' + String.join(orderList, ', ');
        } else {
            return '';
        }

    }

    public String build() {
        List<String> queryParts = new List<String>();

        queryParts.add(this.buildSelect());
        queryParts.add('FROM ' + this.fromText);

        if (!this.conditions.isEmpty()) {
            queryParts.add(this.buildConditions());
        }

        if (!this.orders.isEmpty()) {
            queryParts.add(this.buildOrderBy());
        }

        if (this.numberOfRows != null) {
            queryParts.add('LIMIT ' + this.numberOfRows);
        }

        if (this.numberOfRowsToSkip != null) {
            queryParts.add('OFFSET ' + this.numberOfRowsToSkip);
        }

        return String.join(queryParts, ' ');
    }
}
