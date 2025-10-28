// --- IMPORTAÇÕES NECESSÁRIAS ADICIONADAS NO TOPO ---
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --- LÓGICA DE LEITURA DA CHAVE MOVIDA PARA CÁ ---
val keyPropertiesFile = rootProject.file("key.properties") // Caminho corrigido
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}
// --- FIM DA LÓGICA DA CHAVE ---

android {
    namespace = "com.example.decifra_rotulo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // --- CONFIGURAÇÃO DE ASSINATURA QUE JÁ TINHA SIDO ADICIONADA ---
    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String?
            keyPassword = keyProperties["keyPassword"] as String?
            storeFile = keyProperties["storeFile"]?.let { rootProject.file(it) }
            storePassword = keyProperties["storePassword"] as String?
        }
    }
    // --- FIM DA CONFIGURAÇÃO DE ASSINATURA ---

    defaultConfig {
        applicationId = "com.example.decifra_rotulo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        // Bloco debug mantido para testes
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        // Bloco release modificado para usar a chave de produção
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
