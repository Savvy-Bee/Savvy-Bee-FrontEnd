# Unity Integration Technical Documentation
 
## 1. Folder Structure Analysis
 
### 1.1. Directory Hierarchy
 
The Android project is structured as a standard Unity project with an Android module. The key directories are:
 
- **android/app**: This directory contains the main Android application module.
- **android/gradle**: This directory contains the Gradle wrapper files.
- **android/launcher**: This directory contains the Unity launcher module.
- **android/unityLibrary**: This directory contains the Unity library module.
 
### 1.2. Key Files
 
- **android/build.gradle.kts**: This is the main Gradle build file for the Android project.
- **android/settings.gradle**: This file defines the project's modules and their dependencies.
- **android/app/src/main/AndroidManifest.xml**: This is the main manifest file for the Android application.
- **android/launcher/build.gradle**: This is the Gradle build file for the Unity launcher module.
- **android/unityLibrary/build.gradle**: This is the Gradle build file for the Unity library module.
 
### 1.3. Custom Configurations
 
The project includes a custom configuration for the build directory, which is set to `../../build`. This is a common practice in Unity projects to avoid conflicts with the default build directory.
 
## 2. Unity Integration Requirements
 
### 2.1. Unity Project Settings
 
- The Unity project must be exported as an Android Library.
- The exported library is then included as a module in the Android project.
 
### 2.2. Required Plugins and SDKs
 
- **Flutter**: The project is a Flutter application, so the Flutter SDK is required.
- **Unity**: The Unity editor is required to build the Unity project or request the unity exports (iOS & Android) from the Unity developer.
 
### 2.3. Build Configuration
 
- The `android/app/build.gradle.kts` file must include the following dependency:
 
```gradle
 dependencies {
     implementation(project(":unityLibrary"))
 }
 ```
 
## 3. Implementation Guide
 
### 3.1. Overview
 
The project uses the `flutter_unity_widget` package to embed a Unity project within the Flutter application. The integration is active and configured as described below.

### 3.2. Unity Integration Implementation

The integration is enabled and uses the `flutter_unity_widget` package. Here are the key implementation points:

1.  **The `flutter_unity_widget` dependency in `pubspec.yaml` is active:**

    ```yaml
    flutter_unity_widget: ^2022.2.1
    ```

2.  **The Unity integration is initialized in `ios/Runner/AppDelegate.swift`:**

    ```swift
    import flutter_unity_widget
    InitUnityIntegrationWithOptions(argc: CommandLine.argc, argv: CommandLine.unsafeArgv, launchOptions)
    ```

3.  **The `UnityWidget` is used in `lib/features/hive/presentation/screens/games/game_screen.dart`:**

    ```dart
    import 'package:flutter_unity_widget/flutter_unity_widget.dart';
    // ...
    UnityWidgetController? _unityWidgetController;
    // ...
    child: UnityWidget(onUnityCreated: onUnityCreated),
    // ...
    void onUnityCreated(controller) {
      _unityWidgetController = controller;
    }
    ```
 
## 4. Testing Procedures

### 4.1. Troubleshooting
 
- **Unity integration not working**: Ensure that the `flutter_unity_widget` package is installed and configured correctly.
- **App crashes on startup**: Check the device logs for any errors that may be causing the crash.
- **UI not rendering correctly**: Ensure that the UI is being rendered on the main thread.
 
## 5. Maintenance Guidelines
 
### 5.1. Version Control
 
- **Use Git for version control.**
- **Create a separate branch for each new feature or bug fix.**
- **Use a Git hosting service like GitHub or GitLab to store the repository.**
 
### 5.2. Update Procedures
 
- **Update the Flutter SDK and other dependencies regularly.**
- **Update the Unity editor and other plugins regularly.**
- **Test the application thoroughly after each update.**
 
### 5.3. Best Practices
 
- **Follow the official Flutter and Unity documentation.**
- **Use a consistent coding style.**
- **Write clear and concise comments.**
- **Use a linter to enforce a consistent coding style.**

 
