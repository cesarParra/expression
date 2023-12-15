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
        public final Token functionToken;
        public final List<Expr> arguments;

        public FunctionCall(Token functionToken, List<Expr> arguments) {
            this.functionToken = functionToken;
            this.arguments = arguments;
        }

        public String functionName {
            get {
                return functionToken.lexeme.toUpperCase();
            }
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

    public class StringLiteral extends Expr {
        // The objects will always either be a string or an inner expression when
        // dealing with a string interpolation.
        public final List<Object> stringsAndInterpolations;

        public StringLiteral(List<Object> stringsAndInterpolations) {
            this.stringsAndInterpolations = stringsAndInterpolations;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public enum VariableType {
        GLOBAL_CONTEXT,
        LOCAL
    }

    public class Variable extends Expr {
        public final Token name;
        public final VariableType type;

        public Variable(Token name, VariableType type) {
            this.name = name;
            this.type = type;
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
        public final Token spreadToken;
        public final Expr expression;

        public Spread(Token spreadToken, Expr expression) {
            this.spreadToken = spreadToken;
            this.expression = expression;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

    public class Query extends Expr {
        public final Token sObjectType;
        public final List<String> fields;
        public final Expr orderBy;

        public Query(Token sObjectType, List<String> fields, Expr orderBy) {
            this.sObjectType = sObjectType;
            this.fields = fields;
            this.orderBy = orderBy;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }
}
