# ProGuard rules for HijriMinder Flutter app
# Add project specific ProGuard rules here.

# Flutter framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep notification service classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends com.dexterous.flutterlocalnotifications.NotificationReceiver { *; }

# Keep model classes for JSON serialization
-keep class com.hijriminder.hijri_minder.models.** { *; }
-keep class * implements java.io.Serializable { *; }

# Keep reflection-based classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Arabic text rendering classes
-keep class android.text.** { *; }
-keep class android.graphics.** { *; }

# Keep HTTP client classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep Geolocator plugin classes
-keep class com.baseflow.geolocator.** { *; }

# Keep location service classes
-keep class com.google.android.gms.location.** { *; }

# Keep audio playback classes
-keep class android.media.** { *; }

# Keep notification classes
-keep class android.app.Notification** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Keep RTL layout classes
-keep class android.view.View** { *; }
-keep class android.widget.** { *; }

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application class
-keep class com.hijriminder.hijri_minder.MainActivity { *; }
-keep class com.hijriminder.hijri_minder.MainApplication { *; }
