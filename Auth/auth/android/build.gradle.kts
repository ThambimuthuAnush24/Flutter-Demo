// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    extra.apply {
        set("kotlinVersion", "1.9.22")
        set("agpVersion", "8.1.0")
        set("googleServicesVersion", "4.4.1")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:${extra["agpVersion"]}")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${extra["kotlinVersion"]}")
        classpath("com.google.gms:google-services:${extra["googleServicesVersion"]}")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
    delete(file("../../build"))
}