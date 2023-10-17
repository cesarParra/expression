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
        List<Expression_Function__mdt> customFunctions = queryForCustomFunctions(functionName);

        if (customFunctions.isEmpty()) {
            return null;
        }

        String className = customFunctions[0].Apex_Class__c;
        Object objectInstance = Type.forName(className).newInstance();
        if (objectInstance instanceof IExpressionFunction) {
            return (IExpressionFunction) objectInstance;
        } else {
            throw new CustomFunctionException(
                'Error executing ' + functionName + ' function: The class ' +
                    className + ' does not implement the IExpressionFunction interface.'
            );
        }
    }

    private static List<Expression_Function__mdt> queryForCustomFunctions(String functionName) {
        Q query = new Q(Expression_Function__mdt.SObjectType)
            .selectField('Apex_Class__c')
            .add(Q.condition('DeveloperName').equalsTo(functionName));
        return QRunner.getInstance().run(query);
    }

    public class CustomFunctionException extends Exception {
    }
}
