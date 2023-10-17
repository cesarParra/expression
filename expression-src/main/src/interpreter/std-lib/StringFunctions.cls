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
        'UPPER' => new UpperFn(),
        'VALUE' => new ValueFn(),
        'SPLIT' => new SplitFn(),
        'INITCAP' => new InitCapFn(),
        'URLENCODE' => new UrlEncodeFn()
    };

    private class Begins extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "BEGINS" function: the argument must evaluate to a string value.'
                );
            }

            Object prefix = evaluate(arguments.get(1));
            if (!(prefix instanceof String)) {
                throw new FunctionExecutionException(
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
            Object firstValue = evaluate(arguments.get(0));
            if (!(firstValue instanceof String) && !(firstValue instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "CONTAINS" function: the argument must evaluate to a string or list value.'
                );
            }

            // When dealing with text
            if (firstValue instanceof String) {
                Object substring = evaluate(arguments.get(1));
                if (!(substring instanceof String)) {
                    throw new FunctionExecutionException(
                        'Error executing "CONTAINS" function: the argument must evaluate to a string value.'
                    );
                }

                return ((String) firstValue).contains((String) substring);
            }

            // When dealing with lists
            Object value = evaluate(arguments.get(1));
            List<Object> castList = (List<Object>) firstValue;
            return castList.contains(value);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class Lower extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new FunctionExecutionException(
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
                throw new FunctionExecutionException(
                    'Error executing "FIND" function: the argument must evaluate to a string value.'
                );
            }

            Object text = evaluate(arguments.get(1));
            if (!(text instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "FIND" function: the argument must evaluate to a string value.'
                );
            }

            // There might be an optional third argument for the starting index, if there isn't one, it defaults to 0.
            Integer startIndex = 0;
            if (arguments.size() > 2) {
                Object startIndexValue = evaluate(arguments.get(2));
                if (!(startIndexValue instanceof Decimal)) {
                    throw new FunctionExecutionException(
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
                throw new FunctionExecutionException(
                    'Error executing "LEFT" function: the argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new FunctionExecutionException(
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
                throw new FunctionExecutionException(
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
                throw new FunctionExecutionException(
                    'Error executing ' + name + ' function: the first argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing ' + name + ' function: the second argument must evaluate to a number value.'
                );
            }

            Object padString = ' ';
            if (arguments.size() > 2) {
                padString = evaluate(arguments.get(2));
                if (!(padString instanceof String)) {
                    throw new FunctionExecutionException(
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
            Object val = evaluate(arguments.get(0));
            // Must evaluate to string or list
            if (!(val instanceof String) && !(val instanceof List<Object>)) {
                throw new FunctionExecutionException(
                    'Error executing "REVERSE" function: the argument must evaluate to a string or list value.'
                );
            }

            if (val instanceof String) {
                return ((String) val).reverse();
            } else {
                List<Object> reversedList = new List<Object>();
                for (Integer i = ((List<Object>) val).size() - 1; i >= 0; i--) {
                    reversedList.add(((List<Object>) val).get(i));
                }
                return reversedList;
            }
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class MidFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "MID" function: the first argument must evaluate to a string value.'
                );
            }

            Object start = evaluate(arguments.get(1));
            if (!(start instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "MID" function: the second argument must evaluate to a number value.'
                );
            }

            Object length = evaluate(arguments.get(2));
            if (!(length instanceof Decimal)) {
                throw new FunctionExecutionException(
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
                throw new FunctionExecutionException(
                    'Error executing "SUBSTRING" function: the first argument must evaluate to a string value.'
                );
            }

            Object start = evaluate(arguments.get(1));
            if (!(start instanceof Decimal)) {
                throw new FunctionExecutionException(
                    'Error executing "SUBSTRING" function: the second argument must evaluate to a number value.'
                );
            }

            // Third argument is optional
            Object length = null;
            if (arguments.size() > 2) {
                length = evaluate(arguments.get(2));
                if (!(length instanceof Decimal)) {
                    throw new FunctionExecutionException(
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
                throw new FunctionExecutionException(
                    'Error executing "RIGHT: function: the first argument must evaluate to a string value.'
                );
            }

            Object length = evaluate(arguments.get(1));
            if (!(length instanceof Decimal)) {
                throw new FunctionExecutionException(
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
                    throw new FunctionExecutionException(
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
            // Check that the first argument is a string
            Object url = evaluate(arguments.get(0));
            if (!(url instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "HYPERLINK" function: the first argument must evaluate to a string value.'
                );
            }

            // Check that the second argument is a string
            Object friendlyText = evaluate(arguments.get(1));
            if (!(friendlyText instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "HYPERLINK" function: the second argument must evaluate to a string value.'
                );
            }

            // Check that the third argument is a string (if present)
            Object target = null;
            if (arguments.size() > 2) {
                target = evaluate(arguments.get(2));
                if (!(target instanceof String)) {
                    throw new FunctionExecutionException(
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
            // Check that the first argument is a string
            Object text = evaluate(arguments.get(0));
            if (!(text instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "SUBSTITUTE" function: the first argument must evaluate to a string value.'
                );
            }

            // Check that the second argument is a string
            Object oldText = evaluate(arguments.get(1));
            if (!(oldText instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "SUBSTITUTE" function: the second argument must evaluate to a string value.'
                );
            }

            // Check that the third argument is a string
            Object newText = evaluate(arguments.get(2));
            if (!(newText instanceof String)) {
                throw new FunctionExecutionException(
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
            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new FunctionExecutionException(
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
            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "UPPER" function: the argument must evaluate to a string value.'
                );
            }

            return ((String) value).toUpperCase();
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class ValueFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "VALUE" function: the argument must evaluate to a string value.'
                );
            }

            return Decimal.valueOf((String) value);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class SplitFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // First argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "SPLIT" function: the first argument must evaluate to a string value.'
                );
            }

            // Second argument must be a string
            Object delimiter = evaluate(arguments.get(1));
            if (!(delimiter instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "SPLIT" function: the second argument must evaluate to a string value.'
                );
            }

            return ((String) value).split((String) delimiter);
        }

        public override Arity getArity() {
            return Arity.exactly(2);
        }
    }

    private class InitCapFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "INITCAP" function: the argument must evaluate to a string value.'
                );
            }

            String[] words = ((String) value).split(' ');
            String result = '';
            for (Integer i = 0; i < words.size(); i++) {
                result += words[i].substring(0, 1).toUpperCase() + words[i].substring(1).toLowerCase();
                if (i < words.size() - 1) {
                    result += ' ';
                }
            }

            return result;
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    private class UrlEncodeFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            // The argument must be a string
            Object value = evaluate(arguments.get(0));
            if (!(value instanceof String)) {
                throw new FunctionExecutionException(
                    'Error executing "URLENCODE" function: the argument must evaluate to a string value.'
                );
            }

            return EncodingUtil.urlEncode((String) value, 'UTF-8');
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }
}
