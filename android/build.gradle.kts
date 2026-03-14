import com.android.build.gradle.BaseExtension

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as BaseExtension
            
            // Don't override compileSdkVersion for unityLibrary - let it use its own
            if (project.name != "unityLibrary") {
                android.compileSdkVersion(36)
            }
            
            if (android.namespace == null) {
                android.namespace = when (project.name) {
                    "flutter_unity_widget" -> "com.xraph.plugin.flutter_unity_widget"
                    else -> "com.example.${project.name.replace("-", "_")}"
                }
            }
            
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
            
            project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                kotlinOptions {
                    jvmTarget = "17"
                }
            }
        }
    }
    
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1") 
            force("androidx.core:core-ktx:1.13.1")
        }
    }
    
    // REMOVE THIS - it's excluding Unity classes entirely!
    // project.configurations.configureEach {
    //     exclude(group = "com.unity3d.player", module = "unity-classes")
    // }
    
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}