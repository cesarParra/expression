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

    public class Function extends Expr {
        public final String functionName;
        public final List<Expr> arguments;

        public Function(String functionName, List<Expr> arguments) {
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
        public final Token name;

        public GetExpr(Expr objectExpr, Token name) {
            this.objectExpr = objectExpr;
            this.name = name;
        }

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
}
