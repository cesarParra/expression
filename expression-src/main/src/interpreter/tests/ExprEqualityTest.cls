@IsTest
private class ExprEqualityTest {
    @IsTest
    static void logicalExpressionsCanBeComparedForEquality_equals() {
        Expr left = new Expr.Literal(true);
        Token operator = new Token(TokenType.AMPERSAND, 'AND', null, null);
        Expr right = new Expr.Literal(false);

        Expr.Logical aLogical = new Expr.Logical(left, operator, right);
        Expr.Logical anotherLogical = new Expr.Logical(left, operator, right);

        Assert.isTrue(aLogical == anotherLogical);
    }

    @IsTest
    static void logicalExpressionsCanBeComparedForEquality_notEquals() {
        Expr left = new Expr.Literal(true);
        Token operator = new Token(TokenType.AMPERSAND, 'AND', null, null);
        Expr right = new Expr.Literal(false);

        Expr.Logical aLogical = new Expr.Logical(left, operator, right);
        Expr.Logical anotherLogical = new Expr.Logical(left, operator, new Expr.Literal(true));

        Assert.isFalse(aLogical == anotherLogical);
    }

    @IsTest
    static void binaryExpressionsCanBeComparedForEquality_equals() {
        Expr left = new Expr.Literal(5);
        Token operator = new Token(TokenType.PLUS, '+', null, null);
        Expr right = new Expr.Literal(3);

        Expr.Binary aBinary = new Expr.Binary(left, operator, right);
        Expr.Binary anotherBinary = new Expr.Binary(left, operator, right);

        Assert.isTrue(aBinary == anotherBinary);
    }

    @IsTest
    static void binaryExpressionsCanBeComparedForEquality_notEquals() {
        Expr left = new Expr.Literal(5);
        Token operator = new Token(TokenType.PLUS, '+', null, null);
        Expr right = new Expr.Literal(3);

        Expr.Binary aBinary = new Expr.Binary(left, operator, right);
        Expr.Binary anotherBinary = new Expr.Binary(left, operator, new Expr.Literal(4));

        Assert.isFalse(aBinary == anotherBinary);
    }

    @IsTest
    static void groupingExpressionsCanBeComparedForEquality_equals() {
        Expr anyExpression = new Expr.Literal(10);
        Expr.Grouping aGrouping = new Expr.Grouping(anyExpression);
        Expr.Grouping anotherGrouping = new Expr.Grouping(anyExpression);
        Assert.isTrue(aGrouping == anotherGrouping);
    }

    @IsTest
    static void groupingExpressionsCanBeComparedForEquality_notEquals() {
        Expr aExpression = new Expr.Literal(10);
        Expr anotherExpression = new Expr.Literal(20);
        Expr.Grouping aGrouping = new Expr.Grouping(aExpression);
        Expr.Grouping anotherGrouping = new Expr.Grouping(anotherExpression);
        Assert.isFalse(aGrouping == anotherGrouping);
    }

    @IsTest
    static void functionCallExpressionsCanBeComparedForEquality() {
        Token functionToken = new Token(TokenType.FUNCTION_KEYWORD, 'myFunction', null, null);
        List<Expr> arguments = new List<Expr> { new Expr.Literal(1), new Expr.Literal(2) };

        Expr.FunctionCall aFunctionCall = new Expr.FunctionCall(functionToken, arguments);
        Expr.FunctionCall anotherFunctionCall = new Expr.FunctionCall(functionToken, arguments);

        Assert.isTrue(aFunctionCall == anotherFunctionCall);
    }

    @IsTest
    static void functionCallExpressionsCanBeComparedForEquality_notEquals() {
        Token functionToken = new Token(TokenType.FUNCTION_KEYWORD, 'myFunction', null, null);
        List<Expr> arguments = new List<Expr> { new Expr.Literal(1), new Expr.Literal(2) };
        List<Expr> differentArguments = new List<Expr> { new Expr.Literal(3), new Expr.Literal(4) };

        Expr.FunctionCall aFunctionCall = new Expr.FunctionCall(functionToken, arguments);
        Expr.FunctionCall anotherFunctionCall = new Expr.FunctionCall(functionToken, differentArguments);

        Assert.isFalse(aFunctionCall == anotherFunctionCall);
    }

