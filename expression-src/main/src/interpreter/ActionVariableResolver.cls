public with sharing class ActionVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName) {
        switch on referenceName.toLowerCase() {
            when 'apex' {
                return new ApexAction();
            }
            when 'flow' {
                // TODO
                throw new Interpreter.InterpreterException('Flow actions are not yet supported');
            }
            when else {
                throw new Interpreter.InterpreterException('Unknown action reference: ' + referenceName);
            }
        }
    }

    private class ApexAction implements IGlobalVariableResolver {
        public Object get(String className) {
            // Check if the class exists and it is a Callable
            Type t = Type.forName(className);
            if (t == null)  {
                throw new Interpreter.InterpreterException('Unknown class: ' + className);
            } else if (!IExpressionFunction.class.isAssignableFrom(t)) {
                throw new Interpreter.InterpreterException('Class ' + className + ' is not a IExpressionFunction');
            }

            return className;
        }
    }
}
