public with sharing class ContextResolver implements Visitor {
    private Boolean shouldExecuteQuery = false;
    private Query queryContext;

    private final List<Expr.FunctionDeclaration> customFunctionDeclarations;
    private final Query topLevelQuery;
    private final List<Query> subQueries = new List<Query>();

    public ContextResolver(Id recordId, List<Expr.FunctionDeclaration> customFunctionDeclarations) {
        this.queryContext = new Query(recordId);
        this.topLevelQuery = this.queryContext;
        this.customFunctionDeclarations = customFunctionDeclarations;
    }

    public ContextResolver(Set<Id> recordIds, List<Expr.FunctionDeclaration> customFunctionDeclarations) {
        this.queryContext = new Query(recordIds);
        this.topLevelQuery = this.queryContext;
        this.customFunctionDeclarations = customFunctionDeclarations;
    }

    private Object resolve(Expr expr) {
        return expr.accept(this);
    }

    /**
     * @description Resolves an expression for record field references without building the query
     * @param expression The expression to analyze
     * @return Object The result of the visitor
     */
    public Object resolveForRecord(Expr expression) {
        return this.resolve(expression);
    }

    /**
     * @description Checks if the query should be executed based on whether any fields were added to the query
     * @return Boolean True if the query should be executed, false otherwise
     */
    public Boolean shouldExecuteQuery() {
        return this.shouldExecuteQuery;
    }

    /**
     * @description Gets the current query context
     * @return Query The current query context
     */
    public Query getQueryContext() {
        return this.queryContext;
    }

    /**
     * @description Gets the list of subqueries that were added during expression resolution
     * @return List<Query> The list of subqueries
     */
    public List<Query> getSubQueries() {
        return this.subQueries;
    }

    public List<SObject> build(List<Expr> expressions) {
        for (Expr currentExpression : expressions) {
            this.resolve(currentExpression);
        }

        if (!this.shouldExecuteQuery) {
            return null;
        }

        for (Query subquery : this.subQueries) {
            this.queryContext.queryBuilder.addSubquery(subquery.queryBuilder);
        }

        this.queryContext.queryBuilder.add(Q.condition('Id').isIn(new List<Id>(this.queryContext.recordId.getIds())));
        List<SObject> results = QDB.getInstance().run(this.queryContext.queryBuilder);
        if (results.isEmpty()) {
            return null;
        }
        return results;
    }

    public Object visit(Expr.Logical logical) {
        resolve(logical.left);
        resolve(logical.right);
        return null;
    }

    public Object visit(Expr.Binary binary) {
        resolve(binary.left);
        resolve(binary.right);
        return null;
    }

    public Object visit(Expr.Grouping grouping) {
        resolve(grouping.expression);
        return null;
    }

    public Object visit(Expr.Literal literal) {
        return null;
    }

    public Object visit(Expr.StringLiteral literal) {
        for (Object obj : literal.stringsAndInterpolations) {
            if (obj instanceof Expr) {
                resolve((Expr)obj);
            }
        }
        return null;
    }

    public Object visit(Expr.Unary unary) {
        resolve(unary.right);
        return null;
    }

    private final Set<String> ignoredScopedVariables = new Set<String>();
    public Object visit(Expr.FunctionCall function) {
        // See if the function can be found in the custom function declarations
        for (Expr.FunctionDeclaration customFunction : this.customFunctionDeclarations) {
            if (customFunction.name.lexeme.toLowerCase() == function.functionName.toLowerCase()) {
                // Resolve arguments
                for (Integer i = 0; i < function.arguments.size(); i++) {
                    resolve(function.arguments[i]);
                }

                // Resolve the function body
                // Declared functions have their own scope, so we need to ignore the variables declared in the function
                // since these will be passed from outside, and we don't want to resolve them as part of the query.
                for (Token functionScopeVariableToken : customFunction.parameters) {
                    ignoredScopedVariables.add(functionScopeVariableToken.lexeme.toLowerCase());
                }
                resolve(customFunction.body);
                for (Token functionScopeVariableToken : customFunction.parameters) {
                    ignoredScopedVariables.remove(functionScopeVariableToken.lexeme.toLowerCase());
                }

                return null;
            }
        }

        // Otherwise, try and resolve the standard function
        StandardFunction fn = StandardFunction.getByName(function.functionName);
        if (fn != null) {
            // Whenever children resolution is needed we assume that the second argument contains the expression
            // for which to resolve, so skip this when the argument list is not long enough.
            if (fn.needsQueryArgumentResolution()) {
                // We want to first resolve the left side and it should resolve to a Query object
                // which we will use as the context for the right side.

                Query previousContext = this.queryContext;
                Object result = resolve(function.arguments[0]);
                if (!(result instanceof Query)) {
                    return null;
                }

                this.queryContext = (Query)result;
                resolve(function.arguments[1]);
                this.queryContext = previousContext;

                // If there are more arguments, resolve normally for the top level query
                if (function.arguments.size() > 2) {
                    for (Integer i = 2; i < function.arguments.size(); i++) {
                        resolve(function.arguments[i]);
                    }
                }

                return result;
            } else {
                for (Expr argument : function.arguments) {
                    resolve(argument);
                }
                return null;
            }
        }

        // See if the function exists as a Custom Metadata function
        IExpressionFunction customMetadataFunction = CustomFunctionRepository.getInstance().getByName(function.functionName);
        if (customMetadataFunction != null) {
            // Resolve arguments
            for (Expr argument : function.arguments) {
                resolve(argument);
            }
        }

        return null;
    }

    public Object visit(Expr.GetExpr getExpr) {
        try {
            String referenceName = this.resolveExtractReferenceOutOfGetExpression(getExpr);

            if (isReferencingContextField(getExpr)) {
                // References to @Context fields will always go to the top level query
                // as they are part of the global contextual context tied to the record Id
                // from which the Evaluation was started.
                addFieldToQuery(this.topLevelQuery, referenceName.toLowerCase());
            } else {
                this.queryContext.queryBuilder.selectField(referenceName);
            }

            this.shouldExecuteQuery = true;
            return null;
        } catch (NotSupportedGetResolutionException e) {
            return null;
        }
    }

    private String resolveExtractReferenceOutOfGetExpression(Expr.GetExpr getExpr) {
        // Get the relationship field to query out of the get/merge field contained.
        String relationshipToQuery = '';
        if ((getExpr.objectExpr instanceof Expr.MergeFieldOrScopeVariable)) {
            relationshipToQuery += ((Expr.MergeFieldOrScopeVariable)getExpr.objectExpr).name.lexeme + '.';
        } else if ((getExpr.objectExpr instanceof Expr.GetExpr)) {
            relationshipToQuery += (String)this.resolveExtractReferenceOutOfGetExpression((Expr.GetExpr)getExpr.objectExpr) + '.';
        } else if (isReferencingContextField(getExpr)) {
            return getExpr.field.lexeme;
        } else {
            // If we are doing a "get" expression on anything that is not either a merge field,
            // another inner get expression, or an @Context reference, we don't know how to resolve it, so we shouldn't
            // end up adding it to the query
            throw new NotSupportedGetResolutionException();
        }

        return relationshipToQuery + getExpr.field.lexeme;
    }

    private static Boolean isReferencingContextField(Expr.GetExpr expr) {
        if (expr.objectExpr instanceof Expr.Variable) {
            return ((Expr.Variable)expr.objectExpr).isContext();
        } else if (expr.objectExpr instanceof Expr.GetExpr) {
            // Recursively check if the parent object is referencing a context field
            // since we can have nested get expressions and what is important is the top level
            // object that is being referenced.
            return isReferencingContextField((Expr.GetExpr)expr.objectExpr);
        }
        return false;
    }

    public Object visit(Expr.Variable variable) {
        if (variable.isContext()) {
            // If context is being accessed, then we always want to run the query.
            this.shouldExecuteQuery = true;

            // recordId migh be null when this is being run from within a subquery.
            // If so, return early.
            if (this.queryContext.recordId == null) {
                return null;
            }

            // When dealing with multiple record Ids and accessing the @Context, then we return
            // the top level query, so that we can take advantage of functions that resolve for children,
            // but instead of resolving a subquery, it can just resolve the top level query and add
            // fields to the main query itself.
            if (this.queryContext.recordId.isComposite()) {
                return topLevelQuery;
            } else {
                return null;
            }
        }

        return null;
    }

    public Object visit(Expr.MergeFieldOrScopeVariable mergeField) {
        String fieldName = mergeField.name.lexeme.toLowerCase();
        // Check if it is ignored within a function scope
        if (ignoredScopedVariables.contains(fieldName)) {
            return null;
        }
        return addFieldToQuery(this.queryContext, fieldName);
    }

    private Object addFieldToQuery(Query queryContext, String fieldName) {
        if (fieldName.contains('.')) {
            // If we are dealing with a relationship query, we will assume that the field
            // might exist, and if it doesn't then we let it bomb when the query is tried to be executed.
            queryContext.queryBuilder.selectField(fieldName);
            this.shouldExecuteQuery = true;
            return null;
        }

        // Check if the field belongs to the parent object
        Field potentialField = this.getFields().get(fieldName);
        if (potentialField != null) {
            if (potentialField.isRelationship) {
                queryContext.queryBuilder.selectField(fieldName + '.Id');
            } else {
                queryContext.queryBuilder.selectField(fieldName);
            }

            this.shouldExecuteQuery = true;
            return null;
        }

        // Check if the merge field is a child relationship field
        for (ChildRelationship relationship : queryContext.objectType.getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == fieldName) {
                // We have a child relationship, so we want to start building a subquery
                Query subQuery = this.getSubqueryFor(childRelationshipName);
                if (subQuery == null) {
                    subQuery = new Query(relationship.getChildSObject(), childRelationshipName);
                    this.subQueries.add(subQuery);
                }

                this.shouldExecuteQuery = true;
                return subQuery;
            }
        }

        throw new ResolverException('Did not understand the relationship to field "' +
            fieldName + '" for SObjectType ' + queryContext.objectType);
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        for (Expr element : listLiteral.elements) {
            resolve(element);
        }
        return null;
    }

    public Object visit(Expr.MapLiteral mapLiteral) {
        for (Object element : mapLiteral.elements) {
            if (element instanceof Expr.Spread) {
                this.resolve(((Expr.Spread)element).expression);
                continue;
            }

            Expr.KeyValue keyValue = (Expr.KeyValue)element;
            this.resolve(keyValue.key);
            this.resolve(keyValue.value);
        }
        return null;
    }

    public Object visit(Expr.Spread spread) {
        this.resolve(spread.expression);
        return null;
    }

    public Object visit(Expr.FunctionDeclaration functionDeclaration) {
        this.resolve(functionDeclaration.body);
        return null;
    }

    public Object visit(Expr.Query query) {
        // Nothing to resolve when inside of a Query expression.
        // A query expression essentially starts an isolated context.
        return null;
    }

    public Object visit(Expr.AddIfExpr ifExpr) {
        resolve(ifExpr.condition);
        resolve(ifExpr.body);
        if (ifExpr.valueExpr != null) {
            resolve(ifExpr.valueExpr);
        }
        return null;
    }

    private final Map<SObjectType, Fields> cachedFieldsBySObjectType = new Map<SObjectType, Fields>();
    private Fields getFields() {
        if (cachedFieldsBySObjectType.containsKey(this.queryContext.objectType)) {
            return cachedFieldsBySObjectType.get(this.queryContext.objectType);
        }

        Map<String, SObjectField> fields = this.queryContext.objectType.getDescribe().fields.getMap();
        Fields fieldsToCache = new Fields();
        for (String currentKey : fields.keySet()) {
            fieldsToCache.add(new Field(currentKey.toLowerCase(), false));
            String relationshipName = fields.get(currentKey).getDescribe().getRelationshipName();
            if (String.isNotBlank(relationshipName)) {
                fieldsToCache.add(new Field(relationshipName.toLowerCase(), true));
            }
        }
        cachedFieldsBySObjectType.put(this.queryContext.objectType, fieldsToCache);
        return fieldsToCache;
    }

    public class ResolverException extends Exception {
    }

    private class Fields {
        private final Set<Field> fields;

        public Fields() {
            this.fields = new Set<Field>();
        }

        public void add(Field field) {
            this.fields.add(field);
        }

        public Field get(String fieldName) {
            for (Field field : this.fields) {
                if (field.name == fieldName) {
                    return field;
                }
            }
            return null;
        }
    }

    private class Field {
        final String name;
        final Boolean isRelationship;

        public Field(String name, Boolean isRelationship) {
            this.name = name;
            this.isRelationship = isRelationship;
        }

        public Boolean equals(Object obj) {
            if (obj instanceof Field) {
                Field other = (Field)obj;
                return this.name == other.name && this.isRelationship == other.isRelationship;
            }
            return false;
        }

        public Integer hashCode() {
            return this.name.hashCode() + this.isRelationship.hashCode();
        }
    }

    private interface IdComposite {
        SObjectType getSobjectType();
        Set<Id> getIds();
        Boolean isComposite();
    }

    private class SingleId implements IdComposite {
        private final Id id;
        public SingleId(Id id) {
            this.id = id;
        }

        public SObjectType getSobjectType() {
            return this.id.getSobjectType();
        }

        public Set<Id> getIds() {
            return new Set<Id> {
                this.id
            };
        }

        public Boolean isComposite() {
            return false;
        }
    }

    private class MultipleIds implements IdComposite {
        private final Set<Id> ids;
        public MultipleIds(Set<Id> ids) {
            this.ids = ids;
        }

        public SObjectType getSobjectType() {
            return new List<Id>(this.ids)[0].getSobjectType();
        }

        public Set<Id> getIds() {
            return this.ids;
        }

        public Boolean isComposite() {
            return true;
        }
    }

    public class Query {
        public Q queryBuilder { get; private set; }
        public IdComposite recordId { get; private set; }
        public SObjectType objectType { get; private set; }
        public String relationshipName { get; private set; }

        public Query(Id recordId) {
            this.recordId = new SingleId(recordId);
            this.objectType = this.recordId.getSobjectType();
            this.queryBuilder = new Q(this.objectType);
            this.queryBuilder.selectField('Id');
        }

        public Query(Set<Id> recordIds) {
            this.recordId = new MultipleIds(recordIds);
            this.objectType = this.recordId.getSobjectType();
            System.debug('Querying for ' + this.objectType);
            this.queryBuilder = new Q(this.objectType);
            this.queryBuilder.selectField('Id');
        }

        public Query(SObjectType objectType, String relationshipName) {
            this.objectType = objectType;
            this.relationshipName = relationshipName;
            this.queryBuilder = new Q(relationshipName);
            this.queryBuilder.selectField('Id');
        }
    }

    private Query getSubqueryFor(String relationshipName) {
        for (Query subquery : this.subQueries) {
            if (subquery.relationshipName == relationshipName) {
                return subquery;
            }
        }
        return null;
    }

    private class NotSupportedGetResolutionException extends Exception {
    }
}
