# Savvy Bee Mobile - Development Setup Guide

This comprehensive guide will walk you through setting up your development environment for the Savvy Bee mobile application, including all necessary tools, dependencies, and configurations.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Project Setup](#project-setup)
4. [Configuration Setup](#configuration-setup)
5. [Running the Application](#running-the-application)
6. [Development Tools](#development-tools)
7. [Troubleshooting](#troubleshooting)
8. [Useful Commands](#useful-commands)

## Prerequisites

### Required Software

1. **Flutter SDK**
   - Flutter version: 3.16.0 or higher
   - Dart version: 3.2.0 or higher
   - Installation: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. **Development Environment**
   - **Android Studio** (recommended) or **Visual Studio Code**
   - **Xcode** (for iOS development on macOS)
   - **Git** for version control

3. **Node.js and npm** (for some development tools)
   - Node.js version: 18.x or higher
   - npm version: 9.x or higher

4. **Java Development Kit (JDK)**
   - JDK version: 11 or higher
   - Required for Android development

### System Requirements

#### Windows
- Windows 10 or later (64-bit)
- Windows PowerShell 5.0 or later
- Git for Windows

#### macOS
- macOS 10.14 (Mojave) or later
- Xcode 12 or later
- CocoaPods for iOS dependencies

#### Linux
- 64-bit Linux distribution
- GLIBC 2.17 or later

## Development Environment Setup

### 1. Install Flutter SDK

#### Windows
```powershell
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS
```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually from https://flutter.dev/docs/get-started/install/macos
# Extract to ~/development/flutter
# Add to PATH: echo 'export PATH="$PATH:~/development/flutter/bin"' >> ~/.zshrc

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
sudo mv flutter /opt/flutter
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor
```

### 2. Install Android Development Tools

#### Android Studio Setup
1. Download and install Android Studio from [developer.android.com](https://developer.android.com/studio)
2. Install Android SDK components through Android Studio SDK Manager
3. Configure Android Virtual Device (AVD) for testing

#### Command Line Tools (Alternative)
```bash
# Download Android Command Line Tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-9477386_latest.zip
mkdir -p ~/android-sdk/cmdline-tools
mv cmdline-tools ~/android-sdk/cmdline-tools/latest

# Set environment variables
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
source ~/.bashrc

# Install required SDK components
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### 3. Install iOS Development Tools (macOS only)

#### Xcode Setup
```bash
# Install Xcode from Mac App Store or Apple Developer Portal
# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Accept Xcode licenses
sudo xcodebuild -license accept
```

### 4. Install Visual Studio Code (Optional)

#### VS Code Setup
1. Download VS Code from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install Flutter and Dart extensions
3. Configure settings for optimal Flutter development

#### Recommended VS Code Extensions
```bash
# Flutter and Dart
code --install-extension dart-code.flutter
code --install-extension dart-code.dart

# Additional useful extensions
code --install-extension bradlc.vscode-tailwindcss
code --install-extension pkief.material-icon-theme
code --install-extension ms-vscode.vscode-json
```

## Project Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/Savvy-Bee/Savvy-Bee-FrontEnd.git
cd savvy-bee-mobile

# Create development branch
git checkout -b development
```

### 2. Install Dependencies

```bash
# Get Flutter dependencies
flutter pub get

# Generate code (if using code generation)
flutter pub run build_runner build --delete-conflicting-outputs

# For iOS (macOS only)
cd ios && pod install && cd ..
```

### 3. Configure Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your configuration
nano .env
```

### 4. Setup Firebase (if using Firebase)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Setup Firebase for the project
flutterfire configure
```

## Configuration Setup

### 1. Environment Configuration

Create a `.env` file in the project root:

```bash
# Development environment
API_BASE_URL=https://api-dev.savvybee.ng/api/v1/

# Mono Bank Integration (Test Keys)
MONO_SECRET=test_sk_j9hfeaeyl0gaevt9v37v
MONO_PUBLIC=test_pk_u7qxf0kjlnwa8o4dg64w

# Encryption Key (Generate a secure key)
ENCRYPTION_KEY=your_secure_encryption_key_here
```

### 2. Android Configuration

#### Android Manifest Configuration
Check `android/app/src/main/AndroidManifest.xml` for required permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

#### Build Configuration
Check `android/app/build.gradle` for proper configuration:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.mysavvybee"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        debug {
            storeFile file("debug.keystore")
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
    }
}
```

### 3. iOS Configuration (macOS only)

#### Info.plist Configuration
Check `ios/Runner/Info.plist` for required permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take profile photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select profile photos</string>
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure authentication</string>
<key>NSBiometricUsageDescription</key>
<string>This app uses biometric authentication for security</string>
```

#### Podfile Configuration
Check `ios/Podfile` for proper configuration:

```ruby
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

## Running the Application

### 1. Check Flutter Doctor

```bash
# Check if everything is properly configured
flutter doctor

# Expected output should show:
# [✓] Flutter (Channel stable, 3.16.0, on macOS 14.0 23A344 darwin-arm64, locale en-US)
# [✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
# [✓] Xcode - develop for iOS and macOS (Xcode 15.0)
# [✓] Chrome - develop for the web
# [✓] Android Studio (version 2023.1)
# [✓] VS Code (version 1.84.0)
# [✓] Connected device (1 available)
# [✓] Network resources
```

### 2. Run on Different Platforms

#### Android (Emulator/Device)
```bash
# List available devices
flutter devices

# Run on specific Android device
flutter run -d android

# Run with debug mode
flutter run --debug

# Run with hot reload
flutter run --hot
```

#### iOS (macOS only)
```bash
# List available iOS simulators
flutter devices

# Run on iOS simulator
flutter run -d ios

# Run on specific iOS device
flutter run -d "iPhone 15 Pro"
```

#### Web (Development)
```bash
# Run on web browser
flutter run -d chrome

# Run on web with specific port
flutter run -d chrome --web-port=8080
```

### 3. Build for Release

#### Android APK
```bash
# Build APK
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release
```

#### iOS (macOS only)
```bash
# Build for iOS
flutter build ios --release

# Build for iOS archive
flutter build ios --release --no-codesign
```

## Development Tools

### 1. Flutter DevTools

```bash
# Install DevTools
flutter pub global activate devtools

# Run DevTools
flutter pub global run devtools

# Run app with DevTools
flutter run --debug
```

### 2. Code Generation

```bash
# Generate code (if using code generation)
flutter pub run build_runner build

# Watch for changes and auto-generate
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Static Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check dependencies
flutter pub deps
```

### 4. Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Flutter Doctor Issues

**Issue**: `flutter doctor` shows missing dependencies
```bash
# Update Flutter
flutter upgrade

# Clean Flutter cache
flutter clean

# Get dependencies again
flutter pub get
```

#### 2. Android Issues

**Issue**: Android license not accepted
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Update Android SDK
sdkmanager --update
```

**Issue**: Gradle build failed
```bash
# Clean Android build
cd android && ./gradlew clean && cd ..

# Update Gradle wrapper
./gradlew wrapper --gradle-version=8.0
```

#### 3. iOS Issues (macOS only)

**Issue**: CocoaPods installation failed
```bash
# Update CocoaPods
sudo gem install cocoapods

# Update pod repo
pod repo update

# Reinstall pods
cd ios && pod install --repo-update && cd ..
```

**Issue**: Xcode build failed
```bash
# Clean Xcode build
cd ios && xcodebuild clean && cd ..

# Update Xcode command line tools
sudo xcode-select --reset
```

#### 4. Dependency Issues

**Issue**: Package conflicts
```bash
# Update pubspec.yaml
flutter pub upgrade

# Force update
flutter pub upgrade --major-versions

# Clear pub cache
flutter pub cache repair
```

#### 5. Environment Variable Issues

**Issue**: Environment variables not loading
```bash
# Check .env file exists
cat .env

# Verify environment variables are loaded
flutter run --dart-define=ENVIRONMENT=development
```

### Performance Issues

#### 1. Slow Build Times
```bash
# Enable parallel builds
export FLUTTER_BUILD_PARALLEL=true

# Use incremental builds
flutter run --hot

# Optimize build configuration
flutter build apk --split-debug-info=debug_symbols
```

#### 2. Memory Issues
```bash
# Monitor memory usage
flutter run --debug --verbose

# Use DevTools memory view
flutter pub global run devtools
```

## Useful Commands

### Development Commands

```bash
# Flutter doctor
flutter doctor -v

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for web
flutter build web --release

# Generate icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

### Git Commands

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Add changes
git add .

# Commit changes
git commit -m "feat: your feature description"

# Push changes
git push origin feature/your-feature-name

# Pull latest changes
git pull origin main

# Rebase on main
git rebase main
```

### Debugging Commands

```bash
# Run with verbose output
flutter run --verbose

# Run with debug mode
flutter run --debug

# Run with hot reload
flutter run --hot

# Run with specific device
flutter run -d emulator-5554

# Run with specific flavor
flutter run --flavor development

# Run with Dart DevTools
flutter run --debug --devtools-server-address http://localhost:9100
```
