allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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
    pluginManager.withPlugin("com.android.library") {
        (extensions.getByName("android") as com.android.build.gradle.BaseExtension).apply {
            testOptions.unitTests.all { it.enabled = false }
        }
    }
    pluginManager.withPlugin("com.android.application") {
        (extensions.getByName("android") as com.android.build.gradle.BaseExtension).apply {
            testOptions.unitTests.all { it.enabled = false }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ... votre code existant (allprojects, subprojects buildDir, etc.)

// AJOUTEZ CE BLOC ICI :
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.3.10") // On force tout le monde sur la version que le compilateur comprend
            }
        }
    }
}