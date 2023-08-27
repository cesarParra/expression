public with sharing class ContextResolver implements Visitor {
    private Boolean shouldExecuteQuery = false;
    private final Id recordId;
    private final SObjectType objectType;
    private final Q queryBuilder;
    private final Set<String> fields;
    private final Map<String, Q> subqueriesByRelationshipName = new Map<String, Q>();

    public ContextResolver(Id recordId) {
        this.recordId = recordId;
        this.objectType = recordId.getSobjectType();
        this.queryBuilder = new Q(recordId.getSobjectType());
        this.fields = new Set<String>();
    }

    public ContextResolver(String relationshipName, SObjectType objectType) {
        this.queryBuilder = new Q(relationshipName);
        this.objectType = objectType;
        this.fields = new Set<String>();
    }

    public Object visit(Expr.Variable variable) {
        return null;
    }

    public Object visit(Expr.MergeField mergeField) {
        String fieldName = mergeField.name.lexeme.toLowerCase();

        // Check if the field belongs to the parent object
        if (this.getFields().contains(fieldName)) {
            this.fields.add(fieldName);
            return null;
        }

        // Check if the merge field is a child relationship field
        for (ChildRelationship relationship : this.recordId.getSobjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == fieldName) {
                // Do nothing
                return null;
            }
        }

        throw new ResolverException('Did not understand the relationship to field ' +
            mergeField.name.lexeme + ' for SObjectType ' + this.recordId.getSobjectType());
    }

    public Object visit(Expr.Binary binary) {
        this.resolve(binary.left);
        this.resolve(binary.right);
        return null;
    }

    public Object visit(Expr.Grouping grouping) {
        this.resolve(grouping.expression);
        return null;
    }

    public Object visit(Expr.Literal literal) {
        return null;
    }

    public Object visit(Expr.Unary unary) {
        this.resolve(unary.right);
        return null;
    }

    public Object visit(Expr.GetExpr getExpr) {
        String referenceName = this.resolveExtractReferenceOutOfGetExpression(getExpr);
        this.fields.add(referenceName);
        return null;
    }

    public Object visit(Expr.Spread spread) {
        this.resolve(spread.expression);
        return null;
    }

    public Object visit(Expr.MapLiteral mp) {
        for (Object element : mp.elements) {
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

    public String resolveExtractReferenceOutOfGetExpression(Expr.GetExpr getExpr) {
        // Get the relationship field to query out of the get/merge field contained.
        String relationshipToQuery = '';
        if ((getExpr.objectExpr instanceof Expr.MergeField)) {
            relationshipToQuery += ((Expr.MergeField) getExpr.objectExpr).name.lexeme;
        } else if ((getExpr.objectExpr instanceof Expr.GetExpr)) {
            relationshipToQuery += (String) this.resolveExtractReferenceOutOfGetExpression((Expr.GetExpr) getExpr.objectExpr);
        } else {
            throw new ResolverException('Did not understand the relationship to field ' +
                getExpr.objectExpr + ' for SObjectType ' + this.recordId.getSobjectType());
        }

        return relationshipToQuery + '.' + getExpr.name.lexeme;
    }

    public Object visit(Expr.FunctionCall function) {
        if (function.functionName == 'MAP') {
            // The MAP function is a special case, since we might be dealing with a
            // child relationship whose fields need to be queried correctly as a subquery.
            // Expect 2 arguments, the first will be the name of the child relationship field or any other list value,
            // the second is an expression that might use fields of the child relationship.
            if (function.arguments.size() != 2) {
                throw new ResolverException(
                    'Error executing "MAP" function: the function must have exactly 2 arguments.'
                );
            }

            if (!(function.arguments.get(0) instanceof Expr.MergeField)) {
                // If we are not dealing with a merge field that needs to be
                // resolved to a query, that means we are likely dealing with a regular
                // list, so do nothing
                return null;
            }

            String mapKey = ((Expr.MergeField) function.arguments.get(0)).name.lexeme.toLowerCase();
            SObjectType childRelationshipType = this.getChildRelationshipType(mapKey);
            if (childRelationshipType == null) {
                // If we are not dealing with a child relationship, do nothing
                return null;
            }

            Q subQ = new ContextResolver(mapKey, childRelationshipType).resolveToQ(
                function.arguments.get(1)
            );

            if (this.subqueriesByRelationshipName.containsKey(mapKey)) {
                // If the sub query already exists, add all fields
                this.subqueriesByRelationshipName.get(mapKey).selectFields(subQ.getFields());
            } else {
                // Otherwise, add the sub query to the map
                this.subqueriesByRelationshipName.put(mapKey, subQ);
            }

            this.shouldExecuteQuery = true;

            return null;
        }

        for (Expr argument : function.arguments) {
            this.resolve(argument);
        }
        return null;
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        for (Expr element : listLiteral.elements) {
            this.resolve(element);
        }
        return null;
    }

    public SObject build(Expr expression) {
        String query = this.resolveToQ(expression).build();
        if (!this.shouldExecuteQuery) {
            return null;
        }
        return Database.query(query);
    }

    private Q resolveToQ(Expr expression) {
        this.resolve(expression);

        if (fields.isEmpty() && subqueriesByRelationshipName.isEmpty()) {
            return this.queryBuilder;
        }

        this.shouldExecuteQuery = true;
        this.queryBuilder.selectFields(this.fields);

        for (String relationshipName : this.subqueriesByRelationshipName.keySet()) {
            this.queryBuilder.addSubquery(
                this.subqueriesByRelationshipName.get(relationshipName)
            );
        }

        if (this.recordId != null) {
            this.queryBuilder.add(Q.condition('Id').equalsTo(this.recordId));
        }

        return this.queryBuilder;
    }

    private void resolve(Expr expression) {
        expression.accept(this);
    }

    private Set<String> cachedFields;
    private Set<String> getFields() {
        if (cachedFields == null) {
            cachedFields = new Set<String>();
            cachedFields = this.objectType.getDescribe().fields.getMap().keySet();
        }

        return cachedFields;
    }

    private SObjectType getChildRelationshipType(String targetChildRelationshipName) {
        for (ChildRelationship relationship : this.recordId.getSobjectType().getDescribe().getChildRelationships()) {
            String childRelationshipName = relationship.getRelationshipName()?.toLowerCase();
            if (childRelationshipName != null && childRelationshipName == targetChildRelationshipName) {
                return relationship.getChildSObject();
            }
        }
        return null;
    }

    public class ResolverException extends Exception {
    }
}
