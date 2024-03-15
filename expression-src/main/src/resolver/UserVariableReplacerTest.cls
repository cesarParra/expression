@IsTest
private class UserVariableReplacerTest {    @IsTest
    static void stringWithNoVariablesReturnTheSameString() {
        String input = 'Hello World';
        String output = UserVariableReplacer.replace(input, new List<UserVariable>(), new Map<String, Object>());
        System.assertEquals(input, output);
    }

    @IsTest
    static void stringWithVariableReturnsTheVariableValue() {
        String input = '1 + @someConst';
        UserVariable variable = new UserVariable('someConst', '2');
        String output = UserVariableReplacer.replace(input, new List<UserVariable>{variable}, new Map<String, Object>());
        System.assertEquals('1 + 2', output);
    }

    @IsTest
    static void stringWithVariableReturnsTheVariableValue_ignoresCase() {
        String input = '1 + @SOMECONST';
        UserVariable variable = new UserVariable('someConst', '2');
        String output = UserVariableReplacer.replace(input, new List<UserVariable>{variable}, new Map<String, Object>());
        System.assertEquals('1 + 2', output);
    }

    @IsTest
    static void stringWithVariablesThatReferenceOtherVariablesAreCorrectlyReplaced() {
        String input = '1 + @someConst + @someOtherConst';
        UserVariable variable1 = new UserVariable('someConst', '2');
        UserVariable variable2 = new UserVariable('someOtherConst', '3 + @someConst');
        String output = UserVariableReplacer.replace(input, new List<UserVariable>{
                variable1, variable2
        }, new Map<String, Object>());
        System.assertEquals('1 + 2 + 3 + 2', output);
    }

    @IsTest
    static void variableOverridesAreIgnored() {
        String input = '1 + @someConst';
        UserVariable variable = new UserVariable('someConst', '2');
        String output = UserVariableReplacer.replace(input, new List<UserVariable>{variable}, new Map<String, Object>{'someConst' => '3'});
        System.assertEquals('1 + @someConst', output);
    }
}