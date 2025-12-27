plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties if file exists
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.finereli.finerhistory"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.finereli.finerhistory"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storeFileProp = keystoreProperties["storeFile"] as String?
                // Resolve path relative to android directory (where key.properties is)
                val storeFileObj = storeFileProp?.let { 
                    val keystoreFile = file("${keystorePropertiesFile.parentFile}/$it")
                    keystoreFile
                }
                if (storeFileObj != null && storeFileObj.exists()) {
                    keyAlias = keystoreProperties["keyAlias"] as String?
                    keyPassword = keystoreProperties["keyPassword"] as String?
                    storeFile = storeFileObj
                    storePassword = keystoreProperties["storePassword"] as String?
                    println("Using release keystore: ${storeFileObj.absolutePath}")
                } else {
                    println("WARNING: Keystore file not found at: ${storeFileObj?.absolutePath ?: storeFileProp}")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                val storeFileProp = keystoreProperties["storeFile"] as String?
                // Resolve path relative to android directory (where key.properties is)
                val storeFileObj = storeFileProp?.let { 
                    val keystoreFile = file("${keystorePropertiesFile.parentFile}/$it")
                    keystoreFile
                }
                if (storeFileObj != null && storeFileObj.exists()) {
                    println("Release build: Using release signing config")
                    signingConfigs.getByName("release")
                } else {
                    println("Release build: Falling back to debug signing (keystore not found)")
                    signingConfigs.getByName("debug")
                }
            } else {
                println("Release build: Falling back to debug signing (key.properties not found)")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
