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

    // 3. FORCE SDK VERSION & Namespace (Updated to 36)
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as BaseExtension
            
            // UPDATE: Pilitin ang lahat ng plugins (camera, image_picker, etc.) na gumamit ng SDK 36
            android.compileSdkVersion(36)

            // Pag-set ng namespace kung wala pa
            if (android.namespace == null) {
                android.namespace = "com.example.honey_purity_app.${project.name}"
            }
        }
    }

    // 4. Fallback Namespace safely for older plugins
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