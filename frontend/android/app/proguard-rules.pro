# Kakao Vector Map SDK Proguard 예외 처리
-keep class com.kakao.vectormap.** { *; }
-keep class com.kakao.vectormap.internal.** { *; }
-dontwarn com.kakao.vectormap.**
# Kakao SDK 예외 처리
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**

