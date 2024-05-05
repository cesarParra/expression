/**
 * @description Q is used to build SOQL statements
 * @author Jean-Philippe Monette
 */
public class Q {
    public final String FromText { get; private set; }
    public Integer NumberOfRowsToQuery { get; private set; }
    public Integer NumberOfRowsToSkip { get; private set; }

    public final Set<String> fieldList = new Set<String>();
    public final List<QOrder> orders = new List<QOrder>();
    public final List<QICondition> conditions = new List<QICondition>();
    public final List<Q> subQueries = new List<Q>();

    public Q(SObjectType fromType) {
        this.FromText = String.valueOf(fromType);
    }

    public Q(String FromText) {
        this.FromText = FromText;
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
        this.NumberOfRowsToQuery = i;
        return this;
    }

    public Q addOffset(Integer i) {
        this.NumberOfRowsToSkip = i;
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
}
