plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter 플러그인은 Android/Kotlin 이후에 와야 합니다.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.sharing_items"

    // Flutter 변수 대신 명시값으로 고정 (권장)
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.sharing_items"
        minSdk = 21
        targetSdk = 34

        // Flutter가 생성해둔 값 유지하려면 그대로 사용
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // (선택) NDK 버전이 필요할 때만 사용
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // 데모용으로 debug 키로 서명 (실서비스 시 release 서명키 설정)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
