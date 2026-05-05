# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Services & Core
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Dio
-keep class io.github.** { *; }
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Socket.io
-keep class io.socket.** { *; }
-keep class engine.io.** { *; }

# GetIt (Dependency Injection)
-keep class get_it.** { *; }

# Sentry
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Google Maps
-keep class com.google.maps.** { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
