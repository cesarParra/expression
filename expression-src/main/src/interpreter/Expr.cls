public abstract class Expr {
    public abstract Object accept(Visitor v);

    public class Binary extends Expr {
        public final Expr left;
        public final Token operator;
        public final Expr right;

        public Binary(Expr left, Token operator, Expr right) {
            this.left = left;
            this.operator = operator;
            this.right = right;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Grouping extends Expr {
        public final Expr expression;

        public Grouping(Expr expression) {
            this.expression = expression;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class FunctionCall extends Expr {
        public final String functionName;
        public final List<Expr> arguments;

        public FunctionCall(String functionName, List<Expr> arguments) {
            this.functionName = functionName;
            this.arguments = arguments;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Literal extends Expr {
        public final Object value;

        public Literal(Object value) {
            this.value = value;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Variable extends Expr {
        public final Token name;

        public Variable(Token name) {
            this.name = name;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class MergeField extends Expr {
        public final Token name;

        public MergeField(Token name) {
            this.name = name;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class GetExpr extends Expr {
        public final Expr objectExpr;
        public final Token field;
        public final List<Expr> arguments;

        public GetExpr(Expr objectExpr, Token field, List<Expr> arguments) {
            this.objectExpr = objectExpr;
            this.field = field;
            this.arguments = arguments;
        }

//        public GetExpr(Expr objectExpr, Token field) {
//            this.objectExpr = objectExpr;
//            this.field = field;
//            this.arguments = new List<Expr>();
//        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Unary extends Expr {
        public final Token operator;
        public final Expr right;

        public Unary(Token operator, Expr right) {
            this.operator = operator;
            this.right = right;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class ListLiteral extends Expr {
        public final List<Expr> elements;

        public ListLiteral(List<Expr> elements) {
            this.elements = elements;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class KeyValue {
        public final Expr key;
        public final Expr value;

        public KeyValue(Expr key, Expr value) {
            this.key = key;
            this.value = value;
        }
    }

    public class MapLiteral extends Expr {
        // Elements should either be KeyValue or Spread
        public final List<Object> elements;

        public MapLiteral(List<Object> elements) {
            this.elements = elements;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Spread extends Expr {
        public final Expr expression;

        public Spread(Expr expression) {
            this.expression = expression;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }
}
