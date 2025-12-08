# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# Keep Stripe classes to prevent R8 errors
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Keep all Stripe SDK classes
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep React Native Stripe SDK classes
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**
