plugins {
    id("com.android.application")
    id("kotlin-android")
    // O Flutter Gradle Plugin deve ser aplicado após os plugins do Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "org.ifsul.contapassos.contador_de_passos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion =  "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            // TODO: Adicione aqui as configurações da sua chave de assinatura real
            // para publicar seu aplicativo na Google Play.
        }
    }

    defaultConfig {
        applicationId = "org.ifsul.contapassos.contador_de_passos"
        minSdk = 28
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            // CORREÇÃO: Usar 'isMinifyEnabled' e 'isShrinkResources'
            isMinifyEnabled = true
            isShrinkResources = true

            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation("androidx.health.connect:connect-client:1.1.0-alpha07")
}

flutter {
    source = "../.."
}