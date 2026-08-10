allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // flutter_avif_android 3.1.0 publishes equivalent Java and Kotlin classes
    // with the same fully-qualified name. Compile the Java implementation only.
    if (name == "flutter_avif_android") {
        tasks.configureEach {
            if (name.startsWith("compile") && name.endsWith("Kotlin")) {
                enabled = false
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
