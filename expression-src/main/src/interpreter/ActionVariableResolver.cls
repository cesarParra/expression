public with sharing class ActionVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        switch on referenceName.toLowerCase() {
            when 'apex' {
                return new ApexAction();
            }
            when 'flow' {
                throw new Interpreter.InterpreterException('Flow actions are not yet supported');
            }
            when 'lwc' {
                return new LwcAction();
            }
            when else {
                throw new Interpreter.InterpreterException('Unknown action reference: ' + referenceName);
            }
        }
    }

    private class ApexAction implements IGlobalVariableResolver {
        // Known limitation: Only top level class names without namespaces are supported.
        public Object get(String className, List<Object> args) {
            // Check if the class exists and it is a Callable
            Type t = Type.forName(className);
            if (t == null)  {
                throw new Interpreter.InterpreterException('Unknown class: ' + className);
            } else if (!IExpressionFunction.class.isAssignableFrom(t)) {
                throw new Interpreter.InterpreterException('Class ' + className + ' is not a IExpressionFunction');
            }

            return new Map<String, Object> {
                'class' => className,
                'args' => args
            };
        }
    }

    private class LwcAction implements IGlobalVariableResolver {
        public Object get(String referenceName, List<Object> args) {
            switch on referenceName.toLowerCase()   {
                when 'gotonamedpage' {
                    Map<Object, Object> navigateArgs = (Map<Object, Object>) args[0];

                    // Must contain the "name" key
                    if (!navigateArgs.containsKey('name')) {
                        throw new Interpreter.InterpreterException('Missing "name" key in navigate args');
                    }

                    Map<Object, Object> extraArgs = new Map<Object, Object>();
                    for (Object key : navigateArgs.keySet()) {
                        if (key != 'name') {
                            extraArgs.put(key, navigateArgs.get(key));
                        }
                    }

                    return new Map<String, Object> {
                        'type' => 'navigate__namedPage',
                        'name' => (String) navigateArgs.get('name'),
                        'args' => extraArgs
                    };
                }
                when else {
                    throw new Interpreter.InterpreterException('Unknown LWC action: ' + referenceName);
                }
            }
        }
    }
}
