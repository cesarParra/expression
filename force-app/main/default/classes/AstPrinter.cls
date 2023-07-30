public with sharing class AstPrinter implements Visitor {
    public void printAst(Expr expr) {
        Object toPrint = expr.accept(this);
        System.debug(toPrint);
    }

    public Object visit(Expr.Binary binary) {
        return parenthesize(
                binary.operator.lexeme,
                new List<Expr>{
                        binary.left,
                        binary.right
                }
        );
    }

    public Object visit(Expr.Grouping grouping) {
        return parenthesize('group', new List<Expr>{
                grouping.expression
        });
    }

    public Object visit(Expr.Literal literal) {
        return literal.value;
    }

    public Object visit(Expr.Unary unary) {
        return parenthesize(
                unary.operator.lexeme,
                new List<Expr>{
                        unary.right
                }
        );
    }

    private String parenthesize(String str, List<Expr> exprs) {
        StringBuilder builder = new StringBuilder();
        builder.add('(').add(str);
        for (Expr expr : exprs) {
            builder.add(' ');
            builder.add(objToString(expr.accept(this)));
        }
        builder.add(')');
        return builder.toString();
    }

    private String objToString(Object obj) {
        if (obj == null) {
            return 'null';
        }

        if (obj instanceof Decimal) {
            // There seems to be an Apex bug that throws a Javalang exception
            // when trying to cast a generic Decimal object to a string, so if we encounter
            // a Decimal, we cast it first to a Decimal, then to a string.
            return String.valueOf((Decimal)obj);
        }

        return String.valueOf(obj.toString());
    }

    private class StringBuilder {
        private String str;
        private Integer index;

        public StringBuilder() {
            str = '';
            index = 0;
        }

        public StringBuilder add(String s) {
            str += s;
            index += s.length();
            return this;
        }

        public override String toString() {
            return str;
        }
    }
}
