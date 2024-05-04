/**
 * @description QConditionGroup is an abstract class extended by QAandGroup and QOrGroup to build parenthetical groupings
 * @author Fred Hays
 * @since 2020-02-04
 */
public abstract class QConditionGroup implements QICondition {
    public enum Operator {
        AND_GROUP, OR_GROUP
    }

    public List<QICondition> conditions { get; set; }

    public Operator operator;

    public QConditionGroup(Operator op) {
        this(new List<QICondition>(), op);
    }

    public QConditionGroup(List<QICondition> conditions, Operator op) {
        this.conditions = conditions;
        this.operator = op;
    }

    public QConditionGroup add(QICondition condition) {
        this.conditions.add(condition);
        return this;
    }
}
