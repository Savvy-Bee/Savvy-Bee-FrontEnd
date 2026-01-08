# Unity iOS Integration for Flutter

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Initial Setup](#initial-setup)
5. [Unity Export Process](#unity-export-process)
6. [Xcode Configuration](#xcode-configuration)
7. [Flutter Configuration](#flutter-configuration)
8. [Build and Run](#build-and-run)
9. [Troubleshooting](#troubleshooting)
10. [Git Configuration](#git-configuration)
11. [Team Workflow](#team-workflow)

---

## Overview

This project integrates a Unity game into a Flutter iOS application using the `flutter_unity_widget` package. The Unity content is embedded as a native iOS framework that communicates with Flutter through a platform channel bridge.

### Architecture
```
Flutter App
    ↓
flutter_unity_widget (Dart)
    ↓
Platform Channel (iOS)
    ↓
UnityFramework (Native iOS)
    ↓
Unity Game
```

---

## Prerequisites

### Required Software
- **Flutter SDK**: Latest stable version
- **Xcode**: 14.0 or later (latest recommended)
- **CocoaPods**: 1.11.0 or later
- **Unity Editor**: 2021.3 LTS or later (if you have the source project)
- **Physical iOS Device**: Strongly recommended (simulators have limited Unity support)

### Required Accounts
- Apple Developer Account (for device testing)
- Unity account (if building from source)

### Check Your Setup
```bash
flutter doctor -v
xcodebuild -version
pod --version
```

---

## Project Structure

### Required Directory Layout
```
Savvy-Bee-FrontEnd/
├── ios/
│   ├── Runner.xcworkspace          # Always use this, not .xcodeproj
│   ├── Runner.xcodeproj
│   ├── UnityLibrary/                # Unity iOS build (not in git)
│   │   ├── Unity-iPhone.xcodeproj
│   │   ├── UnityFramework.framework/
│   │   ├── Data/
│   │   ├── Classes/
│   │   └── Libraries/
│   ├── Podfile
│   └── Runner/
│       └── Info.plist
├── android/
│   ├── app/
│   │   └── build.gradle.kts
│   └── settings.gradle
├── lib/
│   └── (your Flutter code)
├── unity/                           # Unity source (if available)
│   └── YourUnityProject/
├── pubspec.yaml
├── .gitignore
└── README.md
```

---

## Initial Setup

### 1. Add Flutter Dependencies

In `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_unity_widget:
    git:
      url: https://github.com/juicycleff/flutter-unity-view-widget.git
      ref: master
```

Run:
```bash
flutter pub get
```

### 2. Configure iOS Info.plist

Add to `ios/Runner/Info.plist`:
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

This enables platform view embedding, which is required for Unity widget.

### 3. Update Podfile

Ensure `ios/Podfile` has Unity configuration:
```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Unity Framework configuration
    if target.name == 'flutter_unity_widget'
      target.build_configurations.each do |config|
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] ||= ['$(inherited)']
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] << '$(PROJECT_DIR)/../UnityLibrary'
        config.build_settings['HEADER_SEARCH_PATHS'] ||= ['$(inherited)']
        config.build_settings['HEADER_SEARCH_PATHS'] << '$(PROJECT_DIR)/../UnityLibrary'
      end
    end
  end
end
```

---

## Unity Export Process

### If You Have Unity Source Project

#### 1. Import Flutter Unity Package
1. Download `FlutterUnityIntegration.unitypackage` from the flutter_unity_widget repository
2. In Unity Editor: `Assets → Import Package → Custom Package`
3. Select the downloaded package
4. Import **ALL** items

#### 2. Configure Build Settings
1. In Unity: `File → Build Settings`
2. Select **iOS** platform
3. Click **Switch Platform** if not already on iOS
4. Go to `Player Settings`

#### 3. Configure Player Settings
Under **Other Settings**:
- **Target SDK**: Device SDK (for physical devices)
- **Target Minimum iOS Version**: 13.0 or higher
- **Architecture**: ARM64
- **Auto Graphics API**: Disabled (Metal only)

#### 4. Export Using Flutter Menu
**CRITICAL**: Do NOT use `Build Settings → Export`

Instead:
1. In Unity menu bar: `Flutter → Export iOS Debug` (or `Export iOS Release`)
2. This automatically exports to `ios/UnityLibrary/` in your Flutter project
3. Wait for export to complete (can take several minutes)

#### 5. Verify Export
Check that these exist:
```bash
ls ios/UnityLibrary/Unity-iPhone.xcodeproj
ls ios/UnityLibrary/UnityFramework.framework
ls ios/UnityLibrary/Data
ls ios/UnityLibrary/Classes
```

All should exist without errors.

### If You Only Have Pre-Built Unity Export

1. Obtain the Unity iOS build (ios-build folder)
2. Copy contents to `ios/UnityLibrary/`:
```bash
mkdir -p ios/UnityLibrary
cp -r path/to/ios-build/* ios/UnityLibrary/
```

3. Verify the structure matches the directory layout above

---

## Xcode Configuration

### Step 1: Open Xcode Workspace

**CRITICAL**: Always use the workspace, never the project file.

```bash
cd ios
open Runner.xcworkspace
```

### Step 2: Add Unity-iPhone Project

1. In Xcode's **Project Navigator** (left panel), right-click in an empty area
2. Select **"Add Files to 'Runner'..."**
3. Navigate to `ios/UnityLibrary/Unity-iPhone.xcodeproj`
4. **UNCHECK** "Copy items if needed"
5. Click **Add**

You should now see both `Runner` and `Unity-iPhone` projects in the navigator.

### Step 3: Configure Data Folder Target Membership

**This is critical for the build to work.**

1. In Project Navigator, expand: `Unity-iPhone → UnityFramework → Data`
2. **Click once** on the **Data** folder (blue folder icon)
3. In the **File Inspector** (right panel), find "Target Membership"
4. **CHECK** the box for `UnityFramework`
5. **UNCHECK** the box for `Unity-iPhone` (if checked)

### Step 4: Add UnityFramework to Runner

1. Select **Runner** (top item in Project Navigator)
2. In the main panel, select **TARGETS → Runner** (not PROJECT)
3. Go to **General** tab
4. Scroll to **"Frameworks, Libraries, and Embedded Content"**
5. Click the **+** button
6. Find and select **UnityFramework.framework**
7. **IMPORTANT**: Change the dropdown to **"Embed & Sign"**
8. Click **Add**

### Step 5: Add Framework Search Path

1. Still in **TARGETS → Runner**
2. Go to **Build Settings** tab
3. Search for **"Framework Search Paths"**
4. Double-click the value
5. Click the **+** button
6. Add: `$(PROJECT_DIR)/UnityLibrary`
7. Set to **recursive**

### Step 6: Disable Bitcode (for Unity-iPhone project)

1. Select **Unity-iPhone** in Project Navigator
2. Select **PROJECT → Unity-iPhone** (not TARGETS)
3. Go to **Build Settings** tab
4. Search for **"Enable Bitcode"**
5. Set to **No**

### Step 7: Configure Signing

1. Select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Select your development team
4. Ensure automatic signing is enabled

Repeat for **Unity-iPhone** targets if prompted.

### Step 8: Clean Build Folder

In Xcode menu: **Product → Clean Build Folder** (⇧⌘K)

---

## Flutter Configuration

### Android Configuration

#### Update settings.gradle

Add to `android/settings.gradle`:
```gradle
include ':unityLibrary'
project(':unityLibrary').projectDir = new File('./unityLibrary')
```

#### Update build.gradle.kts

Your `android/app/build.gradle.kts` should have (already configured):
```kotlin
dependencies {
    implementation(project(":unityLibrary"))
}

packaging {
    resources {
        excludes.addAll(listOf(
            "META-INF/DEPENDENCIES",
            "META-INF/LICENSE",
            "META-INF/LICENSE.txt",
            "META-INF/NOTICE",
            "META-INF/NOTICE.txt"
        ))
        pickFirsts.add("**/*.jar")
    }
    jniLibs {
        pickFirsts.add("**/*.so")
    }
}
```

### Using Unity in Flutter Code

#### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityGameScreen extends StatefulWidget {
  const UnityGameScreen({Key? key}) : super(key: key);

  @override
  State<UnityGameScreen> createState() => _UnityGameScreenState();
}

class _UnityGameScreenState extends State<UnityGameScreen> {
  late UnityWidgetController _unityWidgetController;
  bool _isUnityReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity Game'),
      ),
      body: SafeArea(
        child: UnityWidget(
          onUnityCreated: _onUnityCreated,
          onUnityMessage: _onUnityMessage,
          onUnitySceneLoaded: _onUnitySceneLoaded,
          fullscreen: false,
        ),
      ),
      floatingActionButton: _isUnityReady
          ? FloatingActionButton(
              onPressed: _sendMessageToUnity,
              child: const Icon(Icons.send),
            )
          : null,
    );
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    setState(() {
      _isUnityReady = true;
    });
    print('Unity initialized successfully');
  }

  void _onUnityMessage(dynamic message) {
    print('Message from Unity: $message');
    // Handle messages from Unity here
  }

  void _onUnitySceneLoaded(SceneLoaded? scene) {
    print('Unity scene loaded: ${scene?.name}');
  }

  void _sendMessageToUnity() {
    // Send message to Unity GameObject
    _unityWidgetController.postMessage(
      'GameObjectName',
      'MethodName',
      'Message from Flutter',
    );
  }

  @override
  void dispose() {
    _unityWidgetController.dispose();
    super.dispose();
  }
}
```

#### Communication Between Flutter and Unity

**Flutter → Unity:**
```dart
// Call a method on a Unity GameObject
_unityWidgetController.postMessage(
  'GameManager',      // GameObject name
  'StartGame',        // Method name in Unity script
  'difficulty:hard',  // Message parameter
);

// Pause Unity
_unityWidgetController.pause();

// Resume Unity
_unityWidgetController.resume();
```

**Unity → Flutter:**

In your Unity C# script:
```csharp
using System.Runtime.InteropServices;

public class GameManager : MonoBehaviour
{
    [DllImport("__Internal")]
    private static extern void SendMessageToFlutter(string message);

    public void NotifyFlutter(string message)
    {
        SendMessageToFlutter(message);
    }
}
```

---

## Build and Run

### Pre-Build Checklist

- [ ] `ios/UnityLibrary/` folder exists and is populated
- [ ] Xcode workspace configured correctly
- [ ] UnityFramework added to Runner as "Embed & Sign"
- [ ] Framework Search Path includes `$(PROJECT_DIR)/UnityLibrary`
- [ ] Info.plist has `io.flutter.embedded_views_preview`
- [ ] Physical iOS device connected (recommended)

### Build Commands

#### Clean Build (recommended first time)
```bash
flutter clean
cd ios
pod install
cd ..
flutter run
```

#### Subsequent Builds
```bash
flutter run
```

#### Select Device
When prompted, select your physical iOS device from the list. Avoid simulators if possible.

### First-Time Device Setup

1. **Trust Developer Certificate**:
   - After first launch, you may see "Untrusted Developer" on device
   - Go to: Settings → General → VPN & Device Management
   - Trust your developer certificate
   - Try running again

2. **Verify Xcode Device Setup**:
   - Open Xcode
   - Window → Devices and Simulators
   - Ensure your device is trusted and ready

### Building from Xcode (Alternative)

If Flutter build fails:
```bash
cd ios
open Runner.xcworkspace
```
- Select your physical device
- Click the Play button (⌘R)
- Wait for build to complete
- If successful, try `flutter run` again

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Unable to find module dependency: 'UnityFramework'"

**Cause**: UnityFramework not properly linked to Runner target

**Solution**:
1. Verify UnityFramework.framework is in "Frameworks, Libraries, and Embedded Content" as "Embed & Sign"
2. Check Framework Search Path includes `$(PROJECT_DIR)/UnityLibrary`
3. Clean build folder in Xcode (Product → Clean Build Folder)
4. Run `flutter clean`

#### Issue: "Value of type 'UnityAppController' has no member 'unityMessageHandler'"

**Cause**: Unity build was not exported using flutter_unity_widget integration

**Solution**:
- You need a Unity build that was exported specifically for Flutter
- Standard Unity iOS exports won't work
- If using git package instead of pub.dev version, this may be resolved
- Ensure pubspec.yaml uses the git repository version:
```yaml
flutter_unity_widget:
  git:
    url: https://github.com/juicycleff/flutter-unity-view-widget.git
    ref: master
```

#### Issue: "Could not build the application for the simulator"

**Cause**: Unity iOS builds are typically compiled for device architecture only

**Solution**:
- Use a physical iOS device instead of simulator
- OR re-export Unity build with "Simulator SDK" target (not recommended)

#### Issue: "2 projects found in ios directory"

**Cause**: Multiple .xcodeproj files at root level

**Solution**:
- Ensure Unity-iPhone.xcodeproj is only in `ios/UnityLibrary/`
- Remove any Unity project files from `ios/` root
- Only `Runner.xcodeproj` should be at `ios/` root level

#### Issue: Data folder not showing UnityFramework target membership

**Cause**: Data folder not properly added to Xcode project

**Solution**:
1. Close Xcode
2. Re-open `Runner.xcworkspace`
3. Right-click Unity-iPhone → "Add Files to Unity-iPhone..."
4. Navigate to and select the Data folder
5. Ensure "Create folder references" (blue folder) is selected
6. Click Add
7. Select Data folder and set target membership to UnityFramework

#### Issue: Build succeeds but Unity content doesn't appear

**Possible Causes & Solutions**:
1. Unity scene not loaded properly
   - Check Unity export includes all required scenes
   - Verify scene is added to Build Settings in Unity

2. Platform view not enabled
   - Verify Info.plist has `io.flutter.embedded_views_preview`

3. Widget configuration issue
   - Check UnityWidget parameters in Flutter code
   - Ensure `fullscreen` property is set appropriately

#### Issue: App crashes on launch

**Check**:
1. Device logs in Xcode (Window → Devices and Simulators → View Device Logs)
2. Unity framework compatibility with iOS version
3. Memory usage (Unity games can be memory-intensive)

### Debug Commands

```bash
# Check Unity package installation
flutter pub deps | grep flutter_unity_widget

# Verify UnityLibrary structure
ls -R ios/UnityLibrary/

# Check pod installation
cd ios
pod list | grep flutter_unity_widget
cd ..

# View detailed build logs
flutter run -v

# Clear all caches
flutter clean
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

---

## Git Configuration

### Important: Do NOT Commit Unity Builds

Unity builds are large (100MB - 1GB+) and platform-specific. They should not be committed to git.

### Update .gitignore

Add these lines to your `.gitignore`:

```gitignore
# Unity Exports - Large files, regenerate locally
ios/UnityLibrary/
android/unityLibrary/

# Unity Source (if you have it)
unity/[Ll]ibrary/
unity/[Tt]emp/
unity/[Oo]bj/
unity/[Bb]uild/
unity/[Bb]uilds/
unity/[Ll]ogs/
unity/[Uu]ser[Ss]ettings/

# Unity Generated
*.csproj
*.unityproj
*.sln
*.suo
*.tmp
*.user
*.userprefs
*.pidb
*.booproj
*.svd
*.pdb
*.mdb
*.opendb
*.VC.db
```

### What TO Commit

```gitignore
# DO commit these
ios/Runner.xcodeproj/
ios/Runner.xcworkspace/
ios/Podfile
ios/Podfile.lock
ios/Runner/Info.plist
android/app/build.gradle.kts
android/settings.gradle
pubspec.yaml
pubspec.lock
lib/
README.md
UNITY_INTEGRATION.md  # This documentation
```

---

## Team Workflow

### For Developers Without Unity Source

If you clone this repository and don't have the Unity source project:

#### 1. Obtain Unity Build
Contact the team lead to get:
- Pre-built `ios/UnityLibrary/` folder (iOS)
- Pre-built `android/unityLibrary/` folder (Android)

These can be shared via:
- Google Drive / Dropbox
- Internal file server
- USB drive

#### 2. Place Builds
```bash
# Extract and place Unity builds
cp -r path/to/ios-build/* ios/UnityLibrary/
cp -r path/to/android-build/* android/unityLibrary/
```

#### 3. Setup Project
```bash
flutter pub get
cd ios
pod install
cd ..
```

#### 4. Configure Xcode
Follow the [Xcode Configuration](#xcode-configuration) steps above.

#### 5. Build and Run
```bash
flutter run
```

### For Developers With Unity Source

If you have access to the Unity project:

#### 1. Clone Repository
```bash
git clone <repository-url>
cd SavvyBee-FrontEnd
```

#### 2. Setup Flutter
```bash
flutter pub get
```

#### 3. Export from Unity
1. Open Unity project from `unity/` folder
2. Ensure Flutter Unity package is imported
3. Export iOS: `Flutter → Export iOS Debug`
4. Export Android: `Flutter → Export Android Debug`

#### 4. Configure Xcode
Follow the [Xcode Configuration](#xcode-configuration) steps.

#### 5. Install iOS Dependencies
```bash
cd ios
pod install
cd ..
```

#### 6. Build and Run
```bash
flutter run
```

### Updating Unity Content

When Unity game is updated:

#### With Unity Source:
1. Pull latest Unity project changes
2. Open in Unity Editor
3. Re-export: `Flutter → Export iOS/Android`
4. Rebuild Flutter app

#### Without Unity Source:
1. Obtain updated Unity build from team
2. Delete old `ios/UnityLibrary/` or `android/unityLibrary/`
3. Replace with new build
4. Rebuild Flutter app

---

## Additional Resources

### Documentation
- [flutter_unity_widget GitHub](https://github.com/juicycleff/flutter-unity-view-widget)
- [Unity iOS Build Documentation](https://docs.unity3d.com/Manual/iphone.html)
- [Flutter Platform Integration](https://docs.flutter.dev/platform-integration)
- [Flutter Platform Views](https://docs.flutter.dev/platform-integration/platform-views)

### Common Commands Quick Reference

```bash
# Clean everything
flutter clean && cd ios && pod install && cd ..

# Check Flutter setup
flutter doctor -v

# List available devices
flutter devices

# Run with verbose logging
flutter run -v

# Run on specific device
flutter run -d <device-id>

# Build release version (iOS)
flutter build ios --release

# Open Xcode workspace
cd ios && open Runner.xcworkspace

# View Flutter logs
flutter logs
```

### Support

For issues with:
- **Flutter integration**: Check flutter_unity_widget GitHub issues
- **Unity export**: Refer to Unity documentation or contact Unity developer
- **Xcode configuration**: Review Apple developer documentation
- **Project-specific issues**: Contact team lead

---

## Version History

- **v1.0** (2026-01-08): Initial iOS Unity integration setup
  - Using flutter_unity_widget from git (master branch)
  - Configured for iOS 13.0+
  - Xcode workspace setup documented
  - Physical device testing only

---

## Notes

1. **Always use physical devices** for Unity iOS testing - simulator support is limited
2. **Always open Runner.xcworkspace** - never use Runner.xcodeproj directly
3. **UnityFramework must be "Embed & Sign"** - not just "Embed"
4. **Data folder must be in UnityFramework target** - critical for proper build
5. **Clean builds resolve 90% of issues** - when in doubt, clean everything
6. **Unity builds are platform-specific** - iOS build won't work on Android and vice versa

---

*Last Updated: January 8, 2026*
