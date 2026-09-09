allprojects {
    repositories {
        google()
        mavenCentral()
    }
    plugins.withId("com.android.library") {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
            ndkVersion = "27.0.12077973"
        }
    }
    plugins.withId("com.android.application") {
        extensions.findByType(com.android.build.gradle.AppExtension::class.java)?.apply {
            ndkVersion = "27.0.12077973"
        }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
