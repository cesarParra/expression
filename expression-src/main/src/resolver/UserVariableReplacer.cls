public with sharing class UserVariableReplacer {
    public static String replace(
            String input,
            List<UserVariable> variables,
            Map<String, Object> overrides
            ) {
        List<UserVariable> variablesWithoutOverrides = removeOverrides(variables, overrides);
        List<UserVariable> resolvedVariables = resolveVariables(variablesWithoutOverrides);

        for (UserVariable variable : resolvedVariables) {
            input = replaceIgnoreCase(input, '@' + variable.name, variable.value);
        }
        return input;
    }

    private static List<UserVariable> removeOverrides(
            List<UserVariable> variables,
            Map<String, Object> overrides
            ) {
        List<UserVariable> variablesWithoutOverrides = new List<UserVariable>();
        for (UserVariable variable : variables) {
            if (!overrides.containsKey(variable.name)) {
                variablesWithoutOverrides.add(variable);
            }
        }
        return variablesWithoutOverrides;
    }

    private static String replaceIgnoreCase(String input, String search, String replacement) {
        return input.replaceAll('(?i)' + search, replacement);
    }

    private static List<UserVariable> resolveVariables(List<UserVariable> variables) {
        List<UserVariable> resolvedVariables = new List<UserVariable>();
        for (UserVariable variable : variables) {
            UserVariable resolvedVariable =
                    new UserVariable(variable.name, replaceVariables(variable.value, variables));
            resolvedVariables.add(resolvedVariable);
        }
        return resolvedVariables;
    }

    private static String replaceVariables(String input, List<UserVariable> variables) {
        for (UserVariable variable : variables) {
            input = replaceIgnoreCase(input, '@' + variable.name, variable.value);
        }
        return input;
    }
}