    @IsTest
    static void literalExpressionsCanBeComparedForEquality_equals() {
        Expr.Literal aLiteral = new Expr.Literal(42);
        Expr.Literal anotherLiteral = new Expr.Literal(42);
        Assert.isTrue(aLiteral == anotherLiteral);
    }

    @IsTest
    static void literalExpressionsCanBeComparedForEquality_notEquals() {
        Expr.Literal aLiteral = new Expr.Literal(42);
        Expr.Literal anotherLiteral = new Expr.Literal(43);
        Assert.isFalse(aLiteral == anotherLiteral);
    }

    @IsTest
    static void stringLiteralsCanBeComparedForEquality_equals() {
        Expr.StringLiteral aLiteral = new Expr.StringLiteral(new List<Object> { 'h', 'e', 'l', 'l', 'o' });
        Expr.StringLiteral anotherLiteral = new Expr.StringLiteral(new List<Object> { 'h', 'e', 'l', 'l', 'o' });
        Assert.isTrue(aLiteral == anotherLiteral);
    }

    @IsTest
    static void stringLiteralsCanBeComparedForEquality_notEquals() {
        Expr.StringLiteral aLiteral = new Expr.StringLiteral(new List<Object> { 'h', 'e', 'l', 'l', 'o' });
        Expr.StringLiteral anotherLiteral = new Expr.StringLiteral(new List<Object> { 'w', 'o', 'r', 'l', 'd' });
        Assert.isFalse(aLiteral == anotherLiteral);
    }

    @IsTest
    static void variableExpressionsCanBeComparedForEquality_equals() {
        Expr.Variable aVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var1', null, null),
            Expr.VariableType.LOCAL
        );

