public with sharing class AstPrinter implements Visitor, EvaluatorEventListener {
    public Map<String, Object> handle(EvaluatorEvent event) {
        OnAfterParseEvent parseEvent = (OnAfterParseEvent) event;
        List<Object> toPrint = new List<Object>();
        for (Expr expression : parseEvent.expressions) {
            toPrint.add(expression.accept(this));
        }

        System.debug(JSON.serializePretty(toPrint));
        return new Map<String, Object>{
            'ast' => toPrint
        };
    }

    public Object visit(Expr.Logical logical) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Logical',
            'body' => new Map<String, Object>{
                'left' => logical.left.accept(this),
                'operator' => logical.operator.lexeme,
                'right' => logical.right.accept(this)
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Binary binary) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Binary',
            'body' => new Map<String, Object>{
                'left' => binary.left.accept(this),
                'operator' => binary.operator?.lexeme,
                'right' => binary.right.accept(this)
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Grouping grouping) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Grouping',
            'body' => new Map<String, Object>{
                'expression' => grouping.expression.accept(this)
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Literal literal) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Literal',
            'body' => new Map<String, Object>{
                'value' => literal.value
            }
        };
        return toPrint;
    }

    public Object visit(Expr.StringLiteral literal) {
        List<Object> stringsAndInterpolations = new List<Object>();
        for (Object current : literal.stringsAndInterpolations) {
            if (current instanceof String) {
                stringsAndInterpolations.add(current);
            } else if (current instanceof Expr) {
                stringsAndInterpolations.add(((Expr) current).accept(this));
            }
        }
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'StringLiteral',
            'body' => new Map<String, Object>{
                'value' => stringsAndInterpolations
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Variable variable) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Variable',
            'body' => new Map<String, Object>{
                'name' => variable.name.lexeme
            }
        };
        return toPrint;
    }

    public Object visit(Expr.MergeFieldOrScopeVariable mergeField) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'MergeField',
            'body' => new Map<String, Object>{
                'name' => mergeField.name.lexeme
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Unary unary) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Unary',
            'body' => new Map<String, Object>{
                'operator' => unary.operator.lexeme,
                'right' => unary.right.accept(this)
            }
        };
        return toPrint;
    }

    public Object visit(Expr.GetExpr getExpr) {
        List<Object> arguments = new List<Object>();
        for (Expr expr : getExpr.arguments) {
            arguments.add(expr.accept(this));
        }
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Get',
            'body' => new Map<String, Object>{
                'object' => getExpr.objectExpr.accept(this),
                'field' => getExpr.field.lexeme,
                'arguments' => arguments
            }
        };
        return toPrint;
    }

    public Object visit(Expr.FunctionCall function) {
        List<Object> arguments = new List<Object>();
        for (Expr expr : function.arguments) {
            arguments.add(expr.accept(this));
        }
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'FunctionCall',
            'body' => new Map<String, Object>{
                'name' => function.functionName,
                'arguments' => arguments
            }
        };
        return toPrint;
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        List<Object> elements = new List<Object>();
        for (Expr expr : listLiteral.elements) {
            elements.add(expr.accept(this));
        }
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'ListLiteral',
            'body' => new Map<String, Object>{
                'elements' => elements
            }
        };
        return toPrint;
    }

    public Object visit(Expr.MapLiteral mapLiteral) {
        List<Object> elements = new List<Object>();
        for (Object current : mapLiteral.elements) {
            if (current instanceof Expr.KeyValue) {
                Object key = ((Expr.KeyValue) current).key.accept(this);
                Object value = ((Expr.KeyValue) current).value.accept(this);
                Map<String, Object> keyValue = new Map<String, Object>{
                    'key' => key,
                    'value' => value
                };
                elements.add(keyValue);
            } else if (current instanceof Expr.Spread) {
                elements.add(((Expr.Spread) current).accept(this));
            }
        }
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'MapLiteral',
            'body' => new Map<String, Object>{
                'elements' => elements
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Spread spread) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Spread',
            'body' => new Map<String, Object>{
                'expression' => spread.expression.accept(this)
            }
        };
        return toPrint;
    }

    public Object visit(Expr.Query query) {
        List<Object> orderBys = new List<Object>();
        for (Expr orderBy : query.orderBy) {
            orderBys.add(orderBy.accept(this));
        }
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'Query',
            'body' => new Map<String, Object>{
                'select' => query.sObjectType.lexeme,
                'fields' => query.fieldsExpression?.accept(this),
                'where' => query.whereExpr?.accept(this),
                'orderBy' => orderBys
            }
        };

        return toPrint;
    }

    public Object visit(Expr.FunctionDeclaration functionDeclaration) {
        Map<String, Object> toPrint = new Map<String, Object>{
            'type' => 'FunctionDeclaration',
            'body' => new Map<String, Object>{
                'name' => functionDeclaration.name.lexeme,
                'parameters' => functionDeclaration.parameters,
                'body' => functionDeclaration.body.accept(this)
            }
        };
        return toPrint;
    }
}
