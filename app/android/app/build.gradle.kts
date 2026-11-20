import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release-Signierung (Upload-Schlüssel für Google Play), in dieser Reihenfolge:
//  1. Codemagic: Umgebungsvariablen CM_KEYSTORE_PATH, CM_KEYSTORE_PASSWORD,
//     CM_KEY_ALIAS, CM_KEY_PASSWORD (Schlüssel in Codemagic hinterlegt).
//  2. Lokal: android/key.properties (nie einchecken, steht in .gitignore).
//  3. Sonst: Debug-Schlüssel – nur für direkt installierte Testversionen,
//     nicht für Google Play.
// Siehe docs/DEVICE_TESTING.md.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) FileInputStream(file).use { load(it) }
}
val ciKeystore: String? = System.getenv("CM_KEYSTORE_PATH")
val hasReleaseKey = ciKeystore != null || keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "ch.solarcticzen.solarctic_zen"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "ch.solarcticzen.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Versionsname und -nummer kommen aus pubspec.yaml bzw. --build-number
        // (Codemagic zählt die Nummer bei jedem Build hoch).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                if (ciKeystore != null) {
                    storeFile = file(ciKeystore)
                    storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("CM_KEY_ALIAS")
                    keyPassword = System.getenv("CM_KEY_PASSWORD")
                } else {
                    storeFile = file(keystoreProperties.getProperty("storeFile"))
                    storePassword = keystoreProperties.getProperty("storePassword")
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseKey) signingConfigs.getByName("release")
                else signingConfigs.getByName("debug")
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
