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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val configureAndroidSdkOverride = {
        if (hasProperty("android")) {
            val androidExtension = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            androidExtension?.apply {
                compileSdkVersion(36)
            }
        }
    }

    // If the plugin has already finished evaluating, patch it right now.
    // Otherwise, safely schedule it for its evaluation completion.
    if (state.executed) {
        configureAndroidSdkOverride()
    } else {
        afterEvaluate {
            configureAndroidSdkOverride()
        }
    }
}