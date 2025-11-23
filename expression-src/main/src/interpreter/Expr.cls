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

        public Boolean equals(Object other) {
            if (other instanceof Logical) {
                Logical otherLogical = (Logical)other;
                return this.left == otherLogical.left
                    && this.operator == otherLogical.operator
                    && this.right == otherLogical.right;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(left);
            result = (31 * result) + System.hashCode(operator);
            result = (31 * result) + System.hashCode(right);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof Binary) {
                Binary otherBinary = (Binary)other;
                return this.left == otherBinary.left
                    && this.operator == otherBinary.operator
                    && this.right == otherBinary.right;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = left != null ? System.hashCode(left) : 0;
            result = (31 * result) + (operator != null ? System.hashCode(operator) : 0);
            result = (31 * result) + (right != null ? System.hashCode(right) : 0);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof Grouping) {
                Grouping otherGrouping = (Grouping)other;
                return this.expression == otherGrouping.expression;
            }
            return false;
        }

        public override Integer hashCode() {
            return System.hashCode(expression);
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

        public Boolean equals(Object other) {
            if (other instanceof FunctionCall) {
                FunctionCall otherFunctionCall = (FunctionCall)other;
                return this.functionToken == otherFunctionCall.functionToken
                    && this.arguments == otherFunctionCall.arguments;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(functionToken);
            result = (31 * result) + System.hashCode(arguments);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof Literal) {
                Literal otherLiteral = (Literal)other;
                return this.value == otherLiteral.value ||
                    (this.value != null && this.value.equals(otherLiteral.value));
            }
            return false;
        }

        public override Integer hashCode() {
            return value != null ? System.hashCode(value) : 0;
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

        public Boolean equals(Object other) {
            if (other instanceof StringLiteral) {
                StringLiteral otherLiteral = (StringLiteral)other;
                return this.stringsAndInterpolations == otherLiteral.stringsAndInterpolations ||
                    (this.stringsAndInterpolations != null && this.stringsAndInterpolations.equals(otherLiteral.stringsAndInterpolations));
            }
            return false;
        }

        public override Integer hashCode() {
            return System.hashCode(stringsAndInterpolations);
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

        public Boolean isContext(Set<String> contextReferenceNames) {
            String lowercasedLexeme = this.name.lexeme.toLowerCase();
            for (String contextReferenceName : contextReferenceNames) {
                if (lowercasedLexeme == contextReferenceName.toLowerCase()) {
                    return true;
                }
            }
            return false;
        }

        public Boolean equals(Object other) {
            if (other instanceof Variable) {
                Variable otherVariable = (Variable)other;
                return this.name == otherVariable.name && this.type == otherVariable.type;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(name);
            result = (31 * result) + System.hashCode(type);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof MergeFieldOrScopeVariable) {
                MergeFieldOrScopeVariable otherVariable = (MergeFieldOrScopeVariable)other;
                return this.name == otherVariable.name;
            }
            return false;
        }

        public override Integer hashCode() {
            return System.hashCode(name);
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

        public Boolean equals(Object other) {
            if (other instanceof GetExpr) {
                GetExpr otherGetExpr = (GetExpr)other;
                return this.objectExpr == otherGetExpr.objectExpr
                    && this.field == otherGetExpr.field
                    && this.arguments == otherGetExpr.arguments;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(objectExpr);
            result = (31 * result) + System.hashCode(field);
            result = (31 * result) + System.hashCode(arguments);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof Unary) {
                Unary otherUnary = (Unary)other;
                return this.operator == otherUnary.operator
                    && this.right == otherUnary.right;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(operator);
            result = (31 * result) + System.hashCode(right);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof ListLiteral) {
                ListLiteral otherListLiteral = (ListLiteral)other;
                return this.elements == otherListLiteral.elements ||
                    (this.elements != null && this.elements.equals(otherListLiteral.elements));
            }
            return false;
        }

        public override Integer hashCode() {
            return System.hashCode(elements);
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

        public Boolean equals(Object other) {
            if (other instanceof MapLiteral) {
                MapLiteral otherMapLiteral = (MapLiteral)other;
                return this.elements == otherMapLiteral.elements ||
                    (this.elements != null && this.elements.equals(otherMapLiteral.elements));
            }
            return false;
        }

        public override Integer hashCode() {
            return System.hashCode(elements);
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

        public Boolean equals(Object other) {
            if (other instanceof Spread) {
                Spread otherSpread = (Spread)other;
                return this.spreadToken == otherSpread.spreadToken
                    && this.expression == otherSpread.expression;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(spreadToken);
            result = (31 * result) + System.hashCode(expression);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof AddIfExpr) {
                AddIfExpr otherAddIf = (AddIfExpr)other;
                return this.ifToken == otherAddIf.ifToken
                    && this.condition == otherAddIf.condition
                    && this.body == otherAddIf.body
                    && this.valueExpr == otherAddIf.valueExpr;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(ifToken);
            result = (31 * result) + System.hashCode(condition);
            result = (31 * result) + System.hashCode(body);
            result = (31 * result) + System.hashCode(valueExpr);
            return result;
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

        public Boolean equals(Object other) {
            if (other instanceof Query) {
                Query otherQuery = (Query)other;
                return this.sObjectType == otherQuery.sObjectType
                    && this.fieldsExpression == otherQuery.fieldsExpression
                    && this.orderBy == otherQuery.orderBy
                    && this.limitExpr == otherQuery.limitExpr
                    && this.whereExpr == otherQuery.whereExpr
                    && this.offsetExpr == otherQuery.offsetExpr;
            }
            return false;
        }

        public override Integer hashCode() {
            Integer result = System.hashCode(sObjectType);
            result = (31 * result) + (fieldsExpression != null ? System.hashCode(fieldsExpression) : 0);
            result = (31 * result) + (orderBy != null ? System.hashCode(orderBy) : 0);
            result = (31 * result) + (limitExpr != null ? System.hashCode(limitExpr) : 0);
            result = (31 * result) + (whereExpr != null ? System.hashCode(whereExpr) : 0);
            result = (31 * result) + (offsetExpr != null ? System.hashCode(offsetExpr) : 0);
            return result;
        }
    }

    // TODO: Equals and hashCode
    public class PipelineFunction extends Expr {
        public final Token pipeToken;
        public final Expr left;
        public final Expr body;
        public Boolean hasInnerCapture = false;

        public PipelineFunction(Token pipeToken, Expr left, Expr body) {
            this.pipeToken = pipeToken;
            this.left = left;
            this.body = body;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }

        public PipelineFunction withInnerCapture(Boolean hasInnerCapture) {
            this.hasInnerCapture = hasInnerCapture;
            return this;
        }
    }

    // TODO: Equals and hashCode
    public class Capture extends Expr {
        public final Token captureToken;

        public Capture(Token captureToken) {
            this.captureToken = captureToken;
        }

        public override Object accept(Visitor v) {
            return v.visit(this);
        }
    }
}
