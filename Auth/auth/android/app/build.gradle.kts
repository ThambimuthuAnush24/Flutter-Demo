plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app_authentication"
    compileSdk = 34  // Updated to latest stable version (35 is preview)

    defaultConfig {
        applicationId = "com.example.app_authentication"
        minSdk = 23
        targetSdk = 34  // Updated to match compileSdk
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        manifestPlaceholders["facebook_app_id"] = "593785636313097"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        // Default debug config is automatically created
        create("release") {
            // Configure these with your actual release keystore info
            // storeFile = File("path/to/your/release-key.keystore")
            // storePassword = "yourpassword"
            // keyAlias = "youralias"
            // keyPassword = "yourpassword"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true  // Added for better size optimization
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            isDebuggable = true
            // Uses default debug signing config automatically
            applicationIdSuffix = ".debug"  // Optional: helps with side-by-side installs
        }
    }

    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
        abortOnError = false
    }

    buildFeatures {
        viewBinding = true
        buildConfig = true  // Added to enable BuildConfig generation
    }

    packagingOptions {
        resources {
            excludes += setOf(  // Using setOf instead of listOf for better performance
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module"
            )
        }

        // For Flutter native libraries
        pickFirsts += setOf(
            "lib/armeabi-v7a/libflutter.so",
            "lib/arm64-v8a/libflutter.so",
            "lib/x86/libflutter.so",
            "lib/x86_64/libflutter.so"
        )
    }
}

dependencies {
    // Core dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.multidex:multidex:2.0.1")

    // Java 8+ APIs on older devices
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Flutter engine (using variables for versions)
    val flutterVersion = "1.0.0-8f2221fbef28b478debb78dd233f5250b220ca99"
    implementation("io.flutter:flutter_embedding_debug:$flutterVersion")
    implementation("io.flutter:armeabi_v7a_debug:$flutterVersion")
    implementation("io.flutter:arm64_v8a_debug:$flutterVersion")
    implementation("io.flutter:x86_64_debug:$flutterVersion")
    implementation("io.flutter:x86_debug:$flutterVersion")

    // AndroidX
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.browser:browser:1.7.0")

    // Social login SDKs (updated versions)
    implementation("com.facebook.android:facebook-android-sdk:16.3.0")
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")

    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test:runner:1.5.2")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}

flutter {
    source = "../.."
}