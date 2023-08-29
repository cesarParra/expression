public with sharing class StringFunctions {
    public static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'BEGINS' => new StringFunctions.Begins(),
        'CONTAINS' => new StringFunctions.Contains(),
        'LOWER' => new StringFunctions.Lower(),
        'FIND' => new StringFunctions.FindFn(),
        'LEFT' => new StringFunctions.LeftFn(),
        'LEN' => new StringFunctions.LenFn(),
        'LPAD' => new StringFunctions.LRPad('LPAD'),
        'RPAD' => new StringFunctions.LRPad('RPAD'),
        'REVERSE' => new StringFunctions.ReverseFn(),
        'MID' => new StringFunctions.MidFn(),
        'SUBSTRING' => new StringFunctions.SubstringFn(),
        'RIGHT' => new StringFunctions.RightFn(),
        'BR' => new StringFunctions.BrFn(),
        'HYPERLINK' => new HyperLinkFn(),
        'SUBSTITUTE' => new SubstituteFn(),
        'TEXT' => new TextFn(),
        'TRIM' => new TrimFn(),
        'UPPER' => new UpperFn()
    };

    private class Begins extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "BEGINS" function: the argument must evaluate to a string value.'
                );
            }

            Object prefix = evaluate(arguments.get(1));
            if (!(prefix instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "BEGINS" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).startsWith((String) prefix);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class Contains extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "CONTAINS" function: the argument must evaluate to a string value.'
                );
            }

            Object substring = evaluate(arguments.get(1));
            if (!(substring instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "CONTAINS function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).contains((String) substring);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class Lower extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LOWER" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).toLowerCase();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class FindFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object searchText = evaluate(arguments.get(0));
            if (!(searchText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "FIND" function: the argument must evaluate to a string value.'
                );
            }

            Object text = evaluate(arguments.get(1));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "FIND" function: the argument must evaluate to a string value.'
                );
            }

            // There might be an optional third argument for the starting index, if there isn't one, it defaults to 0.
            Integer startIndex = 0;
            if (arguments.size() > 2) {
                Object startIndexValue = evaluate(arguments.get(2));
                if (!(startIndexValue instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "FIND" function: the argument must evaluate to a number value.'
                    );
                }
                startIndex = ((Decimal) startIndexValue).intValue();
            }

            return ((String) text).indexOf((String) searchText, startIndex);
        }

        public override Arity getArity() {
            return Arity.between(2, 3);
        }
    }

    private class LeftFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LEFT" function: the argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LEFT" function: the argument must evaluate to a number value.'
                );
            }

            return ((String) text).substring(0, ((Decimal) length).intValue());
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class LenFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "LEN" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).length();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class LRPad extends ExpressionFunction {
        private final String name;

        public LRPad(String name) {
            this.name = name;
        }

        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + name + ' function: the first argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing ' + name + ' function: the second argument must evaluate to a number value.'
                );
            }

            Object padString = ' ';
            if (arguments.size() > 2) {
                padString = evaluate(arguments.get(2));
                if (!(padString instanceof String)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing ' + name + ' function: the third argument must evaluate to a string value.'
                    );
                }
            }

            if (name == 'LPAD') {
                return ((String) padString).repeat(((Decimal) length).intValue() - ((String) text).length()) + (String) text;
            } else {
                return (String) text + ((String) padString).repeat(((Decimal) length).intValue() - ((String) text).length());
            }
        }

        public override Arity getArity() {
            return Arity.between(2, 3);
        }
    }

    private class ReverseFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "REVERSE" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) text).reverse();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class MidFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MID" function: the first argument must evaluate to a string value.'
                );
            }

            Object start = evaluate(arguments.get(1));
            if (!(start instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MID" function: the second argument must evaluate to a number value.'
                );
            }

            Object length = evaluate(arguments.get(2));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "MID" function: the third argument must evaluate to a number value.'
                );
            }

            return ((String) text).substring(((Decimal) start).intValue() - 1, ((Decimal) start).intValue() - 1 + ((Decimal) length).intValue());
        }

        public override Arity getArity() {
            return Arity.exactly(3);
        }
    }

    private class SubstringFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTRING" function: the first argument must evaluate to a string value.'
                );
            }

            Object start = evaluate(arguments.get(1));
            if (!(start instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTRING" function: the second argument must evaluate to a number value.'
                );
            }

            // Third argument is optional
            Object length = null;
            if (arguments.size() > 2) {
                length = evaluate(arguments.get(2));
                if (!(length instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "SUBSTRING" function: the third argument must evaluate to a number value.'
                    );
                }
            }

            if (length == null) {
                return ((String) text).substring(((Decimal) start).intValue() - 1);
            } else {
                return ((String) text).substring(((Decimal) start).intValue() - 1, ((Decimal) start).intValue() - 1 + ((Decimal) length).intValue());
            }
        }

        public override Arity getArity() {
            return Arity.between(2, 3);
        }
    }

    private class RightFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "RIGHT: function: the first argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "RIGHT" function: the second argument must evaluate to a number value.'
                );
            }

            // If the number is less than 0, force it to 0
            Integer lengthAsInteger = ((Decimal) length).intValue();
            if (lengthAsInteger < 0) {
                lengthAsInteger = 0;
            }

            return ((String) text).right(lengthAsInteger);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class BrFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Integer linesToAdd = 1;
            // If an argument was passed, then it must be a number
            if (arguments.size() > 0) {
                Object linesToAddValue = evaluate(arguments.get(0));
                if (!(linesToAddValue instanceof Decimal)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "BR" function: the argument must evaluate to a number value.'
                    );
                }
                linesToAdd = ((Decimal) linesToAddValue).intValue();
            }

            if (Request.getCurrent().getQuiddity() == Quiddity.AURA || Request.getCurrent().getQuiddity() == Quiddity.VF) {
                return '<br/>'.repeat(linesToAdd);
            }
            return '\n'.repeat(linesToAdd);
        }

        public override Arity getArity() {
            return Arity.between(0, 1);
        }
    }

    /**
     * @description Creates a link to a URL specified that is linkable from the text specified.
     */
    private class HyperLinkFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expected arguments:
            // 1. Url
            // 2. Friendly text
            // 3. Option - target

            // Check that there is at least 2 arguments
            if (arguments.size() < 2) {
                throw new Interpreter.InterpreterException(
                    'Error executing "HYPERLINK" function: the function must have at least 2 arguments.'
                );
            }

            // Check that the first argument is a string
            Object url = evaluate(arguments.get(0));
            if (!(url instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "HYPERLINK" function: the first argument must evaluate to a string value.'
                );
            }

            // Check that the second argument is a string
            Object friendlyText = evaluate(arguments.get(1));
            if (!(friendlyText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "HYPERLINK" function: the second argument must evaluate to a string value.'
                );
            }

            // Check that the third argument is a string (if present)
            Object target = null;
            if (arguments.size() > 2) {
                target = evaluate(arguments.get(2));
                if (!(target instanceof String)) {
                    throw new Interpreter.InterpreterException(
                        'Error executing "HYPERLINK" function: the third argument must evaluate to a string value.'
                    );
                }
            }

            // Create the link
            String link = '<a href="' + (String) url + '"';
            if (target != null) {
                link += ' target="' + (String) target + '"';
            }
            link += '>' + (String) friendlyText + '</a>';

            return link;
        }

        public override Arity getArity() {
            return Arity.between(2, 3);
        }
    }

    private class SubstituteFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expected arguments:
            // 1. text
            // 2. old text
            // 3. new text

            // Check that there is at least 3 arguments
            if (arguments.size() < 3) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the function must have at least 3 arguments.'
                );
            }

            // Check that the first argument is a string
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the first argument must evaluate to a string value.'
                );
            }

            // Check that the second argument is a string
            Object oldText = evaluate(arguments.get(1));
            if (!(oldText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the second argument must evaluate to a string value.'
                );
            }

            // Check that the third argument is a string
            Object newText = evaluate(arguments.get(2));
            if (!(newText instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "SUBSTITUTE" function: the third argument must evaluate to a string value.'
                );
            }

            // Replace all occurrences of the old text with the new text
            return ((String) text).replaceAll((String) oldText, (String) newText);
        }

        public override Arity getArity() {
            return Arity.exactly(3);
        }
    }

    private class TextFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TEXT" function: the function must have exactly 1 argument.'
                );
            }

            Object value = evaluate(arguments.get(0));
            if (value == null) {
                return '';
            }

            if (value instanceof Decimal) {
                return ((Decimal) value).format();
            } else if (value instanceof Date) {
                return ((Date) value).format();
            } else if (value instanceof Datetime) {
                return ((Datetime) value).format();
            } else if (value instanceof Boolean) {
                return ((Boolean) value) ? 'true' : 'false';
            } else if (value instanceof Time) {
                Time timeValue = (Time) value;
                Datetime dt = Datetime.newInstance(
                    1970,
                    1,
                    1,
                    timeValue.hour(),
                    timeValue.minute(),
                    timeValue.second()
                );
                return dt.format('hh:mm:ss a').replace(dt.date().format(), '').trim();
            } else {
                return String.valueOf(value);
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class TrimFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TRIM" function: the function must have exactly 1 argument.'
                );
            }

            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "TRIM" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) value).trim();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class UpperFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // Expect 1 argument
            if (arguments.size() != 1) {
                throw new Interpreter.InterpreterException(
                    'Error executing "UPPER" function: the function must have exactly 1 argument.'
                );
            }

            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new Interpreter.InterpreterException(
                    'Error executing "UPPER" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) value).toUpperCase();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }
}
