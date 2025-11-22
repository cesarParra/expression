public with sharing class PriceComponents {
    private final List<PriceComponent> components;

    public PriceComponents(List<PriceComponent> components) {
        this.components = components;
    }

    public List<PriceComponent> getListPrices() {
        List<PriceComponent> result = new List<PriceComponent>();
        for (PriceComponent current : components) {
            if (current.pricingType == PriceComponent.Type.LIST_PRICE) {
                result.add(current);
            }
        }
        return result;
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
