public interface Visitor {
    Object visit(Expr.Binary binary);
    Object visit(Expr.Grouping grouping);
    Object visit(Expr.Literal literal);
    Object visit(Expr.Unary unary);
    Object visit(Expr.Function function);
    Object visit(Expr.GetExpr getExpr);
    Object visit(Expr.MergeField mergeField);
    Object visit(Expr.ListLiteral listLiteral);
    Object visit(Expr.MapLiteral mapLiteral);
    Object visit(Expr.Spread spread);
}
