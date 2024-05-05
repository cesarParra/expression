/**
 * @description QOrGroup is used to build a SOQL WHERE clause with parenthetical groupings of logical OR operators
 * @author Fred Hays
 * @since 2020-02-04
 */
public class QOrGroup extends QConditionGroup {
    public QOrGroup() {
        super(QConditionGroup.Operator.OR_GROUP);
    }

    public QOrGroup(List<QICondition> conditions) {
        super(conditions, QConditionGroup.Operator.OR_GROUP);
    }
}
