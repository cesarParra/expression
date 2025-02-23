/**
 * @description Converts an AST with pipe operators into a normal AST.
 */
public with sharing class PipeResolver implements Visitor {
    public Expr resolve(Expr expr) {
        return (Expr) expr.accept(this);
    }

    public Object visit(Expr.Logical logical) {
        Expr.Logical newLogical = new Expr.Logical(
            resolve(logical.left),
            logical.operator,
            resolve(logical.right)
        );

        return newLogical;
    }

    public Object visit(Expr.Binary binary) {
        if (binary.operator?.type == TokenType.ARROW) {
            // Check that the right side is a function call
            if (!(binary.right instanceof Expr.FunctionCall)) {
                throw new Exceptions.RuntimeException(
                    binary.operator,
                    'Right side of pipe must be a function call'
                );
            }

            // Add the left side as the first argument to the function call
            Expr.FunctionCall function = (Expr.FunctionCall) binary.right;
            if (function.arguments.isEmpty()) {
                function.arguments.add(binary.left);
            } else {
                function.arguments.add(0, binary.left);
            }

            return visit(function);
        }

        Expr.Binary newBinary = new Expr.Binary(
            resolve(binary.left),
            binary.operator,
            resolve(binary.right)
        );

        return newBinary;
    }

    public Object visit(Expr.Grouping grouping) {
        Expr.Grouping newGrouping = new Expr.Grouping(resolve(grouping.expression));
        return newGrouping;
    }

    public Object visit(Expr.Literal literal) {
        return literal;
    }

    public Object visit(Expr.StringLiteral literal) {
        return literal;
    }

    public Object visit(Expr.Unary unary) {
        Expr.Unary newUnary = new Expr.Unary(
            unary.operator,
            resolve(unary.right)
        );

        return newUnary;
    }

    public Object visit(Expr.FunctionCall function) {
        List<Expr> newArguments = new List<Expr>();
        for (Expr argument : function.arguments) {
            newArguments.add(resolve(argument));
        }

        Expr.FunctionCall newFunction = new Expr.FunctionCall(
            function.functionToken,
            newArguments
        );

        return newFunction;
    }

    public Object visit(Expr.GetExpr getExpr) {
        Expr.GetExpr newGetExpr = new Expr.GetExpr(
            resolve(getExpr.objectExpr),
            getExpr.field,
            getExpr.arguments
        );

        return newGetExpr;
    }

    public Object visit(Expr.Variable variable) {
        return variable;
    }

    public Object visit(Expr.MergeField mergeField) {
        return mergeField;
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        List<Expr> newElements = new List<Expr>();
        for (Expr element : listLiteral.elements) {
            if (element instanceof Expr.Spread) {
                newElements.add(resolve(element));
                continue;
            }

            newElements.add(resolve(element));
        }

        Expr.ListLiteral newListLiteral = new Expr.ListLiteral(newElements);
        return newListLiteral;
    }

    public Object visit(Expr.MapLiteral mapLiteral) {
        List<Object> newElements = new List<Object>();
        for (Object element : mapLiteral.elements) {
            if (element instanceof Expr.Spread) {
                newElements.add(resolve((Expr) element));
                continue;
            }

            Expr.KeyValue keyValue = (Expr.KeyValue) element;
            Expr.KeyValue newKeyValue = new Expr.KeyValue(
                resolve(keyValue.key),
                resolve(keyValue.value)
            );
            newElements.add(newKeyValue);
        }

        Expr.MapLiteral newMapLiteral = new Expr.MapLiteral(newElements);
        return newMapLiteral;
    }

    public Object visit(Expr.Spread spread) {
        Expr.Spread newSpread = new Expr.Spread(spread.spreadToken, resolve(spread.expression));
        return newSpread;
    }

    public Object visit(Expr.Query query) {
        Expr newFieldsExpression;
        if (query.fieldsExpression != null) {
            newFieldsExpression = resolve(query.fieldsExpression);
        }

        List<Expr> newOrderBys = new List<Expr>();
        for (Expr orderBy : query.orderBy) {
            newOrderBys.add(resolve(orderBy));
        }

        Expr newLimitExpr;
        if (query.limitExpr != null) {
            newLimitExpr = resolve(query.limitExpr);
        }

        Expr newWhereExpr;
        if (query.whereExpr != null) {
            newWhereExpr = resolve(query.whereExpr);
        }

        Expr newOffsetExpr;
        if (query.offsetExpr != null) {
            newOffsetExpr = resolve(query.offsetExpr);
        }

        return new Expr.Query(
            query.sObjectType,
            newFieldsExpression,
            newOrderBys,
            newLimitExpr,
            newWhereExpr,
            newOffsetExpr
        );
    }

    public Object visit(Expr.FunctionDeclaration functionDeclaration) {
        throw new Exceptions.RuntimeException(
            functionDeclaration.name,
            'Function declarations are not supported at this time'
        );
    }
}
