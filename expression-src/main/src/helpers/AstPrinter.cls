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

    public Object visit(Expr.StringLiteral literal) {
        // TODO: Improve once we implement interpolation
        String stringValue = '';
        for (Object current : literal.stringsAndInterpolations) {
            stringValue += (String)current;
        }
        return stringValue;
    }

    public Object visit(Expr.Variable variable) {
        return 'Variable(' + variable.name.lexeme + ')';
    }

    public Object visit(Expr.MergeField mergeField) {
        return 'MergeField(' + mergeField.name.lexeme + ')';
    }

    public Object visit(Expr.Unary unary) {
        return parenthesize(
            unary.operator.lexeme,
            new List<Expr>{
                unary.right
            }
        );
    }

    public Object visit(Expr.GetExpr getExpr) {
        return parenthesize(
            'GET:' + getExpr.field.lexeme,
            new List<Expr>{
                getExpr.objectExpr
            }
        );
    }

    public Object visit(Expr.FunctionCall function) {
        return parenthesize(
            'FN:' + function.functionName,
            function.arguments
        );
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        StringBuilder builder = new StringBuilder();
        builder.add('(').add('[');
        for (Expr expr : listLiteral.elements) {
            builder.add(' ');
            builder.add(objToString(expr.accept(this)));
        }
        builder.add(']').add(')');
        return builder.toString();
    }

    public Object visit(Expr.MapLiteral mapLiteral) {
        StringBuilder builder = new StringBuilder();
        builder.add('(').add('{');
        for (Object element: mapLiteral.elements) {
            builder.add(' ');
            if (element instanceof Expr.Spread) {
                builder.add(objToString(((Expr.Spread) element).accept(this)));
                continue;
            }

            Expr.KeyValue keyValue = (Expr.KeyValue) element;
            builder.add(objToString(keyValue.key.accept(this)));
            builder.add(': ');
            builder.add(objToString(keyValue.value.accept(this)));
        }
        builder.add('}').add(')');
        return builder.toString();
    }

    public Object visit(Expr.Spread spread) {
        return parenthesize(
            'SPREAD',
            new List<Expr>{
                spread.expression
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

    private static String objToString(Object obj) {
        if (obj == null) {
            return 'null';
        }

        if (obj instanceof Decimal) {
            // There seems to be an Apex bug that throws a Javalang exception
            // when trying to cast a generic Decimal object to a string, so if we encounter
            // a Decimal, we cast it first to a Decimal, then to a string.
            return String.valueOf((Decimal) obj);
        }

        return String.valueOf(obj.toString());
    }

    private with sharing class StringBuilder {
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
