/**
 * @description QConditionGroup is an abstract class extended by QAandGroup and QOrGroup to build parenthetical groupings
 * @author Fred Hays
 * @since 2020-02-04
 */
public abstract class QConditionGroup implements QICondition {

    public List<QICondition> conditions { get; set; }

    public String operator;

    public QConditionGroup(String operator) {
        this(new List<QICondition>(), operator);
    }

    public QConditionGroup(List<QICondition> conditions, String operator) {
        this.conditions = conditions;
        this.operator = operator;
    }

    public QConditionGroup add(QICondition condition) {
        this.conditions.add(condition);
        return this;
    }
}
