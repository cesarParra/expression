public interface IInterpreter extends Visitor {
    Object interpret(Expr expr);
}