        Expr.Variable anotherVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var1', null, null),
            Expr.VariableType.LOCAL
        );

        Assert.isTrue(aVariable == anotherVariable);
    }

    @IsTest
    static void variableExpressionsCanBeComparedForEquality_notEquals() {
        Expr.Variable aVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var1', null, null),
            Expr.VariableType.LOCAL
        );

        Expr.Variable anotherVariable = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'var2', null, null),
            Expr.VariableType.LOCAL
        );

        Assert.isFalse(aVariable == anotherVariable);
    }

    @IsTest
    static void mergeFieldOrScopeVariableExpressionsCanBeComparedForEquality_equals() {
        Expr.MergeFieldOrScopeVariable aMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field1', null, null)
        );

        Expr.MergeFieldOrScopeVariable anotherMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field1', null, null)
        );

        Assert.isTrue(aMergeField == anotherMergeField);
    }

    @IsTest
    static void mergeFieldOrScopeVariableExpressionsCanBeComparedForEquality_notEquals() {
        Expr.MergeFieldOrScopeVariable aMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field1', null, null)
        );

        Expr.MergeFieldOrScopeVariable anotherMergeField = new Expr.MergeFieldOrScopeVariable(
            new Token(TokenType.IDENTIFIER, 'Field2', null, null)
        );

        Assert.isFalse(aMergeField == anotherMergeField);
    }

    @IsTest
    static void getExpressionsCanBeComparedForEquality_equals() {
        Expr objectExpr = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'obj', null, null),
            Expr.VariableType.LOCAL
        );
        Token field = new Token(TokenType.IDENTIFIER, 'field', null, null);
        List<Expr> arguments = new List<Expr> {
            new Expr.Literal(1),
            new Expr.Literal(2)
        };

        Expr.GetExpr aGetExpr = new Expr.GetExpr(objectExpr, field, arguments);
        Expr.GetExpr anotherGetExpr = new Expr.GetExpr(objectExpr, field, arguments);

        Assert.isTrue(aGetExpr == anotherGetExpr);
    }

    @IsTest
    static void getExpressionsCanBeComparedForEquality_notEquals() {
        Expr objectExpr = new Expr.Variable(
            new Token(TokenType.CUSTOM_VARIABLE, 'obj', null, null),
            Expr.VariableType.LOCAL
        );
        Token field = new Token(TokenType.IDENTIFIER, 'field', null, null);
        List<Expr> arguments = new List<Expr> {
            new Expr.Literal(1),
            new Expr.Literal(2)
        };
        List<Expr> differentArguments = new List<Expr> {
            new Expr.Literal(3),
            new Expr.Literal(4)
        };

        Expr.GetExpr aGetExpr = new Expr.GetExpr(objectExpr, field, arguments);
        Expr.GetExpr anotherGetExpr = new Expr.GetExpr(objectExpr, field, differentArguments);

        Assert.isFalse(aGetExpr == anotherGetExpr);
    }

    @IsTest
    static void unaryExpressionsCanBeComparedForEquality_equals() {
        Token operator = new Token(TokenType.MINUS, '-', null, null);
        Expr right = new Expr.Literal(5);

        Expr.Unary aUnary = new Expr.Unary(operator, right);
        Expr.Unary anotherUnary = new Expr.Unary(operator, right);

        Assert.isTrue(aUnary == anotherUnary);
    }

    @IsTest
    static void unaryExpressionsCanBeComparedForEquality_notEquals() {
        Token operator = new Token(TokenType.MINUS, '-', null, null);
        Expr right = new Expr.Literal(5);
        Expr.Unary aUnary = new Expr.Unary(operator, right);
        Expr.Unary anotherUnary = new Expr.Unary(operator, new Expr.Literal(10));
        Assert.isFalse(aUnary == anotherUnary);
    }

    @IsTest
    static void listLiteralExpressionsCanBeComparedForEquality_equals() {
        List<Expr> elements = new List<Expr> {
            new Expr.Literal(1),
            new Expr.Literal(2),
            new Expr.Literal(3)
        };

        Expr.ListLiteral aListLiteral = new Expr.ListLiteral(elements);
        Expr.ListLiteral anotherListLiteral = new Expr.ListLiteral(elements);

        Assert.isTrue(aListLiteral == anotherListLiteral);
    }

    @IsTest
    static void listLiteralExpressionsCanBeComparedForEquality_notEquals() {
        List<Expr> elements = new List<Expr> {
            new Expr.Literal(1),
            new Expr.Literal(2),
            new Expr.Literal(3)
        };
        List<Expr> differentElements = new List<Expr> {
            new Expr.Literal(4),
            new Expr.Literal(5),
            new Expr.Literal(6)
        };

        Expr.ListLiteral aListLiteral = new Expr.ListLiteral(elements);
        Expr.ListLiteral anotherListLiteral = new Expr.ListLiteral(differentElements);

        Assert.isFalse(aListLiteral == anotherListLiteral);
    }

    @IsTest
    static void mapLiteralExpressionsCanBeComparedForEquality_equals() {
        Expr.KeyValue pair1 = new Expr.KeyValue(
            new Expr.Literal('key1'),
            new Expr.Literal(1)
        );
        Expr.KeyValue pair2 = new Expr.KeyValue(
            new Expr.Literal('key2'),
            new Expr.Literal(2)
        );

        List<Expr.KeyValue> pairs = new List<Expr.KeyValue> { pair1, pair2 };
        Expr.MapLiteral aMapLiteral = new Expr.MapLiteral(pairs);
        Expr.MapLiteral anotherMapLiteral = new Expr.MapLiteral(pairs);

        Assert.isTrue(aMapLiteral == anotherMapLiteral);
    }

    @IsTest
    static void mapLiteralExpressionsCanBeComparedForEquality_notEquals() {
        Expr.KeyValue pair1 = new Expr.KeyValue(
            new Expr.Literal('key1'),
            new Expr.Literal(1)
        );
        Expr.KeyValue pair2 = new Expr.KeyValue(
            new Expr.Literal('key2'),
            new Expr.Literal(2)
        );
        Expr.KeyValue pair3 = new Expr.KeyValue(
            new Expr.Literal('key3'),
            new Expr.Literal(3)
        );
        List<Expr.KeyValue> pairs = new List<Expr.KeyValue> { pair1, pair2 };
        List<Expr.KeyValue> differentPairs = new List<Expr.KeyValue> { pair1, pair3 };

        Expr.MapLiteral aMapLiteral = new Expr.MapLiteral(pairs);
        Expr.MapLiteral anotherMapLiteral = new Expr.MapLiteral(differentPairs);

        Assert.isFalse(aMapLiteral == anotherMapLiteral);
    }

    @IsTest
    static void spreadExpressionsCanBeComparedForEquality_equals() {
        Token spreadToken = new Token(TokenType.SPREAD, '...', null, null);
        Expr innerExpr = new Expr.Literal(10);
        Expr.Spread aSpread = new Expr.Spread(spreadToken, innerExpr);
        Expr.Spread anotherSpread = new Expr.Spread(spreadToken, innerExpr);

        Assert.isTrue(aSpread == anotherSpread);
    }

    @IsTest
    static void spreadExpressionsCanBeComparedForEquality_notEquals() {
        Token spreadToken = new Token(TokenType.SPREAD, '...', null, null);
        Expr innerExpr = new Expr.Literal(10);
        Expr differentInnerExpr = new Expr.Literal(20);
        Expr.Spread aSpread = new Expr.Spread(spreadToken, innerExpr);
        Expr.Spread anotherSpread = new Expr.Spread(spreadToken, differentInnerExpr);

        Assert.isFalse(aSpread == anotherSpread);
    }

    @IsTest
    static void addIfExpressionsCanBeComparedForEquality_equals() {
        Token ifToken = new Token(TokenType.ADD_IF_KEYWORD, 'addIf', null, null);
        Expr condition = new Expr.Literal(true);
        Expr body = new Expr.Literal(50);
        Expr value = new Expr.Literal(100);

        Expr.AddIfExpr aAddIf = new Expr.AddIfExpr(ifToken, condition, body, value);
        Expr.AddIfExpr anotherAddIf = new Expr.AddIfExpr(ifToken, condition, body, value);

        Assert.isTrue(aAddIf == anotherAddIf);
    }

    @IsTest
    static void addIfExpressionsCanBeComparedForEquality_notEquals() {
        Token ifToken = new Token(TokenType.ADD_IF_KEYWORD, 'addIf', null, null);
        Expr condition = new Expr.Literal(true);
        Expr body = new Expr.Literal(50);
        Expr value = new Expr.Literal(100);

        Expr differentBody = new Expr.Literal(75);

        Expr.AddIfExpr aAddIf = new Expr.AddIfExpr(ifToken, condition, body, value);
        Expr.AddIfExpr anotherAddIf = new Expr.AddIfExpr(ifToken, condition, differentBody, value);

        Assert.isFalse(aAddIf == anotherAddIf);
    }

    @IsTest
    static void queryExpressionsCanBeComparedForEquality_equals() {
        Token sObjectType = new Token(TokenType.IDENTIFIER, 'Account', null, null);
        Expr fieldsExpression = new Expr.Literal('Name, Industry');
        List<Expr> orderBy = new List<Expr> { new Expr.Literal('Name ASC') };
        Expr limitExpr = new Expr.Literal(10);
        Expr whereExpr = new Expr.Literal('Industry = \'Technology\'');
        Expr offsetExpr = new Expr.Literal(5);

        Expr.Query aQuery = new Expr.Query(
            sObjectType,
            fieldsExpression,
            orderBy,
            limitExpr,
            whereExpr,
            offsetExpr
        );

        Expr.Query anotherQuery = new Expr.Query(
            sObjectType,
            fieldsExpression,
            orderBy,
            limitExpr,
            whereExpr,
            offsetExpr
        );

        Assert.isTrue(aQuery == anotherQuery);
    }

    @IsTest
    static void queryExpressionsCanBeComparedForEquality_notEquals() {
        Token sObjectType = new Token(TokenType.IDENTIFIER, 'Account', null, null);
        Expr fieldsExpression = new Expr.Literal('Name, Industry');
        List<Expr> orderBy = new List<Expr> { new Expr.Literal('Name ASC') };
        Expr limitExpr = new Expr.Literal(10);
        Expr whereExpr = new Expr.Literal('Industry = \'Technology\'');
        Expr offsetExpr = new Expr.Literal(5);
        Expr differentWhereExpr = new Expr.Literal('Industry = \'Finance\'');

        Expr.Query aQuery = new Expr.Query(
            sObjectType,
            fieldsExpression,
            orderBy,
            limitExpr,
            whereExpr,
            offsetExpr
        );

        Expr.Query anotherQuery = new Expr.Query(
            sObjectType,
            fieldsExpression,
            orderBy,
            limitExpr,
            differentWhereExpr,
            offsetExpr
        );

        Assert.isFalse(aQuery == anotherQuery);
    }
}
