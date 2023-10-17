public with sharing class Exceptions {
    public class RuntimeException extends Exception {
        public final Token atToken;
        public final String message;

        public RuntimeException(Token atToken, String message) {
            super.setMessage(message);
            this.atToken = atToken;
            this.message = message;
        }

        public override String getMessage() {
            return this.message + '\n' +
                'Line: ' + this.atToken.position.line + ' Column: ' + this.atToken.position.column;
        }

        public String toString() {
            return this.getMessage();
        }
    }
}
