public with sharing class ContextResolver implements Visitor {
    private final Id recordId;
    private final Q queryBuilder;
    private final Set<String> fields;
    private final Map<String, Set<String>> childRelationshipsFieldsByRelationshipName;

    public ContextResolver(Id recordId) {
        this.recordId = recordId;
        this.queryBuilder = new Q(recordId.getSobjectType());
        this.fields = new Set<String>();
        this.childRelationshipsFieldsByRelationshipName = new Map<String, Set<String>>();
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
                if (!this.childRelationshipsFieldsByRelationshipName.containsKey(childRelationshipName)) {
                    this.childRelationshipsFieldsByRelationshipName.put(childRelationshipName, new Set<String>());
                }

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

    public Object visit(Expr.Function function) {
        switch on function.name.type {
            // The TOLIST function is a special case, since here we know we are dealing with a
            // child relationship whose fields need to be queried correctly as a subquery.
            when TOLIST_FN {
                // Expect 2 arguments, the first will be the name of the child relationship field,
                // the second the name of the fields for which we want the data
                if (function.arguments.size() != 2) {
                    throw new ResolverException(
                        'Error executing ' + function.name.lexeme + ' function: the function must have exactly 2 arguments.'
                    );
                }

                // Evaluate the first argument as normal.
                // This will eventually resolve as a Merge field and initialize
                // the childRelationshipsFieldsByRelationshipName map.
                this.resolve(function.arguments[0]);

                // The first argument is the name of a child relationship, which will be the key to our map
                if (!(function.arguments.get(0) instanceof Expr.MergeField)) {
                    throw new ResolverException(
                        'Error executing ' + function.name.lexeme + ' function: the first argument must be a merge field.'
                    );
                }

                String mapKey = ((Expr.MergeField) function.arguments.get(0)).name.lexeme.toLowerCase();

                // The second argument is the name of a child field, so we want to add it to the pre-initialized
                // map so that it gets queried
                if (!(function.arguments.get(1) instanceof Expr.MergeField)) {
                    throw new ResolverException(
                        'Error executing ' + function.name.lexeme + ' function: the second argument must be a merge field.'
                    );
                }
                String secondArgument = ((Expr.MergeField) function.arguments.get(1)).name.lexeme;
                Set<String> fields = this.childRelationshipsFieldsByRelationshipName.get(mapKey);
                fields.add(secondArgument);

                return null;
            }
        }

        // For anything else, we resolve as normal
        for (Expr argument : function.arguments) {
            this.resolve(argument);
        }
        return null;
    }

    public SObject build(Expr expression) {
        this.resolve(expression);

        this.queryBuilder.selectFields(this.fields).add(Q.condition('Id').equalsTo(this.recordId));
        for (String relationshipName : this.childRelationshipsFieldsByRelationshipName.keySet()) {
            Q childQ = new Q(relationshipName);
            childQ.selectFields(this.childRelationshipsFieldsByRelationshipName.get(relationshipName));
            this.queryBuilder.addSubquery(childQ);
        }
        String query = this.queryBuilder.build();
        return Database.query(query);
    }

    private void resolve(Expr expression) {
        expression.accept(this);
    }

    private static Set<String> cachedFields;
    private Set<String> getFields() {
        if (cachedFields == null) {
            cachedFields = new Set<String>();
            cachedFields = recordId.getSobjectType().getDescribe().fields.getMap().keySet();
        }

        return cachedFields;
    }

    public class ResolverException extends Exception {
    }
}
