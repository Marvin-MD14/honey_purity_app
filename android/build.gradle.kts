import com.android.build.gradle.BaseExtension
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {

    // 1. Set per-module build directory
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Ensure app is evaluated first
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    // 3. Apply namespace safely (NO afterEvaluate)
    plugins.withId("com.android.application") {
        extensions.configure<BaseExtension>("android") {
            if (namespace == null) {
                namespace = "com.example.honey_purity_app.${project.name}"
            }
        }
    }

    plugins.withId("com.android.library") {
        extensions.configure<BaseExtension>("android") {
            if (namespace == null) {
                namespace = "com.example.honey_purity_app.${project.name}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
