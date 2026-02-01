// 1. BLOC BUILDSCRIPT (Regroupe TOUS les plugins de build)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Plugin pour Android Gradle (Indispensable pour compiler l'app)
        classpath("com.android.tools.build:gradle:7.3.0")
        
        // Plugin nécessaire pour lire le fichier google-services.json (Firebase)
        classpath("com.google.gms:google-services:4.4.1")
        
        // Plugin Kotlin (Souvent nécessaire pour Flutter)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
    }
}

// 2. RÉPERTOIRES POUR LES PROJETS
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. CONFIGURATION DES DOSSIERS DE BUILD
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 4. TÂCHE DE NETTOYAGE
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}