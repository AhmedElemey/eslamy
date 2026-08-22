import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing — mirrors xstore's android/app/build.gradle.kts pattern.
// android/key.properties and the keystore it points at are both gitignored;
// CI decodes them from secrets right before a release build and deletes them
// straight after (see .github/workflows/build-and-release-apk.yml).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun isReleaseBuildTask(): Boolean =
    gradle.startParameter.taskNames.any { task ->
        val t = task.lowercase()
        (t.contains("assemble") || t.contains("bundle") || t.contains("package")) &&
            t.contains("release")
    }

fun requireReleaseSigningProperties(): Properties {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            """
            Release build requires android/key.properties, but the file was not found.

            Create android/key.properties with:
              storePassword=<keystore-password>
              keyPassword=<key-password>
              keyAlias=<key-alias>
              storeFile=app/release.keystore

            Generate the keystore locally with keytool and keep both files out of git.
            See: https://docs.flutter.dev/deployment/android#signing-the-app
            """.trimIndent(),
        )
    }

    val requiredKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missingKeys = requiredKeys.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
    if (missingKeys.isNotEmpty()) {
        throw GradleException(
            "android/key.properties is missing required properties: ${missingKeys.joinToString()}",
        )
    }

    val storeFile = rootProject.file(keystoreProperties.getProperty("storeFile")!!)
    if (!storeFile.exists()) {
        throw GradleException(
            """
            Release keystore not found at: ${storeFile.absolutePath}

            Generate a keystore locally, place it at that path (or update storeFile in
            android/key.properties), and retry the release build.
            """.trimIndent(),
        )
    }

    return keystoreProperties
}

// Only enforced for an actual release build (assemble/bundle/package + "release" in the
// task name) — debug builds and `flutter analyze`/tests never need a keystore at all.
val releaseSigningProperties: Properties? =
    if (isReleaseBuildTask()) requireReleaseSigningProperties() else null

android {
    namespace = "com.eslamy.eslamy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.eslamy.eslamy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningProperties != null) {
            create("release") {
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
                storePassword = releaseSigningProperties.getProperty("storePassword")
                storeFile = rootProject.file(releaseSigningProperties.getProperty("storeFile")!!)
            }
        }
    }

    buildTypes {
        release {
            // requireReleaseSigningProperties() above already throws with a
            // clear message for any release-assembling task before this
            // point is reached if key.properties/the keystore is missing —
            // so by the time we get here for a release build, signing
            // properties are always present. (Non-release tasks, e.g. `flutter
            // analyze` or a debug build, never touch this — releaseSigningProperties
            // stays null and this branch is simply never evaluated for them.)
            if (releaseSigningProperties != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.3")
    // BubbleOverlayService talks to audio_service's MediaSession via
    // MediaBrowserCompat/MediaControllerCompat — audio_service depends on
    // this itself but only as `implementation`, so it isn't exposed
    // transitively; declare it directly.
    implementation("androidx.media:media:1.8.0")
}
