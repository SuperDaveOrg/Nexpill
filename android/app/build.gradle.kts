import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing. The keystore and its passwords never live in the repo: they
// come from android/key.properties (gitignored), or the file named by the
// NEXPILL_KEY_PROPERTIES environment variable (tool/build_release.sh uses this,
// because it builds in a clean checkout). See docs/RELEASING.md.
//
// Without either, release builds fall back to the debug key — fine for your
// own phone, refused by tool/build_release.sh.
val keyProperties = Properties().apply {
    val path = System.getenv("NEXPILL_KEY_PROPERTIES")
    val source = if (path != null) file(path) else rootProject.file("key.properties")
    if (source.exists()) FileInputStream(source).use { load(it) }
}

android {
    namespace = "com.superdavelab.nexpill"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications, which uses java.time APIs
        // that predate our minSdk.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.superdavelab.nexpill"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Both come from pubspec.yaml; the code is derived from the name
        // (major*10000 + minor*100 + patch). See docs/RELEASING.md.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (!keyProperties.isEmpty) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (keyProperties.isEmpty) "debug" else "release"
            )
            // Leave out the git commit AGP would record: a worktree build
            // finds no repository and F-Droid's clone does, so the APKs would
            // differ by that one file.
            vcsInfo.include = false
            // Keeps what the notification plugin reads back by reflection;
            // see the file.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // No dependency-metadata block in the APK signature. It is encrypted for
    // Google Play, which Nexpill doesn't use, and F-Droid rejects APKs carrying
    // it. See docs/RELEASING.md, "Reproducible builds".
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
