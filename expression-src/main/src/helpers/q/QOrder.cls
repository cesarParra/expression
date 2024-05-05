/**
 * @description QOrder is used to build ORDER BY for SOQL statements
 * @author Jean-Philippe Monette
 */
public class QOrder {
    public enum SortOrder { ASCENDING, DESCENDING }
    public enum NullsOrder { FIRST, LAST }

    public final String Field { get; private set; }
    public SortOrder SortValue { get; private set; }
    public NullsOrder NullsOrderValue { get; private set; }

    public QOrder(String Field) {
        this.Field = Field;
        this.SortValue = SortOrder.ASCENDING;
    }

    public QOrder withDirection(SortOrder direction) {
        this.SortValue = direction;
        return this;
    }

    public QOrder ascending() {
        this.SortValue = SortOrder.ASCENDING;
        return this;
    }

    public QOrder descending() {
        this.SortValue = SortOrder.DESCENDING;
        return this;
    }

    public QOrder nullsFirst() {
        this.NullsOrderValue = NullsOrder.FIRST;
        return this;
    }

    public QOrder nullsLast() {
        this.NullsOrderValue = NullsOrder.LAST;
        return this;
    }
}
