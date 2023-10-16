public with sharing class PriceComponents {
    private final List<PriceComponent> components;

    public PriceComponents(List<PriceComponent> components) {
        System.debug('PriceComponents: ' + components);
        this.components = components;
    }

    public PriceComponent getListPrice() {
        for (PriceComponent current : components) {
            if (current.pricingType == PriceComponent.Type.LIST_PRICE) {
                return current;
            }
        }
        return null;
    }

    public List<PriceComponent> getSurcharges() {
        List<PriceComponent> result = new List<PriceComponent>();
        for (PriceComponent current : components) {
            if (current.pricingType == PriceComponent.Type.SURCHARGE) {
                result.add(current);
            }
        }
        return result;
    }

    public List<PriceComponent> getDiscounts() {
        List<PriceComponent> result = new List<PriceComponent>();
        for (PriceComponent current : components) {
            if (current.pricingType == PriceComponent.Type.DISCOUNT) {
                result.add(current);
            }
        }
        return result;
    }
}
