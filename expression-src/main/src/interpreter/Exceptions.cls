public with sharing class Exceptions {
    public abstract class PositionAwareException extends Exception {
        public final SourcePosition position;
        public final String message;

        public PositionAwareException(SourcePosition position, String message) {
            super.setMessage(message);
            this.position = position;
            this.message = message;
        }

        public override String getMessage() {
            return
                this.getType() + ' Error: ' + '\n' +
                    this.message + '\n' +
                    'Line: ' + this.position.lineStart + ' Column: ' + this.position.columnStart;
        }

        public virtual override String toString() {
            return this.getMessage();
        }

        public abstract String getType();
    }

    public class ParsingException extends PositionAwareException {
        public ParsingException(SourcePosition position, String message) {
            super(position, message);
        }

        public ParsingException(Token atToken, String message) {
            super(atToken.position, message);
        }

        public override String toString() {
            return super.toString();
        }

        public override String getType() {
            return 'Parsing';
        }
    }

    public class RuntimeException extends PositionAwareException {
        public RuntimeException(Token atToken, String message) {
            super(atToken?.position ?? new SourcePosition(1, 1, 1), message);
        }

        public override String toString() {
            return super.toString();
        }

        public override String getType() {
            return 'Runtime';
        }
    }
}
