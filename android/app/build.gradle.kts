// android/app/build.gradle.kts
import java.util.Properties

val keystoreProps = Properties().apply {
    val candidates = listOf(
        rootProject.file("key.properties"),
        rootProject.file("keystore.properties"),
        file("key.properties")
    )
    for (f in candidates) {
        if (f.exists()) {
            f.inputStream().use { load(it) }
            println("=== INFO: loaded keystore props from ${f.absolutePath} ===")
            break
        }
    }
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // aktifkan kalau pakai Crashlytics
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    // Upload ke Google Play (Gradle Play Publisher)
    id("com.github.triplet.play") version "3.10.1"
    // Flutter plugin HARUS terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abce.mart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ WAJIB untuk flutter_local_notifications (desugaring)
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.abce.mart"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // 1) Prioritas ENV (CI)
            val envStorePath = System.getenv("ANDROID_KEYSTORE")
            val envStorePwd  = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            val envAlias     = System.getenv("ANDROID_KEY_ALIAS")
            val envKeyPwd    = System.getenv("ANDROID_KEY_PASSWORD")

            // 2) Fallback ke key.properties (lokal)
            val propStorePath = keystoreProps.getProperty("storeFile")
            val propStorePwd  = keystoreProps.getProperty("storePassword")
            val propAlias     = keystoreProps.getProperty("keyAlias")
            val propKeyPwd    = keystoreProps.getProperty("keyPassword")

            val storePath = envStorePath ?: propStorePath
            val storePwd  = envStorePwd  ?: propStorePwd
            val alias     = envAlias     ?: propAlias
            val keyPwd    = envKeyPwd    ?: propKeyPwd

            // Resolve path: coba relative ke android/ dulu, kalau nggak ada coba relative ke app/
            val resolvedStoreFile = storePath?.let {
                val fromAndroid = rootProject.file(it)                 // android/<path>
                val fromApp     = file(it)                             // android/app/<path>
                when {
                    fromAndroid.exists() -> fromAndroid
                    fromApp.exists()     -> fromApp
                    else                 -> file(it) // biar keliatan di log
                }
            }

            println("=== SIGN DEBUG ===")
            println("storePath=$storePath")
            println("resolved=${resolvedStoreFile?.absolutePath}")
            println("exists=${resolvedStoreFile?.exists()} alias=$alias")

            if (
                resolvedStoreFile != null && resolvedStoreFile.exists() &&
                !storePwd.isNullOrBlank() &&
                !alias.isNullOrBlank() &&
                !keyPwd.isNullOrBlank()
            ) {
                storeFile = resolvedStoreFile
                storePassword = storePwd
                keyAlias = alias
                keyPassword = keyPwd
            } else {
                println("WARNING: Release keystore NOT configured. Release build will fall back to debug signing.")
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.findByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

// Gradle Play Publisher
play {
    // file JSON service account (dibuat di workflow dari secrets)
    serviceAccountCredentials.set(
        file(System.getenv("PLAY_SERVICE_ACCOUNT_JSON_PATH") ?: "play-cred.json")
    )
    // track default (internal / alpha / beta / production)
    track.set(System.getenv("PLAY_TRACK") ?: "internal")
    defaultToAppBundles.set(true)
}

// ✅ Tambahkan dependencies desugaring di modul :app
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
