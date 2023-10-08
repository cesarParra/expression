public with sharing class StringUtils {
    public static String leftPad(String source, Integer length, String padChar) {
        String result = source;
        while (result.length() < length) {
            result = padChar + result;
        }
        return result;
    }
}
