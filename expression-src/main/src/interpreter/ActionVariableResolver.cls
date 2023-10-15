public with sharing class ActionVariableResolver implements IGlobalVariableResolver {
    public Object get(String referenceName, List<Object> args) {
        switch on referenceName.toLowerCase() {
            when 'apex' {
                return new ApexAction();
            }
            when 'flow' {
                throw new ActionVariableResolverException('Flow actions are not yet supported');
            }
            when 'lwc' {
                return new LwcAction();
            }
            when else {
                throw new ActionVariableResolverException('Unknown action reference: ' + referenceName);
            }
        }
    }

    private class ApexAction implements IGlobalVariableResolver {
        // Known limitation: Only top level class names without namespaces are supported.
        public Object get(String className, List<Object> args) {
            // Check if the class exists and it is a Callable
            Type t = Type.forName(className);
            if (t == null)  {
                throw new ActionVariableResolverException('Unknown class: ' + className);
            } else if (!IExpressionFunction.class.isAssignableFrom(t)) {
                throw new ActionVariableResolverException('Class ' + className + ' is not a IExpressionFunction');
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
                    Map<String, Object> returnMap = buildLwcActionMap(args);
                    returnMap.put('type', 'navigate__namedPage');
                    return returnMap;
                }
                when 'gotourl' {
                    Map<String, Object> returnMap = buildLwcActionMap(args);
                    returnMap.put('type', 'navigate__url');
                    return returnMap;
                }
                when else {
                    throw new ActionVariableResolverException('Unknown LWC action: ' + referenceName);
                }
            }
        }

        private Map<String, Object> buildLwcActionMap(List<Object> args) {
            Map<Object, Object> navigateArgs = (Map<Object, Object>) args[0];

            // Must contain the "name" key
            if (!navigateArgs.containsKey('name')) {
                throw new ActionVariableResolverException('Missing "name" key in navigate args');
            }

            Map<Object, Object> extraArgs = new Map<Object, Object>();
            for (Object key : navigateArgs.keySet()) {
                if (key != 'name') {
                    extraArgs.put(key, navigateArgs.get(key));
                }
            }

            return new Map<String, Object>{
                'name' => (String) navigateArgs.get('name'),
                'args' => extraArgs
            };
        }
    }

    public class ActionVariableResolverException extends Exception {}
}
