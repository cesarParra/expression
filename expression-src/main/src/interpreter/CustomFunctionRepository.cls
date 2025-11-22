public virtual with sharing class CustomFunctionRepository {
    protected CustomFunctionRepository() {
    }

    @TestVisible private static CustomFunctionRepository mockInstance;
    public static CustomFunctionRepository getInstance() {
        if (Test.isRunningTest() && mockInstance != null) {
            return mockInstance;
        }
        return new CustomFunctionRepository();
    }

    public virtual CustomMetadataExpressionFunction getByName(String functionName) {
        List<Expression_Function__mdt> customFunctions = queryForCustomFunctions(functionName);

        if (customFunctions.isEmpty()) {
            return null;
        }

        Expression_Function__mdt record = customFunctions[0];
        String className = record.Apex_Class__c;
        Object objectInstance = Type.forName(className).newInstance();
        if (objectInstance instanceof IExpressionFunction) {
            return new CustomMetadataExpressionFunction((IExpressionFunction) objectInstance, record.CacheResult__c ?? false);
        } else {
            throw new CustomFunctionException(
                'Error executing ' + functionName + ' function: The class ' +
                    className + ' does not implement the IExpressionFunction interface.'
            );
        }
    }

    private static List<Expression_Function__mdt> queryForCustomFunctions(String functionName) {
        Q query = new Q(Expression_Function__mdt.SObjectType)
            .selectFields(new Set<String> { 'Apex_Class__c', 'CacheResult__c' } )
            .add(Q.condition('DeveloperName').equalsTo(functionName));
        return QDB.getInstance().run(query);
    }

    public class CustomFunctionException extends Exception {
    }
}
