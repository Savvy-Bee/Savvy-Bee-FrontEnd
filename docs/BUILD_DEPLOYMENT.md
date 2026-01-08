# Savvy Bee Mobile - Build and Deployment Guide

This guide covers the complete build and deployment processes for the Savvy Bee mobile application, including local builds, CI/CD pipelines, and production deployments.

## Table of Contents

1. [Build Environment Setup](#build-environment-setup)
2. [Local Build Process](#local-build-process)
3. [Release Build Configuration](#release-build-configuration)
4. [Platform-Specific Builds](#platform-specific-builds)
5. [CI/CD Pipeline Setup](#cicd-pipeline-setup)
6. [Deployment Strategies](#deployment-strategies)
7. [App Store Deployment](#app-store-deployment)

## Build Environment Setup

### Prerequisites

1. **Flutter SDK**
   - Version: 3.16.0 or higher
   - Channel: Stable
   - Installation: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. **Development Tools**
   - Android Studio with Android SDK
   - Xcode (for iOS builds on macOS)
   - Git for version control
   - Node.js and npm (for CI/CD tools)

3. **Build Tools**
   - Android: Gradle 8.0+, Android SDK 34
   - iOS: Xcode 15+, iOS 12.0+ deployment target
   - Web: Modern web browser support

4. **Environment Variables**
   ```bash
   # Required environment variables
   export FLUTTER_ROOT="/path/to/flutter"
   export ANDROID_HOME="/path/to/android-sdk"
   export PATH="$PATH:$FLUTTER_ROOT/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
   ```

### Build Environment Configuration

#### 1. Flutter Environment Setup

```bash
# Verify Flutter installation
flutter doctor

# Switch to stable channel (if not already)
flutter channel stable
flutter upgrade

# Enable web support (if needed)
flutter config --enable-web

# Enable desktop support (if needed)
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

#### 2. Android Build Environment

```bash
# Set Android SDK location
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# Accept Android licenses
flutter doctor --android-licenses

# Verify Android setup
flutter doctor -v
```

#### 3. iOS Build Environment (macOS only)

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Accept Xcode licenses
sudo xcodebuild -license accept

# Install CocoaPods
sudo gem install cocoapods

# Setup CocoaPods
pod setup
```

## Local Build Process

### 1. Pre-Build Checklist

```bash
# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Generate code (if using code generation)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run static analysis
flutter analyze

# 5. Run tests
flutter test

# 6. Check for security vulnerabilities
flutter pub deps
```

### 2. Build Configuration Files

#### Environment Configuration

Create build configuration files for different environments:

**`build_config/development.json`**
```json
{
  "environment": "development",
  "api_base_url": "https://api-dev.savvybee.ng/api/v1/",
  "mono_public_key": "test_pk_u7qxf0kjlnwa8o4dg64w",
  "enable_analytics": false,
  "enable_crashlytics": false,
  "debug_mode": true
}
```

**`build_config/staging.json`**
```json
{
  "environment": "staging",
  "api_base_url": "https://api-staging.savvybee.ng/api/v1/",
  "mono_public_key": "test_pk_u7qxf0kjlnwa8o4dg64w",
  "enable_analytics": true,
  "enable_crashlytics": true,
  "debug_mode": false
}
```

**`build_config/production.json`**
```json
{
  "environment": "production",
  "api_base_url": "https://api.savvybee.ng/api/v1/",
  "mono_public_key": "live_pk_production_key_here",
  "enable_analytics": true,
  "enable_crashlytics": true,
  "debug_mode": false
}
```

#### Build Scripts

**`scripts/build.sh`**
```bash
#!/bin/bash

# Build script for Savvy Bee Mobile
set -e

ENVIRONMENT=${1:-development}
PLATFORM=${2:-all}

echo "Building Savvy Bee Mobile for $ENVIRONMENT environment on $PLATFORM platform"

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run static analysis
flutter analyze

# Build based on platform
case $PLATFORM in
  android)
    build_android $ENVIRONMENT
    ;;
  ios)
    build_ios $ENVIRONMENT
    ;;
  web)
    build_web $ENVIRONMENT
    ;;
  all)
    build_android $ENVIRONMENT
    build_ios $ENVIRONMENT
    build_web $ENVIRONMENT
    ;;
  *)
    echo "Invalid platform: $PLATFORM"
    exit 1
    ;;
esac

echo "Build completed successfully!"

build_android() {
  local env=$1
  echo "Building Android APK for $env environment..."
  
  flutter build apk \
    --release \
    --flavor $env \
    --target-platform android-arm64 \
    --split-debug-info=build/app/outputs/symbols \
    --build-name=$(get_build_name $env) \
    --build-number=$(get_build_number $env)
}

build_ios() {
  local env=$1
  echo "Building iOS for $env environment..."
  
  flutter build ios \
    --release \
    --flavor $env \
    --build-name=$(get_build_name $env) \
    --build-number=$(get_build_number $env) \
    --no-codesign
}

build_web() {
  local env=$1
  echo "Building Web for $env environment..."
  
  flutter build web \
    --release \
    --dart-define=ENVIRONMENT=$env \
    --base-href=/ \
    --web-renderer canvaskit
}

get_build_name() {
  local env=$1
  case $env in
    development)
      echo "1.0.0-dev"
      ;;
    staging)
      echo "1.0.0-staging"
      ;;
    production)
      echo "1.0.0"
      ;;
  esac
}

get_build_number() {
  local env=$1
  case $env in
    development)
      echo "$(date +%Y%m%d%H%M)"
      ;;
    staging)
      echo "$(date +%Y%m%d%H%M)"
      ;;
    production)
      echo "1"
      ;;
  esac
}

# Make script executable
chmod +x scripts/build.sh
```

## Release Build Configuration

### 1. Version Management

#### Version Configuration

**`pubspec.yaml`**
```yaml
name: savvy_bee_mobile
description: An AI-powered financial literacy and management app
version: 1.0.0+1  # format: versionName+versionCode

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"
```

#### Build Number Automation

**`scripts/version_bump.sh`**
```bash
#!/bin/bash

# Version bump script
set -e

TYPE=${1:-patch}

echo "Bumping version: $TYPE"

# Get current version
CURRENT_VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2)
VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
VERSION_CODE=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$VERSION_NAME"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Bump version based on type
case $TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Invalid version type: $TYPE"
    exit 1
    ;;
esac

# Increment build number
VERSION_CODE=$((VERSION_CODE + 1))

# New version
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$VERSION_CODE"

# Update pubspec.yaml
sed -i.bak "s/version: .*/version: $NEW_VERSION/" pubspec.yaml

# Update Android build.gradle
sed -i.bak "s/versionCode .*/versionCode $VERSION_CODE/" android/app/build.gradle
sed -i.bak "s/versionName .*/versionName \"$MAJOR.$MINOR.$PATCH\"/" android/app/build.gradle

# Update iOS Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $MAJOR.$MINOR.$PATCH" ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION_CODE" ios/Runner/Info.plist

echo "Version bumped from $CURRENT_VERSION to $NEW_VERSION"
```

### 2. Signing Configuration

#### Android Signing

**`android/app/build.gradle`**
```gradle
android {
    signingConfigs {
        release {
            storeFile file("../release.keystore")
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**`android/key.properties`**
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../release.keystore
```

#### iOS Signing

**`ios/Runner.xcodeproj/project.pbxproj`**
```xml
// Development team and provisioning profile
DEVELOPMENT_TEAM = YOUR_TEAM_ID
PROVISIONING_PROFILE_SPECIFIER = "Savvy Bee Development"
CODE_SIGN_STYLE = Automatic
```

### 3. ProGuard Configuration

**`android/app/proguard-rules.pro`**
```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Riverpod
-keep class ** implements StateNotifier { *; }
-keep class ** extends _$* { *; }

# Dio
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep model classes
-keep class com.savvybee.mobile.** { *; }
-keepclassmembers class com.savvybee.mobile.** { *; }

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
```

## Platform-Specific Builds

### Android Build Process

#### 1. APK Build

```bash
# Development APK
flutter build apk --debug --flavor development

# Staging APK
flutter build apk --profile --flavor staging

# Production APK
flutter build apk --release --flavor production
```

#### 2. App Bundle Build (Recommended for Play Store)

```bash
# Development app bundle
flutter build appbundle --debug --flavor development

# Production app bundle
flutter build appbundle --release --flavor production
```

#### 3. Build Configuration

**`android/app/build.gradle`**
```gradle
android {
    flavorDimensions "version"
    
    productFlavors {
        development {
            dimension "version"
            applicationId "com.savvybee.mobile.dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Savvy Bee Dev"
        }
        
        staging {
            dimension "version"
            applicationId "com.savvybee.mobile.staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "Savvy Bee Staging"
        }
        
        production {
            dimension "version"
            applicationId "com.savvybee.mobile"
            resValue "string", "app_name", "Savvy Bee"
        }
    }
}
```

### iOS Build Process

#### 1. iOS Build

```bash
# Development build
flutter build ios --debug --flavor development

# Staging build
flutter build ios --profile --flavor staging

# Production build
flutter build ios --release --flavor production
```

#### 2. Archive Build (for App Store)

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build for archive
flutter build ios --release --no-codesign

# Open Xcode
cd ios && open Runner.xcworkspace

# In Xcode:
# 1. Select Generic iOS Device
# 2. Product > Archive
# 3. Distribute App
```

#### 3. Build Configuration

**`ios/Runner.xcodeproj/project.pbxproj`**
```xml
// Build configurations for different flavors
XCBuildConfiguration section
    baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
    buildSettings = {
        PRODUCT_BUNDLE_IDENTIFIER = com.savvybee.mobile.dev;
        PRODUCT_NAME = "Savvy Bee Dev";
    };
```

### Web Build Process

#### 1. Web Build

```bash
# Development web build
flutter build web --debug --dart-define=ENVIRONMENT=development

# Production web build
flutter build web --release --dart-define=ENVIRONMENT=production
```

#### 2. Web Configuration

**`web/index.html`**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta content="IE=Edge" http-equiv="X-UA-Compatible">
    <meta name="description" content="Savvy Bee - Financial Literacy App">
    
    <!-- iOS meta tags & icons -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-title" content="Savvy Bee">
    
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="favicon.png"/>
    
    <title>Savvy Bee</title>
    <link rel="manifest" href="manifest.json">
    
    <script>
        // The value below is injected by flutter build, do not touch.
        var serviceWorkerVersion = null;
    </script>
    <!-- This script adds the flutter initialization JS code -->
    <script src="flutter.js" defer></script>
</head>
<body>
    <script>
        window.addEventListener('load', function(ev) {
            // Download main.dart.js
            _flutter.loader.loadEntrypoint({
                serviceWorker: {
                    serviceWorkerVersion: serviceWorkerVersion,
                }
            }).then(function(engineInitializer) {
                return engineInitializer.initializeEngine();
            }).then(function(appRunner) {
                return appRunner.runApp();
            });
        });
    </script>
</body>
</html>
```

## CI/CD Pipeline Setup

### 1. GitHub Actions Configuration

#### `.github/workflows/ci.yml`
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter pub run build_runner build --delete-conflicting-outputs
    
    - name: Run static analysis
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'
    
    - name: Setup Android SDK
      uses: android-actions/setup-android@v2
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter pub run build_runner build --delete-conflicting-outputs
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build App Bundle
      run: flutter build appbundle --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-release.apk
    
    - name: Upload App Bundle
      uses: actions/upload-artifact@v3
      with:
        name: android-app-bundle
        path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter pub run build_runner build --delete-conflicting-outputs
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload iOS Build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  deploy-staging:
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    steps:
    - name: Deploy to Staging
      run: |
        echo "Deploying to staging environment..."
        # Add staging deployment commands here
```

### 2. Fastlane Configuration

#### `fastlane/Fastfile`
```ruby
# Fastlane configuration for automated builds and deployments

default_platform(:android)

platform :android do
  desc "Build Android APK"
  lane :build_apk do
    gradle(task: "assembleRelease")
  end
  
  desc "Build Android App Bundle"
  lane :build_aab do
    gradle(task: "bundleRelease")
  end
  
  desc "Deploy to Google Play Store"
  lane :deploy do
    gradle(task: "bundleRelease")
    upload_to_play_store(
      track: 'production',
      release_status: 'draft'
    )
  end
  
  desc "Deploy to Firebase App Distribution"
  lane :distribute do
    gradle(task: "assembleRelease")
    firebase_app_distribution(
      app: ENV["FIREBASE_APP_ID"],
      testers: "testers@savvybee.com",
      groups: "qa-team",
      release_notes: "Latest build from CI/CD"
    )
  end
end

platform :ios do
  desc "Build iOS"
  lane :build do
    build_app(
      scheme: "Runner",
      configuration: "Release"
    )
  end
  
  desc "Deploy to TestFlight"
  lane :deploy do
    build_app(
      scheme: "Runner",
      configuration: "Release"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end
```

## Deployment Strategies (Optional)

### 1. Blue-Green Deployment

#### Strategy Overview
- Maintain two identical production environments
- Deploy to inactive environment
- Switch traffic after validation
- Rollback by switching back

#### Implementation
```bash
# Deploy to blue environment
kubectl apply -f k8s/blue-deployment.yaml

# Validate deployment
kubectl rollout status deployment/savvybee-blue

# Switch traffic to blue
kubectl patch service savvybee-service -p '{"spec":{"selector":{"version":"blue"}}}'

# Keep green as backup
```

### 2. Canary Deployment

#### Strategy Overview
- Deploy to small subset of users
- Gradually increase traffic
- Monitor metrics and errors
- Full rollout after validation

#### Implementation
```bash
# Deploy canary version
kubectl apply -f k8s/canary-deployment.yaml

# Route 10% traffic to canary
kubectl patch virtualservice savvybee -p '{"spec":{"http":[{"match":[{"headers":{"canary":{"exact":"true"}}}],"route":[{"destination":{"host":"savvybee-canary"}}]},{"route":[{"destination":{"host":"savvybee-stable"}}]}]}}'

# Monitor metrics
kubectl top pods -l app=savvybee
```

### 3. Rolling Deployment

#### Strategy Overview
- Replace instances gradually
- Zero downtime deployment
- Automatic rollback on failure
- Resource efficient

#### Implementation
```bash
# Rolling update
kubectl set image deployment/savvybee savvybee=savvybee:v2.0.0

# Monitor rollout
kubectl rollout status deployment/savvybee

# Rollback if needed
kubectl rollout undo deployment/savvybee
```

## App Store Deployment

### 1. Google Play Store Deployment

#### Prerequisites
- Google Play Console account
- Signed release build
- App bundle (AAB format recommended)
- Store listing assets

#### Deployment Process

```bash
# Build app bundle
flutter build appbundle --release

# Upload to Play Console
# 1. Go to Play Console
# 2. Create new release
# 3. Upload AAB file
# 4. Fill release notes
# 5. Submit for review
```

#### Automated Deployment with Fastlane

```bash
# Setup Fastlane
fastlane init

# Configure deployment
fastlane android deploy
```

### 2. Apple App Store Deployment

#### Prerequisites
- Apple Developer account
- App Store Connect account
- Signed release build
- App Store listing assets

#### Deployment Process

```bash
# Build for App Store
flutter build ios --release

# Create archive in Xcode
# 1. Open ios/Runner.xcworkspace
# 2. Select Generic iOS Device
# 3. Product > Archive
# 4. Distribute App > App Store Connect
```

#### Automated Deployment with Fastlane

```bash
# Setup Fastlane
fastlane init

# Configure deployment
fastlane ios deploy
```

This build and deployment guide ensures that the Savvy Bee mobile application can be built, deployed, and maintained efficiently across all platforms and environments.