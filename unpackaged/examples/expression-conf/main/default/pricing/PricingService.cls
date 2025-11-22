public with sharing class PricingService {
    public PriceComponents calculate(Id productId, List<PriceComponent> components) {
        List<PriceComponent> evaluatedComponents = new List<PriceComponent>();

        Configuration config = new Configuration()
            .respectSharing(false)
            .withCustomContext(new Map<String, Object> {
                'ProductId' => productId
            });
        for (PriceComponent componentToEvaluate : components) {
            Boolean result = (Boolean)Evaluator.run(componentToEvaluate.expression, config);
            if (result) {
                evaluatedComponents.add(componentToEvaluate);
            }
        }
        return new PriceComponents(evaluatedComponents);
    }
}
