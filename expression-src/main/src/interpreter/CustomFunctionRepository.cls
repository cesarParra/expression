public virtual with sharing class CustomFunctionRepository {
    protected CustomFunctionRepository() {}

    @TestVisible private static CustomFunctionRepository mockInstance;
    public static CustomFunctionRepository getInstance() {
        if (Test.isRunningTest() && mockInstance != null) {
            return mockInstance;
        }
        return new CustomFunctionRepository();
    }

    public virtual IExpressionFunction getByName(String functionName) {
        List<Expression_Function__mdt> customFunctions = [
            SELECT
                Apex_Class__c
            FROM Expression_Function__mdt
            WHERE DeveloperName = :functionName
        ];

        if (customFunctions.isEmpty()) {
            return null;
        }

        String className = customFunctions[0].Apex_Class__c;
        Object objectInstance = Type.forName(className).newInstance();
        if (objectInstance instanceof IExpressionFunction) {
            return (IExpressionFunction) objectInstance;
        } else {
            throw new Interpreter.InterpreterException(
                'Error executing ' + functionName + ' function: The class ' +
                    className + ' does not implement the IExpressionFunction interface.'
            );
        }
    }
}
