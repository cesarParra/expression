@IsTest
private class CustomLabelGlobalVariableTest {
    @IsTest
    private static void canEvaluateCustomLabels() {
        LabelWrapper.mockLabel = new DummyLabel();
        String formula = '$Label.c.MyLabelName';
        Assert.areEqual('Value', Evaluator.run(formula));
    }

    private class DummyLabel implements LabelWrapper.ILabel {
        public String get(String namespace, String label, String language) {
            return 'Value';
        }
    }
}
