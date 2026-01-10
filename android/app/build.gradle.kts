plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.honey_purity_app"
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // PINASIMPLE NA SIGNING CONFIG
    signingConfigs {
        getByName("debug") {
            // Gagamit ng default debug key para hindi mag-error sa property
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    defaultConfig {
        // Binago ang ID para i-reset ang certificate issue sa phone
        applicationId = "com.honeypurity.scanner.app" 
        
        minSdk = 26 
        targetSdk = 36 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    @Suppress("UnstableApiUsage")
    androidResources {
        noCompress.add("tflite")
        noCompress.add("lite")
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}