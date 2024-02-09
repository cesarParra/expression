public with sharing class BuilderPattern {
    public interface Receipt {
        void process();
    }

    public class PrintReceipt implements Receipt {
        public PrintReceipt(String header, String footer, String body, Double total, Double tax, List<String> items, String customer) {
            // Validate information
            // Build out the receipt
        }

        public void process() {
            // PrinterRestService.send('receipt');
        }
    }

    public class EmailReceipt implements Receipt {
        private final String email;
        private final String emailToSend;

        public EmailReceipt(String email, String header, String footer, String body, Double total, Double tax, List<String> items, String customer) {
            // Validate information
            // Build out the HTML for the email
        }

        public void process() {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { email });
            mail.setSubject('Receipt');
            mail.setHtmlBody(emailToSend);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public interface ReceiptBuilder {
        void setHeader(String header);
        void setFooter(String footer);
        void setBody(String body);
        void setTotal(Double total);
        void setTax(Double tax);
        void setItems(List<String> items);
        void setCustomer(String customer);
        void setEmail(String email);
        Receipt build();
    }

    public class PrintedReceiptBuilder implements ReceiptBuilder {
        private String header;
        private String footer;
        private String body;
        private Double total;
        private Double tax;
        private List<String> items;
        private String customer;

        public void setHeader(String header) {
            this.header = header;
        }

        public void setFooter(String footer) {
            this.footer = footer;
        }

        public void setBody(String body) {
            this.body = body;
        }

        public void setTotal(Double total) {
            this.total = total;
        }

        public void setTax(Double tax) {
            this.tax = tax;
        }

        public void setItems(List<String> items) {
            this.items = items;
        }

        public void setCustomer(String customer) {
            this.customer = customer;
        }

        public void setEmail(String email) {
            // Do nothing
        }

        public Receipt build() {
            return new PrintReceipt(header, footer, body, total, tax, items, customer);
        }
    }

    public class EmailReceiptBuilder implements ReceiptBuilder {
        private String header;
        private String footer;
        private String body;
        private Double total;
        private Double tax;
        private List<String> items;
        private String customer;
        private String email;

        public void setHeader(String header) {
            this.header = header;
        }

        public void setFooter(String footer) {
            this.footer = footer;
        }

        public void setBody(String body) {
            this.body = body;
        }

        public void setTotal(Double total) {
            this.total = total;
        }

        public void setTax(Double tax) {
            this.tax = tax;
        }

        public void setItems(List<String> items) {
            this.items = items;
        }

        public void setCustomer(String customer) {
            this.customer = customer;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public Receipt build() {
            return new EmailReceipt(email, header, footer, body, total, tax, items, customer);
        }
    }

    public enum ReceiptType {
        PRINTED,
        EMAIL
    }

    public static void sendReceipt(ReceiptType type, String header, String footer, String body, Double total, Double tax, List<String> items, String customer, String email) {
        // Unclean 1:
//        if (type == ReceiptType.PRINTED) {
//            String printedReceipt = '';
//            printedReceipt += header;
//            printedReceipt += footer;
//            printedReceipt += body;
//            printedReceipt += total;
//            printedReceipt ...;
//
//            PrinterRestService.send(printedReceipt);
//        } else {
//            String emailToSend = '';
//            emailToSend += '<html>' + header + footer + body + total + ... + '</html>';
//
//            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//            mail.setToAddresses(new String[] { email });
//            mail.setSubject('Receipt');
//            mail.setHtmlBody(emailToSend);
//            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
//        }

        // Not clean way 2:
        // if (type == ReceiptType.PRINTED) {
        //     PrintReceipt receipt = new PrintReceipt(header, footer, body, total, tax, items, customer);
        //     receipt.process();
        // } else {
        //     EmailReceipt receipt = new EmailReceipt(email, header, footer, body, total, tax, items, customer);
        //     receipt.process();
        // }

        // Clean way:
//        ReceiptBuilder builder = ReceiptBuilderFactory.getBuilder(type);
//        builder.setHeader(header);
//        builder.setFooter(footer);
//        builder.setBody(body);
//        builder.setTotal(total);
//        builder.setTax(tax);
//        builder.setItems(items);
//        builder.setCustomer(customer);
//        builder.setEmail(email);
//
//        Receipt receipt = builder.build();
//        receipt.process();
    }

    // Extra pattern: Null Object Pattern
    // Extra use case: SObject Test Data creation + fluent interface (more of a style rather than a pattern)
}
