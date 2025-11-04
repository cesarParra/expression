public virtual with sharing class Interpreter implements Visitor {
    private final Environment env;

    private Boolean inListLiteral = false;
    private Boolean isInMapLiteral = false;

    public Interpreter(Environment env) {
        this.env = env;
    }

    public void setIsInListLiteral(Boolean inListLiteral) {
        this.inListLiteral = inListLiteral;
    }

    public Object interpret(Expr expression) {
        return evaluate(expression);
    }

    protected Object evaluate(Expr expr) {
        return expr.accept(this);
    }

    public Environment getEnvironment() {
        return env;
    }

    public virtual Object visit(Expr.Logical logical) {
        Object left = evaluate(logical.left);

        if (logical.operator.type == TokenType.DOUBLE_PIPE) {
            if (!isBoolean(left)) {
                throw new Exceptions.RuntimeException(
                    logical.operator,
                    'Error executing ' + logical.operator.lexeme + ' operator: the left operand must evaluate to a boolean value.'
                );
            }

            Boolean leftAsBoolean = (Boolean)left;

            if (leftAsBoolean) {
                return true;
            }

            Object right = evaluate(logical.right);
            if (!isBoolean(right)) {
                throw new Exceptions.RuntimeException(
                    logical.operator,
                    'Error executing ' + logical.operator.lexeme + ' operator: the right operand must evaluate to a boolean value.'
                );
            }

            return (Boolean)right;
        } else {
            if (!isBoolean(left)) {
                throw new Exceptions.RuntimeException(
                    logical.operator,
                    'Error executing ' + logical.operator.lexeme + ' operator: the left operand must evaluate to a boolean value.'
                );
            }

            Boolean leftAsBoolean = (Boolean)left;

            if (!leftAsBoolean) {
                return false;
            }

            Object right = evaluate(logical.right);
            if (!isBoolean(right)) {
                throw new Exceptions.RuntimeException(
                    logical.operator,
                    'Error executing ' + logical.operator.lexeme + ' operator: the right operand must evaluate to a boolean value.'
                );
            }

            return (Boolean)right;
        }
    }

    public virtual Object visit(Expr.Binary binary) {
        Object left = evaluate(binary.left);
        Object right = evaluate(binary.right);

        switch on binary.operator.type {
            when PLUS {
                if (left instanceof Decimal && right instanceof Decimal) {
                    // Add numbers
                    return (Decimal)left + (Decimal)right;
                }
                if (left instanceof String && right instanceof String) {
                    // Concatenate strings
                    return (String)left + (String)right;
                }
                throw new Exceptions.RuntimeException(
                    binary.operator, 'Error executing ' + binary.operator.lexeme + ' operator: operands must be numbers or strings.'
                );
            }
            when AMPERSAND {
                if (left instanceof String && right instanceof String) {
                    // Concatenate strings
                    return (String)left + (String)right;
                }
                throw new Exceptions.RuntimeException(
                    binary.operator, 'Error executing ' + binary.operator.lexeme + ' operator: operands must be strings.'
                );
            }
            when MINUS {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left - (Decimal)right;
            }
            when STAR {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left * (Decimal)right;
            }
            when SLASH {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left / (Decimal)right;
            }
            when EXPONENT {
                if (!checkIsDecimal(left) || !checkIsDecimal(right)) {
                    throw new Exceptions.RuntimeException(
                        binary.operator,
                        'Error executing ' + binary.operator.lexeme + ' operator: the left operand must be a number and' +
                            ' the right operand must be an integer, but found: left' + left + ' and right ' + right
                    );
                }

                // This can result in a runtime exception since right might not be an integer,
                // but any number
                return ((Decimal)left).pow(Integer.valueOf(right));
            }
            when GREATER {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left > (Decimal)right;
            }
            when GREATER_EQUAL {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left >= (Decimal)right;
            }
            when LESS {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left < (Decimal)right;
            }
            when LESS_EQUAL {
                checkNumberOperand(binary.operator, left, right);
                return (Decimal)left <= (Decimal)right;
            }
            when EQUAL, EQUAL_EQUAL {
                return left == right;
            }
            when LESS_GREATER, BANG_EQUAL {
                return left != right;
            }
        }

        // Unreachable
        return null;
    }

    public Object visit(Expr.Grouping grouping) {
        return evaluate(grouping.expression);
    }

    public Object visit(Expr.Literal literal) {
        return literal.value;
    }

    public Object visit(Expr.StringLiteral literal) {
        String stringValue = '';
        for (Object current : literal.stringsAndInterpolations) {
            if (current instanceof String) {
                stringValue += (String)current;
            } else if (current instanceof Expr) {
                Object result = evaluate((Expr)current);
                stringValue += StringUtils.valueOf(result);
            }
        }
        return stringValue;
    }

    public virtual Object visit(Expr.GetExpr getExpr) {
        Object result = evaluate(getExpr.objectExpr);
        if (result instanceof SObject) {
            if (!getExpr.arguments.isEmpty()) {
                throw new Exceptions.RuntimeException(
                    getExpr.field,
                    'Error executing expression. Get expressions on SObjects must not have arguments.'
                );
            }

            Environment tempEnvironmentForGet = new Environment((SObject)result);

            // We might be dealing with either a field reference or with a reference to another parent
            if (tempEnvironmentForGet.contains(getExpr.field.lexeme)) {
                return tempEnvironmentForGet.get(getExpr.field.lexeme);
            } else if (tempEnvironmentForGet.containsAsParent(getExpr.field.lexeme)) {
                return tempEnvironmentForGet.getParentSObject(getExpr.field.lexeme);
            }

            throw new Exceptions.RuntimeException(
                getExpr.field,
                'Error executing get expression: the SObject type ' +
                    tempEnvironmentForGet.getSObjectTypeName() +
                    ' does not contain a field with the name: ' + getExpr.field.lexeme
            );
        } else if (result instanceof IGlobalVariableResolver) {
            List<Object> arguments = new List<Object>();
            for (Expr argument : getExpr.arguments) {
                arguments.add(evaluate(argument));
            }

            try {
                return ((IGlobalVariableResolver)result).get(getExpr.field.lexeme, arguments);
            } catch (Exceptions.PositionAwareException e) {
                throw e;
            } catch (Exception e) {
                throw new Exceptions.RuntimeException(
                    getExpr.field,
                    e.getMessage()
                );
            }
        } else if (result instanceof Map<Object, Object>) {
            if (!getExpr.arguments.isEmpty()) {
                throw new Exceptions.RuntimeException(
                    getExpr.field,
                    'Error executing expression. Get expressions on Maps must not have arguments.'
                );
            }

            Map<Object, Object> castMap = (Map<Object, Object>)result;
            if (castMap.containsKey(getExpr.field.lexeme)) {
                return castMap.get(getExpr.field.lexeme);
            }

            throw new Exceptions.RuntimeException(
                getExpr.field,
                'Error executing get expression: the map does not contain a key with the name: ' + getExpr.field.lexeme
            );
        } else if (result instanceof Map<String, Object>) {
            if (!getExpr.arguments.isEmpty()) {
                throw new Exceptions.RuntimeException(
                    getExpr.field,
                    'Error executing expression. Get expressions on Maps must not have arguments.'
                );
            }

            Map<String, Object> castMap = (Map<String, Object>)result;
            if (castMap.containsKey(getExpr.field.lexeme)) {
                return castMap.get(getExpr.field.lexeme);
            }

            throw new Exceptions.RuntimeException(
                getExpr.field,
                'Error executing get expression: the map does not contain a key with the name: ' + getExpr.field.lexeme
            );
        }

        throw new Exceptions.RuntimeException(
            getExpr.field,
            'Error executing get expression: could not determine the value of: ' +
                getExpr.field.lexeme + ' from ' + result
        );
    }

    public Object visit(Expr.Variable variable) {
        if (env == null) {
            throw new Exceptions.RuntimeException(
                variable.name,
                'Error executing variable expression: no context was provided.'
            );
        }

        if (env.contains(variable.name.lexeme)) {
            return env.get(variable.name.lexeme);
        }

        String errorMessage;
//        if (variable.isContext()) {
//            errorMessage = '@Context is not accessible when no context Id or record was provided.';
//        } else {
//            errorMessage = 'Error executing variable expression: the variable ' +
//                variable.name.lexeme +
//                ' is not defined in the current context.';
//        }

        errorMessage = 'Error executing variable expression: the variable ' +
            variable.name.lexeme +
            ' is not defined in the current context.';

        throw new Exceptions.RuntimeException(
            variable.name,
            errorMessage
        );
    }

    public virtual Object visit(Expr.MergeFieldOrScopeVariable mergeFieldOrScopeVariable) {
        if (!env.contains(mergeFieldOrScopeVariable.name.lexeme)) {
            if (env.containsAsParent(mergeFieldOrScopeVariable.name.lexeme)) {
                return env.getParentSObject(mergeFieldOrScopeVariable.name.lexeme);
            }

            String messageSuffix = env.getSObjectTypeName() != null ? ' or the SObject type ' + env.getSObjectTypeName() + ' does not contain a field with that name.' : '';
            throw new Exceptions.RuntimeException(
                mergeFieldOrScopeVariable.name,
                'Error evaluating merge field or variable: ' +
                    mergeFieldOrScopeVariable.name.lexeme +
                    ' A variable with that name is not declared in the current context' +
                    messageSuffix
            );
        }

        return env.get(mergeFieldOrScopeVariable.name.lexeme);
    }

    public virtual Object visit(Expr.Unary unary) {
        Object right = evaluate(unary.right);

        switch on (unary.operator.type) {
            when BANG {
                if (!isBoolean(right)) {
                    throw new Exceptions.RuntimeException(
                        unary.operator,
                        'Error executing ' + unary.operator.lexeme + ' operator: the operand must evaluate to a boolean value.'
                    );
                }

                return !(Boolean)right;
            }
            when MINUS {
                if (!checkIsDecimal(right)) {
                    throw new Exceptions.RuntimeException(
                        unary.operator,
                        'Error executing ' + unary.operator.lexeme + ' operator: the operand must be a number.'
                    );
                }

                return -(Decimal)right;
            }
        }

        // Unreachable
        return null;
    }

    private static Boolean checkIsDecimal(Object single) {
        return single instanceof Decimal;
    }

    private static Boolean isBoolean(Object single) {
        return single instanceof Boolean;
    }

    private static void checkNumberOperand(Token operator, Object left, Object right) {
        if (left instanceof Decimal && right instanceof Decimal) return;
        throw new Exceptions.RuntimeException(
            operator,
            'Error executing ' + operator.lexeme + ' operator: operands must be numbers.'
        );
    }

    public virtual Object visit(Expr.FunctionCall function) {
        return FunctionCaller.exec(this, function);
    }

    public Object visit(Expr.ListLiteral listLiteral) {
        inListLiteral = true;
        List<Object> resultList = new List<Object>();
        for (Expr expr : listLiteral.elements) {
            Object result = evaluate(expr);
            if (result instanceof ListSpreadContents) {
                resultList.addAll(((ListSpreadContents)result).contents);
            } else if (result instanceof AddIfConditional) {
                AddIfConditional element = (AddIfConditional)result;
                if (element.shouldAdd == false) {
                    continue;
                }

                // We can safely cast here since the `visit` method will take
                // care of only returning a ConditionalElement when within a list literal.
                resultList.add(((ConditionalElement)element).value);
            } else {
                resultList.add(result);
            }
        }
        inListLiteral = false;
        return resultList;
    }

    public Object visit(Expr.Spread spread) {
        if (!inListLiteral && !isInMapLiteral) {
            throw new Exceptions.RuntimeException(
                spread.spreadToken,
                'Error executing spread operator: the spread operator can only be used in a list or map literal.'
            );
        }

        if (inListLiteral) {
            Object result = evaluate(spread.expression);
            if (!(result instanceof List<Object>)) {
                throw new Exceptions.RuntimeException(
                    spread.spreadToken,
                    'Error executing spread operator: the expression must evaluate to a list.'
                );
            }

            return new ListSpreadContents((List<Object>)result);
        }

        Object result = evaluate(spread.expression);
        if (!(result instanceof Map<Object, Object>)) {
            throw new Exceptions.RuntimeException(
                spread.spreadToken,
                'Error executing spread operator: the expression must evaluate to a map.'
            );
        }

        return new MapSpreadContents((Map<Object, Object>)result);
    }

    public class ListSpreadContents {
        public List<Object> contents;

        public ListSpreadContents(List<Object> contents) {
            this.contents = contents;
        }
    }

    public class MapSpreadContents {
        public Map<Object, Object> contents;

        public MapSpreadContents(Map<Object, Object> contents) {
            this.contents = contents;
        }
    }

    public Object visit(Expr.MapLiteral mapLiteral) {
        isInMapLiteral = true;
        Map<Object, Object> resultMap = new Map<Object, Object>();
        for (Object element : mapLiteral.elements) {
            if (element instanceof Expr.KeyValue) {
                Expr.KeyValue mapElement = (Expr.KeyValue)element;
                Object key = evaluate(mapElement.key);
                Object value = evaluate(mapElement.value);
                resultMap.put(key, value);
            } else if (element instanceof Expr.Spread) {
                Object result = evaluate((Expr.Spread)element);
                if (result instanceof MapSpreadContents) {
                    resultMap.putAll(((MapSpreadContents)result).contents);
                }
            } else if (element instanceof Expr.AddIfExpr) {
                Object result = evaluate((Expr.AddIfExpr)element);
                AddIfConditional conditional = (AddIfConditional)result;
                if (conditional.shouldAdd == false) {
                    continue;
                }
                // We can safely cast here since the `visit` method will take
                // care of only returning a ConditionalKeyValuePair when within a map literal.
                ConditionalKeyValuePair conditionalKeyValuePair = (ConditionalKeyValuePair)result;
                resultMap.put(conditionalKeyValuePair.key, conditionalKeyValuePair.value);
            }
        }
        isInMapLiteral = false;
        return resultMap;
    }

    public virtual Object visit(Expr.Query query) {
        Q querier = new QueryInterpreter(this.env).evaluateToQuery(query);
        return QDB.getInstance().run(querier);
    }

    public Object visit(Expr.FunctionDeclaration functionDeclaration) {
        if (functionDeclaration.isAnonymous) {
            return functionDeclaration;
        }

        // Declarations should not be called
        // by the EvaluatorResolver.
        // Reaching this point means a declaration exists within another expression and not at the top level,
        // which is not valid.
        throw new Exceptions.RuntimeException(
            functionDeclaration.name,
            'Function declarations can only be declared at the top level of an expression.'
        );
    }

    private abstract class AddIfConditional {
        public final Boolean shouldAdd;

        protected AddIfConditional(Boolean shouldAdd) {
            this.shouldAdd = shouldAdd;
        }
    }

    private class ShouldNotAdd extends AddIfConditional {
        public ShouldNotAdd() {
            super(false);
        }
    }

    private class ConditionalElement extends AddIfConditional {
        public final Object value;

        public ConditionalElement(Object value) {
            super(true);
            this.value = value;
        }
    }

    private class ConditionalKeyValuePair extends AddIfConditional {
        public final Object key;
        public final Object value;

        public ConditionalKeyValuePair(Object key, Object value) {
            super(true);
            this.key = key;
            this.value = value;
        }
    }

    public Object visit(Expr.AddIfExpr ifExpr) {
        if (!inListLiteral && !isInMapLiteral) {
            throw new Exceptions.RuntimeException(
                ifExpr.ifToken,
                'Error executing addif expression: the "addif" expression can only be used in a list or map literal.'
            );
        }

        if (inListLiteral && ifExpr.valueExpr != null) {
            throw new Exceptions.RuntimeException(
                ifExpr.ifToken,
                'Error executing addif expression: a "colon" was not expected. When using addif in a list literal, only one expression is expected.'
            );
        }

        if (isInMapLiteral && ifExpr.valueExpr == null) {
            throw new Exceptions.RuntimeException(
                ifExpr.ifToken,
                'Error executing addif expression: a "colon" was expected. ' +
                    'When using addif in a map literal, two expressions separated by a colon (:) are expected, one for the key and one for the value.'
            );
        }

        Object condition = evaluate(ifExpr.condition);
        if (!isBoolean(condition)) {
            throw new Exceptions.RuntimeException(
                ifExpr.ifToken,
                'Error executing addif expression: the condition must evaluate to a boolean value.'
            );
        }

        if ((Boolean)condition) {
            if (ifExpr.isForKeyValuePair()) {
                return new ConditionalKeyValuePair(
                    evaluate(ifExpr.body),
                    evaluate(ifExpr.valueExpr)
                );
            }

            return new ConditionalElement(
                evaluate(ifExpr.body)
            );
        }

        return new ShouldNotAdd();
    }
}
