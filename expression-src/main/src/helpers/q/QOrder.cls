/**
 * @description QOrder is used to build ORDER BY for SOQL statements
 * @author Jean-Philippe Monette
 * @since 2017-03-31
 */
public class QOrder {

    public enum SortOrder {
        ASCENDING, DESCENDING
    }
    public enum NullsOrder {
        FIRST, LAST
    }

    public final String field;
    public SortOrder sortValue;
    public NullsOrder nullsValue;

    public QOrder(String field) {
        this.field = field;
        this.sortValue = SortOrder.ASCENDING;
    }

    public QOrder withDirection(SortOrder direction) {
        this.sortValue = direction;
        return this;
    }

    public QOrder ascending() {
        this.sortValue = SortOrder.ASCENDING;
        return this;
    }

    public QOrder descending() {
        this.sortValue = SortOrder.DESCENDING;
        return this;
    }

    public QOrder nullsFirst() {
        this.nullsValue = NullsOrder.FIRST;
        return this;
    }

    public QOrder nullsLast() {
        this.nullsValue = NullsOrder.LAST;
        return this;
    }
}
