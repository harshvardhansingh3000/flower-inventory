-keepclassmembers class * {
    @com.google.errorprone.annotations.CanIgnoreReturnValue *;
    @com.google.errorprone.annotations.CheckReturnValue *;
    @com.google.errorprone.annotations.Immutable *;
    @com.google.errorprone.annotations.RestrictedApi *;
    @javax.annotation.Nullable *;
    @javax.annotation.concurrent.GuardedBy *;
}

-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class org.checkerframework.** { *; }