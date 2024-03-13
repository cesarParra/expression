public with sharing class DecoratorPattern {
    // Example 1: payment and logging
    public interface PaymentService {
        PaymentResult pay(PaymentRequest request);
    }

    public class PaymentRequest {
        public Id customerId;
        public Decimal amount;
        public String currency;
    }

    public class PaymentResult {
        public Boolean success;
        public String message;
    }

    public class PaymentServiceImpl implements PaymentService {
        public PaymentResult pay(PaymentRequest request) {
            // do the payment by calling the payment gateway through a REST request
            return new PaymentResult();
        }
    }

    @AuraEnabled
    public static PaymentResult pay(Id customerId, Decimal amount, String currency) {
        PaymentRequest request = new PaymentRequest();
        request.customerId = customerId;
        request.amount = amount;
        request.currency = currency;

        PaymentService paymentService = new PaymentServiceImpl();
        PaymentResult result = paymentService.pay(request);

        return result;
    }
}
