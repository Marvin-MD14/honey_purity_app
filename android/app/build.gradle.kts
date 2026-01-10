plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Your unique app namespace
    namespace = "com.example.honey_purity_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.honey_purity_app"
        // MinSdk 26 supports the hardware acceleration needed for TFLite
        minSdk = 26 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Prevents the system from compressing the AI model, which causes runtime crashes
    @Suppress("UnstableApiUsage")
    androidResources {
        noCompress.add("tflite")
        noCompress.add("lite")
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Disable shrinking to ensure the TFLite native libraries aren't removed
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

// DO NOT add "subprojects" or "afterEvaluate" blocks here. 
// They must remain only in the root android/build.gradle.kts file.