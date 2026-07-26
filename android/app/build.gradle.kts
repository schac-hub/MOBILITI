plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {

    namespace = "com.meschac.mobiliti.mobiliti"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

}

flutter {
    source = "../.."
}
