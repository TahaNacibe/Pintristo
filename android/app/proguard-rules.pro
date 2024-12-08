# Keep all classes related to Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }

# Keep classes from Guava that might be needed
-keep class com.google.common.** { *; }

# Keep classes that use TypeToken
-keep class com.google.common.reflect.TypeToken {
    <init>();
    <fields>;
    <methods>;
}

-keep class * extends com.google.common.reflect.TypeToken {
    <init>();
    <fields>;
    <methods>;
}

# Ensure that generic signatures are preserved
-keepattributes Signature
-keepattributes *Annotation*

# Keep the types for the generic parameters
-keepclassmembers class * {
    <fields>;
    <methods>;
}

# Keep methods that use generics with TypeToken
-keep class ** {
    <methods>;
}

# Prevent warnings about missing classes
-dontwarn java.lang.reflect.AnnotatedType
-dontwarn com.google.common.reflect.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.squareup.okhttp.CipherSuite
-dontwarn com.squareup.okhttp.ConnectionSpec
-dontwarn com.squareup.okhttp.TlsVersion