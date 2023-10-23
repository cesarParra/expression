/**
 * @description Repository of functions that can be used in expressions.
 * @group String
 * @function-repository true
 * @display-icon utility:text
 */
public with sharing class StringFunctions {
    private static final Map<String, ExpressionFunction> FUNCTIONS = new Map<String, ExpressionFunction>{
        'BEGINS' => new StringFunctions.Begins(),
        'CONTAINS' => new StringFunctions.Contains(),
        'LOWER' => new StringFunctions.Lower(),
        'FIND' => new StringFunctions.FindFn(),
        'LEFT' => new StringFunctions.LeftFn(),
        'LEN' => new StringFunctions.LenFn(),
        'LPAD' => new StringFunctions.LPadFn(),
        'RPAD' => new StringFunctions.RPadFn(),
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

    public class StringFunctionsProvider implements FunctionProvider {
        public Map<String, ExpressionFunction> getFunctions() {
            return FUNCTIONS;
        }
    }

    /**
     * @description Returns TRUE if the first character(s) in a text field match a given string.
     *
     * Accepts 2 arguments: the text field and the string to match.
     * @function BEGINS
     * @example
     * BEGINS("Hello World", "Hello") // TRUE
     */
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

    /**
     * @description Returns TRUE if a text field contains a given string.
     *
     * Accepts 2 arguments: the text field and the string to match.
     * @function CONTAINS
     * @example
     * CONTAINS("Hello World", "World") // TRUE
     */
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

    /**
     * @description Converts all letters in the specified text to lowercase.
     *
     * Accepts 1 argument: the text to convert.
     * @function LOWER
     * @example
     * LOWER("Hello World") // "hello world"
     */
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

    /**
     * @description Returns the starting position of one text string within another text string. If the text string is not found, FIND
     * returns a value -1.
     *
     * Accepts either 2 or 3 arguments: the text to find, the text to search, and optionally the starting position.
     * @function FIND
     * @example
     * FIND("World", "Hello World") // 7
     * FIND("World", "Hello World", 7) // -1
     */
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

    /**
     * @description Returns the specified number of characters from the beginning of a text string.
     *
     * Accepts 2 arguments: the text to evaluate and the number of characters to return.
     * @function LEFT
     * @example
     * LEFT("Hello World", 5) // "Hello"
     */
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

    /**
     * @description Returns the number of characters in a text string.
     *
     * Accepts 1 argument: the text to evaluate.
     * @function LEN
     * @example
     * LEN("Hello World") // 11
     */
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

    private virtual class LRPad extends ExpressionFunction {
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

    /**
     * @description Returns a text value padded to the specified length with the specified set of characters.
     *
     * Accepts 2 or 3 arguments: the text to pad, the length to pad to, and optionally the padding character.
     * If the padding character is not specified, it defaults to a space.
     * @function LPAD
     * @example
     * LPAD("Hello", 10) // "     Hello"
     * LPAD("Hello", 10, "*") // "*****Hello"
     */
    private class LPadFn extends LRPad {
        public LPadFn() {
            super('LPAD');
        }
    }

    /**
     * @description Returns a text value padded to the specified length with the specified set of characters.
     *
     * Accepts 2 or 3 arguments: the text to pad, the length to pad to, and optionally the padding character.
     * If the padding character is not specified, it defaults to a space.
     * @function RPAD
     * @example
     * RPAD("Hello", 10) // "Hello     "
     * RPAD("Hello", 10, "*") // "Hello*****"
     */
    private class RPadFn extends LRPad {
        public RPadFn() {
            super('RPAD');
        }
    }

    /**
     * @description Returns a text value with the order of the characters reversed.
     *
     * Accepts 1 argument: the text to reverse.
     * @function REVERSE
     * @example
     * REVERSE("Hello World") // "dlroW olleH"
     */
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

    /**
     * @description Returns a specified number of characters from a text string starting at the position you specify up
     * to the number of characters you specify.
     *
     * Note that the position is 1-based, not 0-based.
     *
     * Accepts 3 arguments: the text to evaluate, the starting position, and the number of characters to return.
     * @function MID
     * @example
     * MID("Hello World", 7, 5) // "World"
     */
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

    /**
     * @description Returns a specified number of characters from a text string starting at the position you specify.
     * Optionally, you can specify the number of characters to return.
     *
     * Note that the position is 1-based, not 0-based.
     *
     * Accepts 2 or 3 arguments: the text to evaluate and the starting position. Optionally, the number of characters to.
     * @function SUBSTRING
     * @example
     * SUBSTRING("Hello World", 7) // "World"
     * SUBSTRING("Hello World", 7, 5) // "World"
     */
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

    /**
     * @description Returns the specified number of characters from the end of a text string.
     *
     * Accepts 2 arguments: the text to evaluate and the number of characters to return.
     *
     * If the second argument is a negative number, it gets treated as a 0
     * @function RIGHT
     * @example
     * RIGHT("Hello World", 5) // "World"
     * RIGHT("Hello World", -5) // ""
     */
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

    /**
     * @description Inserts a line break in a string of text.
     *
     * When no arguments are provided, it inserts a line break. When a number is provided, it inserts that number of line
     *
     * ⚠️ Note that the inserted line break depends on the call context based on the
     * [Request Quiddity](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_Quiddity.htm). When called from
     * an Aura/LWC or Visualforce context it will insert a `<br>` tag, otherwise it will insert a newline character.
     * @function BR
     * @example
     * BR() // "<br/>"
     * BR(2) // "<br/><br/>"
     */
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
     * @description Returns a text string of an HTML anchor tag that displays a hyperlink.
     *
     * Accepts 2 or 3 arguments: the URL and the text to display. Optionally, the third argument is the target
     * of the link.
     *
     * The target should be one of `_blank`, `_parent`, `_self`, or `_top`.
     * @function HYPERLINK
     * @example
     * HYPERLINK("https://www.google.com", "Google") // "<a href="https://www.google.com">Google</a>"
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

    /**
     * @description Substitutes new text for old text in a text string.
     *
     * Accepts 3 arguments: the text to evaluate, the text to replace, and the text to replace it with.
     * @function SUBSTITUTE
     * @example
     * SUBSTITUTE("Hello World", "World", "Universe") // "Hello Universe"
     */
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

    /**
     * @description Converts a value to text.
     *
     * Accepts 1 argument: the value to convert.
     * @function TEXT
     * @example
     * TEXT(123) // "123"
     */
    private class TextFn extends ExpressionFunction {
        public override Object call(List<Expr> arguments) {
            Object value = evaluate(arguments.get(0));
            return StringUtils.valueOf(value);
        }

        public override Arity getArity() {
            return Arity.exactly(1);
        }
    }

    /**
     * @description Removes the spaces and tabs from the beginning and end of a text string.
     *
     * Accepts 1 argument: the text to trim.
     * @function TRIM
     * @example
     * TRIM(" Hello World ") // "Hello World"
     */
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

    /**
     * @description Converts all letters in the specified text to uppercase.
     *
     * Accepts 1 argument: the text to convert.
     * @function UPPER
     * @example
     * UPPER("Hello World") // "HELLO WORLD"
     */
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

    /**
     * @description Converts a text string that represents a number to a number.
     *
     * Accepts 1 argument: the text to convert.
     * @function VALUE
     * @example
     * VALUE("123") // 123
     */
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

    /**
     * @description Returns a list that contains each substring of the String that is terminated
     * by the provided delimiter.
     *
     * Accepts 2 arguments: the text to split and the delimiter.
     * @function SPLIT
     * @example
     * SPLIT("Hello World", " ") // ["Hello", "World"]
     */
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

    /**
     * @description Converts the first letter of each word in a text string to uppercase and converts all other letters to lowercase.
     *
     * Accepts 1 argument: the text to convert.
     * @function INITCAP
     * @example
     * INITCAP("hello world") // "Hello World"
     */
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

    /**
     * @description Encodes text and merge field values for use in URLs by replacing characters that are illegal in URLs, such as blank
     * spaces.
     *
     * Accepts 1 argument: the text to encode.
     * @function URLENCODE
     * @example
     * URLENCODE("Hello World") // "Hello+World"
     */
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
