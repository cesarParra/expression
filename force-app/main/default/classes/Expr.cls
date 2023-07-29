public abstract class Expr {
    public abstract Object accept(Visitor v);

    public class Binary extends Expr {
        final Expr left;
        final Token operator;
        final Expr right;

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
        final Expr expression;

        public Grouping(Expr expression) {
            this.expression = expression;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Literal extends Expr {
        final Object value;

        public Literal(Object value) {
            this.value = value;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Unary extends Expr {
        final Token operator;
        final Expr right;

        public Unary(Token operator, Expr right) {
            this.operator = operator;
            this.right = right;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }
}
