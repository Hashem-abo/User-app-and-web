allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
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

    plugins.withId("com.android.library") {
        val androidExt = extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        androidExt?.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
