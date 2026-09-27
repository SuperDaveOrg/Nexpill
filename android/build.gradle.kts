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
    project.evaluationDependsOn(":app")
}

// Plugins that compile C/C++ do it with CMake (none do yet). Adding
// reproducible.cmake to each of those builds keeps their libraries identical
// from one machine to the next, which F-Droid's rebuild depends on.
val reproducibleCmake = rootProject.file("reproducible.cmake").absolutePath
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.dsl.LibraryExtension> {
            defaultConfig.externalNativeBuild.cmake.arguments +=
                "-DCMAKE_PROJECT_INCLUDE=$reproducibleCmake"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
