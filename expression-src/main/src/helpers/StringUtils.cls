public with sharing class StringUtils {
    public static String leftPad(String source, Integer length, String padChar) {
        String result = source;
        while (result.length() < length) {
            result = padChar + result;
        }
        return result;
    }

    public static String valueOf(Object obj) {
        if (obj == null) {
            return '';
        }

        if (obj instanceof Decimal) {
            return ((Decimal) obj).format();
        } else if (obj instanceof Date) {
            return ((Date) obj).format();
        } else if (obj instanceof Datetime) {
            return ((Datetime) obj).format();
        } else if (obj instanceof Boolean) {
            return ((Boolean) obj) ? 'true' : 'false';
        } else if (obj instanceof Time) {
            Time timeValue = (Time) obj;
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
            return String.valueOf(obj);
        }
    }
}
