plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // (opsional) kalau pakai Crashlytics aktifkan baris di bawah:
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Upload ke Google Play (Gradle Play Publisher)
    id("com.github.triplet.play") version "3.10.1"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abce.mart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID HARUS sama dengan di Play Console
        applicationId = "com.abce.mart"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        // akan dioverride di CI (pubspec.yaml) tapi tetap beri default
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // di CI, ANDROID_KEYSTORE akan di-set ke path file yang didecode dari secret
            storeFile = file(System.getenv("ANDROID_KEYSTORE") ?: "upload-key.jks")
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            // biarkan default
        }
    }
}

flutter {
    source = "../.."
}

// Konfigurasi Gradle Play Publisher (ambil kredensial & track dari ENV)
play {
    // path file JSON service account yang dibuat di step workflow
    serviceAccountCredentials.set(
        file(System.getenv("PLAY_SERVICE_ACCOUNT_JSON_PATH") ?: "play-cred.json")
    )
    track.set(System.getenv("PLAY_TRACK") ?: "internal")
    defaultToAppBundles.set(true)
}
