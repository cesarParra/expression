public abstract class FunctionCaller {
    private final Expr.FunctionCall function;
    protected abstract Object call(Interpreter interpreter);

    public FunctionCaller(Expr.FunctionCall function) {
        this.function = function;
    }

    private static FunctionCaller find(Expr.FunctionCall function, Environment env) {
        if (env.hasFunction(function.functionName)) {
            return new FunctionDeclarationCaller(function);
        } else if (StandardFunction.functionExistsInStandardLibrary(function.functionName)) {
            // TODO: Also cache standard functions
            return new StandardLibraryFunctionCaller(function);
        }

        IExpressionFunction fn = CustomFunctionRepository.getInstance().getByName(function.functionName);
        if (fn != null) {
            return new CustomMetadataFunctionCaller(function, fn);
        }


        return new NotFoundFunctionCaller(function);
    }

    public static Object exec(Interpreter interpreter, Expr.FunctionCall function) {
        FunctionCaller functionCaller = find(function, interpreter.getEnvironment());
        return functionCaller.call(interpreter);
    }

    private class FunctionDeclarationCaller extends FunctionCaller {
        public FunctionDeclarationCaller(Expr.FunctionCall function) {
            super(function);
        }

        public override Object call(Interpreter interpreter) {
            Expr.FunctionDeclaration functionDeclaration = interpreter.getEnvironment().getFunction(function.functionName);
            ArityEvaluator.check(functionDeclaration, function);

            Environment functionScopeEnvironment = new Environment(interpreter.getEnvironment());

            for (Integer i = 0; i < functionDeclaration.parameters.size(); i++) {
                functionScopeEnvironment.define(
                    functionDeclaration.parameters.get(i).lexeme,
                    interpreter.interpret(function.arguments.get(i))
                );
            }

            if (functionDeclaration.isCachedForEnvironment(functionScopeEnvironment)) {
                return functionDeclaration.getCachedValueForEnvironment(functionScopeEnvironment);
            }

            Interpreter functionInterpreter = new Interpreter(functionScopeEnvironment);
            Object value = functionInterpreter.interpret(functionDeclaration.body);
            functionDeclaration.cache(functionScopeEnvironment, value);
            return value;
        }
    }

    private class StandardLibraryFunctionCaller extends FunctionCaller {
        public StandardLibraryFunctionCaller(Expr.FunctionCall function) {
            super(function);
        }

        public override Object call(Interpreter interpreter) {
            // Check if the function is in the list of supported functions
            StandardFunction fn = StandardFunction.getByName(function.functionName);
            fn.setInterpreter(interpreter);
            ArityEvaluator.check(fn, function);

            try {
                return fn.call(function.arguments);
            } catch (Exceptions.PositionAwareException e) {
                throw e;
            } catch (Exception e) {
                throw new Exceptions.RuntimeException(
                    function.functionToken,
                    e.getMessage()
                );
            }
        }
    }

    private class CustomMetadataFunctionCaller extends FunctionCaller {
        private final IExpressionFunction fn;
        public CustomMetadataFunctionCaller(Expr.FunctionCall function, IExpressionFunction fn) {
            super(function);
            this.fn = fn;
        }

        public override Object call(Interpreter interpreter) {
            List<Object> arguments = new List<Object>();
            for (Expr argument : function.arguments) {
                arguments.add(interpreter.interpret(argument));
            }

            try {
                return fn.execute(arguments);
            } catch (Exceptions.PositionAwareException e) {
                throw e;
            } catch (Exception e) {
                throw new Exceptions.RuntimeException(
                    function.functionToken,
                    e.getMessage()
                );
            }
        }
    }

    private class NotFoundFunctionCaller extends FunctionCaller {
        public NotFoundFunctionCaller(Expr.FunctionCall function) {
            super(function);
        }

        public override Object call(Interpreter interpreter) {
            throw new Exceptions.RuntimeException(
                function.functionToken,
                'Error executing ' + function.functionName + ' function: the function is not supported.'
            );
        }
    }
}
