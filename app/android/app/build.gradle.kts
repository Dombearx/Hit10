import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (docs/05 §9): the keystore never enters the repo. Locally
// it comes from android/key.properties (gitignored), in CI from secrets via
// environment variables. Without either, release builds use the debug key,
// which is fine for testing but cannot be uploaded to Play.
val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
fun signing(name: String, env: String): String? =
    keyProps.getProperty(name) ?: System.getenv(env)
val releaseStore = signing("storeFile", "HIT10_KEYSTORE")

// AdMob app id (docs/05 T-26, T-28): Google's test id unless the release
// build passes the real one.
val admobAppId = System.getenv("ADMOB_APP_ID")
    ?: (project.findProperty("ADMOB_APP_ID") as String?)
    ?: "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "io.github.dombearx.hit10"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications needs library desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Fixed forever after the first release (docs/05 §9).
        applicationId = "io.github.dombearx.hit10"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (releaseStore != null) {
            create("release") {
                storeFile = file(releaseStore)
                storePassword = signing("storePassword", "HIT10_KEYSTORE_PASSWORD")
                keyAlias = signing("keyAlias", "HIT10_KEY_ALIAS")
                keyPassword = signing("keyPassword", "HIT10_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
