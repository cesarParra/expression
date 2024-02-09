public with sharing class ReceiptBuilderFactory {
    public static BuilderPattern.ReceiptBuilder getBuilder(BuilderPattern.ReceiptType receiptType) {
        if (receiptType == BuilderPattern.ReceiptType.PRINTED) {
            return new BuilderPattern.PrintedReceiptBuilder();
        } else if (receiptType == BuilderPattern.ReceiptType.EMAIL) {
            return new BuilderPattern.EmailReceiptBuilder();
        }

        throw new UnreachableCodeException();
    }

    public class UnreachableCodeException extends Exception {}
}
