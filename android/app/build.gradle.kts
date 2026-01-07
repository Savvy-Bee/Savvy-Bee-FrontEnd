plugins {
    id("com.android.application")
    
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.savvy_bee_mobile"
    compileSdk = 36
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    defaultConfig {
        applicationId = "com.example.savvy_bee_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Add NDK configuration
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Fix packaging options - this is critical!
    packagingOptions {
        // Don't strip native libraries
        jniLibs {
            useLegacyPackaging = true
            keepDebugSymbols.add("*/arm64-v8a/*.so")
            keepDebugSymbols.add("*/armeabi-v7a/*.so")
        }
        
        // Handle duplicate files properly instead of pickFirst("**")
        resources {
            excludes.add("META-INF/DEPENDENCIES")
            excludes.add("META-INF/LICENSE")
            excludes.add("META-INF/LICENSE.txt")
            excludes.add("META-INF/license.txt")
            excludes.add("META-INF/NOTICE")
            excludes.add("META-INF/NOTICE.txt")
            excludes.add("META-INF/notice.txt")
            excludes.add("META-INF/*.kotlin_module")
        }
        
        // For duplicate .so files, pick the first one
        pickFirst("lib/armeabi-v7a/libc++_shared.so")
        pickFirst("lib/arm64-v8a/libc++_shared.so")
        pickFirst("lib/x86/libc++_shared.so")
        pickFirst("lib/x86_64/libc++_shared.so")
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(project(":unityLibrary"))
}