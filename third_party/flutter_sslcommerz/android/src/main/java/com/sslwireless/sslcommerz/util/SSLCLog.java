package com.sslwireless.sslcommerz.util;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.util.Log;

/**
 * Logging gate for the plugin.
 *
 * <p>Logs are emitted only when the <em>host application</em> is debuggable. This module is an
 * Android library, so its own {@code BuildConfig.DEBUG} describes the library variant rather than
 * the app that embeds it; {@link ApplicationInfo#FLAG_DEBUGGABLE} is the flag that actually tracks
 * the release/debug state of the shipped app.
 *
 * <p>Never pass cardholder data, store credentials, session tokens or customer PII to these
 * methods. A debuggable build still writes to logcat, which is readable by other processes on
 * older Android versions and by anyone with adb access.
 */
public final class SSLCLog {

    private static final String TAG = "FlutterSslcommerz";

    private static volatile boolean debuggable = false;

    private SSLCLog() {
    }

    /** Resolves the host app's debuggable flag. Called once when the plugin attaches. */
    public static void init(Context context) {
        if (context == null) {
            debuggable = false;
            return;
        }
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        debuggable = applicationInfo != null
                && (applicationInfo.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
    }

    /** Guard for call sites that would otherwise build an expensive message string. */
    public static boolean isDebuggable() {
        return debuggable;
    }

    public static void d(String message) {
        if (debuggable) {
            Log.d(TAG, message);
        }
    }

    public static void w(String message) {
        if (debuggable) {
            Log.w(TAG, message);
        }
    }

    public static void e(String message) {
        if (debuggable) {
            Log.e(TAG, message);
        }
    }

    public static void e(String message, Throwable throwable) {
        if (debuggable) {
            Log.e(TAG, message, throwable);
        }
    }
}
