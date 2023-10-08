public with sharing class ContextResolver implements Visitor {
    private Boolean shouldExecuteQuery = false;
    private Query queryContext;
    private final List<Query> subQueries = new List<Query>();

    public ContextResolver(Id recordId) {
        this.queryContext = new Query(recordId);
    }

    private Object resolve(Expr expr) {
        return expr.accept(this);
    }

    public SObject build(Expr expression) {
        this.resolve(expression);
        if (!this.shouldExecuteQuery) {
            return null;
        }

        for (Query subquery : this.subQueries) {
            this.queryContext.queryBuilder.addSubquery(subquery.queryBuilder);
        }

        this.queryContext.queryBuilder.add(Q.condition('Id').equalsTo(this.queryContext.recordId));

        String query = this.queryContext.queryBuilder.build();
        return Database.query(query);
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

    public Object visit(Expr.Unary unary) {
        resolve(unary.right);
        return null;
    }

    public Object visit(Expr.FunctionCall function) {
        ExpressionFunction fn = ExpressionFunction.FUNCTIONS.get(function.functionName);
        if (fn == null) {
            return null;
        }
        if (fn.needsChildrenResolution()) {
            // Expect at least 2 arguments, the first will be the name of the child relationship field or any other list value,
            // the second is an expression that might use fields of the child relationship.
            if (function.arguments.size() < 2) {
                throw new ResolverException(
                    'Error executing ' + function.functionName + ' function: the function must have exactly 2 arguments.'
                );
            }

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
            this.queryContext.queryBuilder.selectField(referenceName);
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
        } else {
            // If we are doing a "get" expression on anything that is not either a merge field
            // or another inner get expression, we don't know how to resolve it, so we shouldn't
            // end up adding it to the query
            throw new NotSupportedGetResolutionException();
        }

        return relationshipToQuery + getExpr.field.lexeme;
    }

    public Object visit(Expr.Variable variable) {
        return null;
    }

    public Object visit(Expr.MergeField mergeField) {
        String fieldName = mergeField.name.lexeme.toLowerCase();

        // Check if the field belongs to the parent object
        if (this.getFields().contains(fieldName)) {
            this.queryContext.queryBuilder.selectField(fieldName);
            this.shouldExecuteQuery = true;
            return null;
        }

        // Check if the merge field is a child relationship field
        for (ChildRelationship relationship : this.queryContext.objectType.getDescribe().getChildRelationships()) {
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
            mergeField.name.lexeme + ' for SObjectType ' + this.queryContext.objectType);
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

    private Set<String> cachedFields;
    private Set<String> getFields() {
        if (cachedFields == null) {
            cachedFields = new Set<String>();
            cachedFields = this.queryContext.objectType.getDescribe().fields.getMap().keySet();
        }

        return cachedFields;
    }

    public class ResolverException extends Exception {
    }

    public class Query {
        public Q queryBuilder { get; private set; }
        public Id recordId { get; private set; }
        public SObjectType objectType { get; private set; }
        public String relationshipName { get; private set; }

        public Query(Id recordId) {
            this.recordId = recordId;
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
