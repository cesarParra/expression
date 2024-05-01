public with sharing class ContextResolver implements Visitor {
    private Boolean shouldExecuteQuery = false;
    private Query queryContext;

    private final Query topLevelQuery;
    private final List<Query> subQueries = new List<Query>();

    public ContextResolver(Id recordId) {
        this.queryContext = new Query(recordId);
        this.topLevelQuery = this.queryContext;
    }

    public ContextResolver(Set<Id> recordIds) {
        this.queryContext = new Query(recordIds);
        this.topLevelQuery = this.queryContext;
    }

    private Object resolve(Expr expr) {
        return expr.accept(this);
    }

    public List<SObject> build(Expr expression) {
        this.resolve(expression);
        if (!this.shouldExecuteQuery) {
            return null;
        }

        for (Query subquery : this.subQueries) {
            this.queryContext.queryBuilder.addSubquery(subquery.queryBuilder);
        }

        this.queryContext.queryBuilder.add(Q.condition('Id').isIn(new List<Id>(this.queryContext.recordId.getIds())));
        System.debug('Query: ' + this.queryContext.queryBuilder.build());
        List<SObject> results = QRunner.getInstance().run(this.queryContext.queryBuilder);
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
                resolve((Expr) obj);
            }
        }
        return null;
    }

    public Object visit(Expr.Unary unary) {
        resolve(unary.right);
        return null;
    }

    public Object visit(Expr.FunctionCall function) {
        ExpressionFunction fn = ExpressionFunction.getByName(function.functionName);
        if (fn == null) {
            return null;
        }

        // Whenever children resolution is needed we assume that the second argument contains the expression
        // for which to resolve, so skip this when the argument list is not long enough.
        if (fn.needsChildrenResolution() && function.arguments.size() > 1) {
            // We want to first resolve the left side and it should resolve to a Query object
            // which we will use as the context for the right side.

            Query previousContext = this.queryContext;
            Object result = resolve(function.arguments[0]);
            if (!(result instanceof Query)) {
                return null;
            }

            this.queryContext = (Query) result;
            resolve(function.arguments[1]);
            this.queryContext = previousContext;

            if (function.functionName == 'WHERE') {
                // The WHERE function is a special case where we might want to keep building
                // the query it started resolving.
                return result;
            } else {
                return null;
            }
        } else {
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
        if ((getExpr.objectExpr instanceof Expr.MergeField)) {
            relationshipToQuery += ((Expr.MergeField) getExpr.objectExpr).name.lexeme + '.';
        } else if ((getExpr.objectExpr instanceof Expr.GetExpr)) {
            relationshipToQuery += (String) this.resolveExtractReferenceOutOfGetExpression((Expr.GetExpr) getExpr.objectExpr) + '.';
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
            return ((Expr.Variable) expr.objectExpr).isContext();
        } else if (expr.objectExpr instanceof Expr.GetExpr) {
            // Recursively check if the parent object is referencing a context field
            // since we can have nested get expressions and what is important is the top level
            // object that is being referenced.
            return isReferencingContextField((Expr.GetExpr) expr.objectExpr);
        }
        return false;
    }

    public Object visit(Expr.Variable variable) {
        if (variable.isContext()) {
            this.shouldExecuteQuery = true;
        }
        return topLevelQuery;
    }

    public Object visit(Expr.MergeField mergeField) {
        String fieldName = mergeField.name.lexeme.toLowerCase();
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
        if (this.getFields().contains(fieldName)) {
            queryContext.queryBuilder.selectField(fieldName);
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

        throw new ResolverException('Did not understand the relationship to field ' +
            fieldName + ' for SObjectType ' + queryContext.objectType);
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
                this.resolve(((Expr.Spread) element).expression);
                continue;
            }

            Expr.KeyValue keyValue = (Expr.KeyValue) element;
            this.resolve(keyValue.key);
            this.resolve(keyValue.value);
        }
        return null;
    }

    public Object visit(Expr.Spread spread) {
        this.resolve(spread.expression);
        return null;
    }

    public Object visit(Expr.Query query) {
        // Nothing to resolve when inside of a Query expression.
        // A query expression essentially starts an isolated context.
        return null;
    }

    private final Map<SObjectType, Set<String>> cachedFieldsBySObjectType = new Map<SObjectType, Set<String>>();
    private Set<String> getFields() {
        if (cachedFieldsBySObjectType.containsKey(this.queryContext.objectType)) {
            return cachedFieldsBySObjectType.get(this.queryContext.objectType);
        }

        Set<String> cachedFields = this.queryContext.objectType.getDescribe().fields.getMap().keySet();
        cachedFieldsBySObjectType.put(this.queryContext.objectType, cachedFields);
        return cachedFields;
    }

    public class ResolverException extends Exception {
    }

    private interface IdComposite {
        SObjectType getSobjectType();
        Set<Id> getIds();
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
            return new Set<Id>{
                this.id
            };
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
