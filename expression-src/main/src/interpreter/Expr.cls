public abstract class Expr {
    public abstract Object accept(Visitor v);

    public class Logical extends Expr {
        public final Expr left;
        public final Token operator;
        public final Expr right;

        public Logical(Expr left, Token operator, Expr right) {
            this.left = left;
            this.operator = operator;
            this.right = right;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }

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

    public class FunctionDeclaration extends Expr implements IAritySupport {
        public final Token name;
        public final List<Token> parameters;
        public final Expr body;
        public final Boolean skipCache;
        private final Map<Environment, Object> cachedValueForEnvironment = new Map<Environment, Object>();

        public FunctionDeclaration(Token name, List<Token> parameters, Expr body, Boolean skipCache) {
            this.name = name;
            this.parameters = parameters;
            this.body = body;
            this.skipCache = skipCache;
        }

        public String functionName {
            get {
                return name.lexeme;
            }
        }

        public Boolean isAnonymous {
            get {
                return name == null;
            }
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }

        public Arity getArity() {
            return Arity.exactly(parameters.size());
        }

        public void cache(Environment env, Object cachedValue) {
            if (skipCache) {
                return;
            }
            cachedValueForEnvironment.put(env, cachedValue);
        }

        public Boolean isCachedForEnvironment(Environment env) {
            if (skipCache) {
                return false;
            }
            return cachedValueForEnvironment.containsKey(env);
        }

        public Object getCachedValueForEnvironment(Environment env) {
            if (skipCache) {
                return null;
            }
            return cachedValueForEnvironment.get(env);
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
        GLOBAL_CONTEXT, // Represented with at sign (@)
        LOCAL // Represented with dollar ($)
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

        public Boolean isContext(String contextReferenceName) {
            return this.name.lexeme.toLowerCase() == contextReferenceName.toLowerCase();
        }
    }

    public class MergeFieldOrScopeVariable extends Expr {
        public final Token name;

        public MergeFieldOrScopeVariable(Token name) {
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

    public class AddIfExpr extends Expr {
        public final Token ifToken;
        public final Expr condition;
        public final Expr body;
        // When dealing with a key:value pair, the valueExpr will be the value
        // If we are dealing with a regular element (within a list), this will be null.
        public final Expr valueExpr;

        public AddIfExpr(Token ifToken, Expr condition, Expr body, Expr valueExpr) {
            this.ifToken = ifToken;
            this.condition = condition;
            this.body = body;
            this.valueExpr = valueExpr;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }

        public Boolean isForKeyValuePair() {
            return valueExpr != null;
        }
    }

    public class Query extends Expr {
        public final Token sObjectType;
        // Fields is an expression that must evaluate to a list
        public final Expr fieldsExpression;
        public final List<Expr> orderBy;
        public final Expr limitExpr;
        public final Expr whereExpr;
        public final Expr offsetExpr;

        public Query(Token sObjectType, Expr fieldsExpression, List<Expr> orderBy, Expr limitExpr, Expr whereExpr, Expr offsetExpr) {
            this.sObjectType = sObjectType;
            this.fieldsExpression = fieldsExpression;
            if (orderBy != null) {
                this.orderBy = orderBy;
            } else {
                this.orderBy = new List<Expr>();
            }
            this.limitExpr = limitExpr;
            this.whereExpr = whereExpr;
            this.offsetExpr = offsetExpr;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }
}
