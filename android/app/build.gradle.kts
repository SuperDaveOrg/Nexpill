import com.android.build.gradle.internal.api.ApkVariantOutputImpl
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

// F-Droid's build deletes the `signingConfigs` block and the `signingConfig =`
// line below, so its APK comes out unsigned for it to compare with ours. Its
// cleaner only removes whole lines, so that line must stay a single line with
// no spaces after the `=`; the choice is made here instead.
val releaseSigning = if (keyProperties.isEmpty) "debug" else "release"

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
        // (major*10000 + minor*100 + patch). Each APK's own code is ten times
        // that plus its ABI digit; see the end of this file.
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
            signingConfig = signingConfigs.getByName(releaseSigning)
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

// Version codes per APK, as F-Droid asks for split-per-ABI Flutter apps: ten
// times the pubspec code plus the ABI's digit, so every ABI of a new version
// outranks every ABI of the last, and on one version F-Droid picks the best ABI
// a device can run. This replaces Flutter's own split scheme (ABI * 1000 +
// code), which our five-digit codes would overflow.
//
// The universal APK (the website's download) gets the same ten times with a 0,
// so switching between it and an F-Droid install is never a downgrade.
val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)
android.applicationVariants.configureEach {
    val variant = this
    variant.outputs.forEach { output ->
        val abi = output.filters.find { it.filterType == "ABI" }?.identifier
        val abiVersionCode = if (abi == null) 0 else abiCodes[abi]
        if (abiVersionCode != null) {
            (output as ApkVariantOutputImpl).versionCodeOverride = variant.versionCode * 10 + abiVersionCode
        }
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
