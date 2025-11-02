pluginManagement {
    // 1. 충돌 마커와 중복된 블록을 삭제하고, 하나만 남깁니다.
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // 2. 충돌 마커를 삭제하고, 더 최신 버전인 8.9.1을 남깁니다.
    id("com.android.application") version "8.9.1" apply false

    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")