@IsTest
private class LocationFunctionsTest {
    @IsTest
    private static void locationFunctionReturnsALocation() {
        String formula = 'LOCATION(28.635308,77.22496)';
        Object result = Evaluator.run(formula);

        System.Location expected = System.Location.newInstance(28.635308, 77.22496);
        Assert.areEqual(expected.latitude, ((System.Location)result).latitude);
        Assert.areEqual(expected.longitude, ((System.Location)result).longitude);
    }

    @IsTest
    private static void locationFunctionThrowsRuntimeExceptionWhenFirstArgumentIsNotDecimal() {
        String formula = 'LOCATION("28.635308",77.22496)';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void locationFunctionThrowsRuntimeExceptionWhenSecondArgumentIsNotDecimal() {
        String formula = 'LOCATION(28.635308,"77.22496")';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void distanceFunctionReturnsADecimal() {
        String formula = 'DISTANCE(LOCATION(28.635308,77.22496), LOCATION(28.635308,77.22496), "mi")';
        Object result = Evaluator.run(formula);

        Assert.areEqual(0.0, (Decimal)result);
    }

    @IsTest
    private static void distanceFunctionThrowsRuntimeExceptionWhenFirstArgumentIsNotLocation() {
        String formula = 'DISTANCE("LOCATION(28.635308,77.22496)", LOCATION(28.635308,77.22496), "mi")';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void distanceFunctionThrowsRuntimeExceptionWhenSecondArgumentIsNotLocation() {
        String formula = 'DISTANCE(LOCATION(28.635308,77.22496), "LOCATION(28.635308,77.22496)", "mi")';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void distanceFunctionThrowsRuntimeExceptionWhenThirdArgumentIsNotString() {
        String formula = 'DISTANCE(LOCATION(28.635308,77.22496), LOCATION(28.635308,77.22496), 1)';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void distanceFunctionThrowsRuntimeExceptionWhenThirdArgumentIsNot_mi_or_km() {
        String formula = 'DISTANCE(LOCATION(28.635308,77.22496), LOCATION(28.635308,77.22496), "miles")';
        try {
            Evaluator.run(formula);
            Assert.fail('Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }
}
