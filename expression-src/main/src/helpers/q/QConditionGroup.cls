/**
 * @description QConditionGroup is an abstract class extended by QAandGroup and QOrGroup to build parenthetical groupings
 * @author Fred Hays
 * @since 2020-02-04
 */
public abstract class QConditionGroup implements QICondition {
    public enum Operator {
        AND_GROUP, OR_GROUP
    }

    public List<QICondition> Conditions { get; protected set; }

    public Operator Operator { get; protected set; }

    public QConditionGroup(Operator op) {
        this(new List<QICondition>(), op);
    }

    public QConditionGroup(List<QICondition> Conditions, Operator op) {
        this.Conditions = Conditions;
        this.Operator = op;
    }

    public QConditionGroup add(QICondition condition) {
        this.Conditions.add(condition);
        return this;
    }
}
