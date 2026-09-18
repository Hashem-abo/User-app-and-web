package im.zego.zego_express_engine.internal;

import java.util.ArrayList;
import java.util.Iterator;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.pm.ActivityInfo;
import android.os.Build;
import android.view.Window;

public class ZegoUtils {
    /* Utils */

    public static boolean boolValue(Boolean number) {
        return number != null && number;
    }

    public static int intValue(Number number) {
        return number != null ? number.intValue() : 0;
    }

    public static long longValue(Number number) {
        return number != null ? number.longValue() : 0;
    }

    public static float floatValue(Number number) {
        return number != null ? number.floatValue() : .0f;
    }

    public static double doubleValue(Number number) {
        return number != null ? number.doubleValue() : .0f;
    }

    public static int[] intArrayValue(ArrayList<Integer> integerArrayList) {
        int[] ret = new int[integerArrayList.size()];
        Iterator<Integer> iterator = integerArrayList.iterator();
        for (int i = 0; i < ret.length; i++) {
            ret[i] = iterator.next();
        }
        return ret;
    }

    public static float[] floatArrayValueFromDoubleArray(ArrayList<Double> floatArrayList) {
        float[] ret = new float[floatArrayList.size()];
        Iterator<Double> iterator = floatArrayList.iterator();
        for (int i = 0; i < ret.length; i++) {
            ret[i] = iterator.next().floatValue();
        }
        return ret;
    }

    public static String getStackTrace(Throwable e) {
        StringBuilder message = new StringBuilder();
        if (e != null) {
            message.append(e.getClass()).append(": ").append(e.getMessage()).append(" | ");
            StackTraceElement[] elements = e.getStackTrace();
            for (StackTraceElement stackTraceElement : elements) {
                message.append(stackTraceElement.toString()).append(" | ");
            }
        }
        return message.toString();
    }

    /** Window is in HDR mode */
    public static boolean isWindowHdrMode(Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false;
        }
        Activity activity = findActivity(context);
        if (activity == null) {
            return false;
        }
        Window window = activity.getWindow();
        return window != null
                && window.getColorMode() == ActivityInfo.COLOR_MODE_HDR;
    }

    public static Activity findActivity(Context context) {
        while (context instanceof ContextWrapper) {
            if (context instanceof Activity) {
                return (Activity) context;
            }
            context = ((ContextWrapper) context).getBaseContext();
        }
        return null;
    }
}
