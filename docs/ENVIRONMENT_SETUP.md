# 🔧 Flutter Core Project - Environment Setup Guide

**Project:** Flutter Core Project  
**Repository:** flutter_core (Owner: ngonhatcuonguit)  
**Branch:** clean_architecture  
**Last Updated:** 10 December 2025  
**Status:** ✅ VERIFIED WORKING

---

## 📋 Table of Contents

1. [Quick Summary](#quick-summary)
2. [Hardware Specifications](#hardware-specifications)
3. [Core Tools & Versions](#core-tools--versions)
4. [Detailed Configuration](#detailed-configuration)
5. [Environment Variables](#environment-variables)
6. [Project Configuration](#project-configuration)
7. [Installation Steps](#installation-steps)
8. [Verification](#verification)
9. [Troubleshooting](#troubleshooting)

---

## Quick Summary

### ⚡ Essential Versions

```
Flutter:    3.13.8 (stable, commit: 6c4930c4ac)
Dart:       3.1.4 (bundled)
Java JDK:   18.0.2 (Oracle)
Android:    SDK 34, Build Tools 34.0.0
Gradle:     7.5 (wrapper)
AGP:        7.3.0 (Android Gradle Plugin)
Kotlin:     1.7.10
Xcode:      14.1 (macOS)
CocoaPods:  1.15.2 (macOS)
Node.js:    20.19.4 (optional)
```

### ⚠️ Critical Requirements

- **EXACT versions required** - Do NOT update without testing
- **JDK 18.0.2** mandatory (not JDK 11 or 8)
- **Gradle 7.5** via wrapper only (do not install system-wide)
- **Android SDK 34** with Build Tools 34.0.0
- **Intel Mac** setup (x86_64) - different from Apple Silicon

---

## Hardware Specifications

```
CPU:          Intel Core i7-4770HQ @ 2.20GHz
Architecture: x86_64 (Intel 64-bit)
RAM:          16 GB
OS:           macOS Monterey 12.7.6
Build:        21H1320
Kernel:       Darwin 21.6.0
```

**Note:** This is an Intel Mac. Apple Silicon (M1/M2/M3) may have different configurations.

---

## Core Tools & Versions

### 1. Flutter SDK

```yaml
Version: 3.13.8
Channel: stable
Git Commit: 6c4930c4ac86fb286f30e31d0ec8bffbcbb9953e
Path: /Users/mac/development/flutter
DevTools: 2.25.0
```

**Installation:**
```bash
# Clone Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
cd ~/development/flutter
git checkout 6c4930c4ac

# Add to PATH (in ~/.zshrc)
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
```

**Verification:**
```bash
flutter --version
cd ~/development/flutter && git rev-parse HEAD
```

### 2. Dart SDK

```yaml
Version: 3.1.4
Path: /Users/mac/development/flutter/bin/cache/dart-sdk
```

**Note:** Dart is bundled with Flutter, no separate installation needed.

### 3. Java JDK

```yaml
Primary JDK (REQUIRED):
  Version: 18.0.2
  Vendor: Oracle Corporation
  Type: Java SE Runtime Environment
  Path: /Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home

Other JDKs (Installed but NOT used):
  - JDK 11.0.16.1 (Microsoft Build of OpenJDK)
  - JDK 1.8.0_302 (Eclipse Temurin)
```

**Installation:**
```bash
# Download JDK 18.0.2 from Oracle:
# https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html

# After installation, set JAVA_HOME in ~/.zshrc:
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
```

**Verification:**
```bash
java -version              # Should show: java version "18.0.2"
echo $JAVA_HOME           # Should show JDK 18.0.2 path
/usr/libexec/java_home -V # List all JDKs
```

### 4. Android SDK

```yaml
SDK Version: 34
SDK Path: /Users/mac/Library/Android/sdk
Build Tools: 34.0.0

Platforms Installed:
  - android-22 (API 22)
  - android-29 (API 29)
  - android-30 (API 30)
  - android-31 (API 31)
  - android-32 (API 32)
  - android-33 (API 33)
  - android-34 (API 34) ← PRIMARY
  - android-35 (API 35)

Build Tools Installed:
  - 29.0.2, 29.0.3
  - 30.0.2, 30.0.3
  - 33.0.1
  - 34.0.0 ← PRIMARY

Command-line Tools:
  - Versions 1.0 through latest
  - Path: $ANDROID_HOME/cmdline-tools/
```

**Installation:**
```bash
# Install Android Studio 2023.2 (Hedgehog)
# Through Android Studio SDK Manager:
# - Install Android SDK 34
# - Install Build Tools 34.0.0
# - Install Android SDK Command-line Tools

# Set ANDROID_HOME in ~/.zshrc:
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
```

**Verification:**
```bash
echo $ANDROID_HOME
ls $ANDROID_HOME/build-tools/34.0.0
ls $ANDROID_HOME/platforms/android-34
```

### 5. Gradle & Build System

```yaml
Gradle Version: 7.5
Method: Wrapper (gradle-wrapper.properties)
Distribution URL: https://services.gradle.org/distributions/gradle-7.5-all.zip

Android Gradle Plugin: 7.3.0
Kotlin Version: 1.7.10
Kotlin Plugin: org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10
```

**Configuration Files:**

`android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

`android/build.gradle`:
```gradle
buildscript {
    ext.kotlin_version = '1.7.10'
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

**⚠️ Important:** DO NOT install Gradle system-wide. Use wrapper: `./gradlew`

**Verification:**
```bash
cd android && ./gradlew --version
```

### 6. Xcode (macOS only)

```yaml
Version: 14.1
Build: 14B47b
Path: /Applications/Xcode.app/Contents/Developer
```

**Installation:**
```bash
# Download Xcode 14.1 from Apple Developer
# https://developer.apple.com/download/all/

# After installation:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcode-select --install  # Install Command Line Tools
```

**Verification:**
```bash
xcodebuild -version
```

### 7. CocoaPods (macOS only)

```yaml
Version: 1.15.2
Ruby: 2.6.10p210 (system Ruby)
Gem: 3.2.16
```

**Installation:**
```bash
sudo gem install cocoapods -v 1.15.2
pod setup
```

**Verification:**
```bash
pod --version
ruby --version
gem --version
```

### 8. Node.js (Optional)

```yaml
Version: 20.19.4
npm Version: 10.8.2
Manager: nvm (Node Version Manager)
Path: ~/.nvm/versions/node/v20.19.4
```

**Installation:**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Node.js
nvm install 20.19.4
nvm use 20.19.4
nvm alias default 20.19.4
```

---

## Environment Variables

### Complete ~/.zshrc Configuration

```bash
# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"

# Flutter
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"

# Python
export PATH="$PATH:$HOME/Library/Python/3.9/bin"

# Other
export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:/usr/bin"

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

### Apply Changes

```bash
source ~/.zshrc
```

---

## Project Configuration

### Android Configuration

**File:** `android/local.properties`
```properties
sdk.dir=/Users/mac/Library/Android/sdk
flutter.sdk=/Users/mac/development/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

**File:** `android/app/build.gradle`
```gradle
android {
    namespace "com.example.flutter_core_project"
    compileSdkVersion 34
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
    
    defaultConfig {
        applicationId "com.example.flutter_core_project"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode 1
        versionName "1.0.0"
    }
    
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Flutter Core (DEV)"
        }
        prod {
            dimension "environment"
            resValue "string", "app_name", "Flutter Core"
        }
    }
}
```

### iOS Configuration (macOS only)

**File:** `ios/Podfile`
```ruby
# Uncomment this line to define a global platform for your project
# platform :ios, '11.0'
```

**Note:** iOS minimum deployment target is 11.0

### Flutter Dependencies

**File:** `pubspec.yaml`
```yaml
environment:
  sdk: '>=3.1.4 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  bloc: ^8.1.1
  flutter_bloc: latest
  hydrated_bloc: latest
  equatable: ^2.0.5
  
  # Networking
  http: ^0.13.5
  dio: latest
  retrofit: latest
  pretty_dio_logger: latest
  connectivity_plus: ^5.0.0
  
  # Storage & Database
  shared_preferences: ^2.0.6
  path_provider: latest
  floor: latest
  
  # Utilities
  get_it: latest
  intl: latest
  json_annotation: latest
  flutter_dotenv: latest
  
  # UI
  cupertino_icons: ^1.0.2
  flutter_svg: ^0.22.0
  cached_network_image: latest
  flutter_hooks: latest
  
  repository: latest

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  build_runner: latest
  json_serializable: latest
  retrofit_generator: latest
```

---

## Installation Steps

### Step-by-Step Guide

#### 1. System Prerequisites (macOS)

```bash
# Install Xcode 14.1
# Download from https://developer.apple.com/download/all/

# Install Command Line Tools
xcode-select --install
sudo xcodebuild -license accept
```

#### 2. Install Java JDK 18.0.2

```bash
# Download from Oracle:
# https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html

# After installation, configure:
echo 'export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
java -version
```

#### 3. Install Android Studio & SDK

```bash
# Download Android Studio 2023.2 (Hedgehog)
# https://developer.android.com/studio/archive

# Through Android Studio:
# - SDK Manager → SDK Platforms → Android 14.0 (API 34)
# - SDK Manager → SDK Tools → Android SDK Build-Tools 34.0.0

# Configure environment:
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_HOME/emulator"' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_HOME/platform-tools"' >> ~/.zshrc
source ~/.zshrc

# Install Flutter & Dart plugins in Android Studio
```

#### 4. Install Flutter SDK

```bash
# Clone Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter

# Checkout exact version
cd ~/development/flutter
git checkout 6c4930c4ac

# Add to PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# Run Flutter doctor
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses
```

#### 5. Install CocoaPods (macOS)

```bash
sudo gem install cocoapods -v 1.15.2
pod setup
```

#### 6. Install Node.js (Optional)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.zshrc

# Install Node.js
nvm install 20.19.4
nvm use 20.19.4
nvm alias default 20.19.4
```

#### 7. Clone & Setup Project

```bash
# Clone repository
git clone https://github.com/ngonhatcuonguit/flutter_core.git
cd flutter_core

# Checkout branch
git checkout clean_architecture

# Get dependencies
flutter pub get

# Verify
flutter doctor -v
```

---

## Verification

### Automated Verification Script

**File:** `verify-environment.sh` (in project root)

```bash
# Run verification
bash verify-environment.sh
```

**Expected Output:**
```
✓ Flutter: 3.13.8 (OK)
✓ Dart: 3.1.4 (OK)
✓ Java: 18.0.2 (OK)
✓ ANDROID_HOME: /Users/mac/Library/Android/sdk
✓ Build Tools 34.0.0: Installed
✓ Android Platform 34: Installed
✓ Xcode: 14.1 (OK)
✓ CocoaPods: 1.15.2 (OK)
✓ Perfect! Your environment matches the working setup!
```

### Manual Verification

```bash
# Check all versions
flutter --version
dart --version
java -version
echo $JAVA_HOME
echo $ANDROID_HOME
xcodebuild -version  # macOS only
pod --version        # macOS only
node --version       # optional
cd android && ./gradlew --version

# Run Flutter doctor
flutter doctor -v
```

### Test Build

```bash
# Clean
flutter clean
flutter pub get

# Run on device (dev flavor)
flutter run --flavor dev -t lib/main_dev.dart

# Build APK (dev)
flutter build apk --flavor dev -t lib/main_dev.dart

# Build iOS (macOS only)
flutter build ios --flavor dev -t lib/main_dev.dart
```

---

## Troubleshooting

### Common Issues & Solutions

#### Issue 1: Flutter command not found

```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/development/flutter/bin"
source ~/.zshrc
```

#### Issue 2: Android licenses not accepted

```bash
flutter doctor --android-licenses
# Press 'y' for all prompts
```

#### Issue 3: Java version mismatch

```bash
# Check active JDK
java -version
echo $JAVA_HOME

# If wrong version, set correct JAVA_HOME
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
```

#### Issue 4: Gradle build fails

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run --flavor dev
```

#### Issue 5: iOS build fails (CocoaPods)

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run --flavor dev
```

#### Issue 6: Wrong Gradle version

```bash
# DO NOT install Gradle system-wide
# Use wrapper in project:
cd android
./gradlew --version  # Should show Gradle 7.5
```

---

## Key Compatibility Notes

### Critical Version Combinations

- Flutter 3.13.8 **requires** Dart 3.1.4 (bundled)
- Gradle 7.5 **requires** JDK 18.0.2
- Android Gradle Plugin 7.3.0 **requires** Gradle 7.5
- Kotlin 1.7.10 **compatible with** AGP 7.3.0
- Android SDK 34 **requires** Build Tools 34.0.0
- Xcode 14.1 **supports** iOS 11.0+

### Do NOT Update These

- ❌ Flutter to 3.14.x or newer
- ❌ Dart (bundled with Flutter)
- ❌ Gradle (use wrapper only)
- ❌ Android Gradle Plugin
- ❌ Kotlin version
- ❌ JDK to version 17 or 19

### Safe to Update

- ✅ Android Studio (IDE only)
- ✅ VS Code
- ✅ Chrome browser
- ✅ Node.js (if not breaking)

---

## Additional Resources

### Documentation Files

- `ENVIRONMENT_CONFIG.md` - Full configuration guide
- `QUICK_SETUP_GUIDE.md` - Quick installation steps
- `COMPLETE_ENVIRONMENT_NOTES.md` - Detailed inspection results
- `ENVIRONMENT_EXPORT_SUMMARY.md` - Summary overview
- `verify-environment.sh` - Automated verification script

### Project Files

- `pubspec.yaml` - Flutter dependencies
- `android/build.gradle` - Android build configuration
- `android/app/build.gradle` - App-level build configuration
- `android/gradle/wrapper/gradle-wrapper.properties` - Gradle wrapper config
- `ios/Podfile` - iOS dependencies

### Useful Commands

```bash
# Flutter commands
flutter doctor -v
flutter clean
flutter pub get
flutter pub upgrade --dry-run
flutter devices
flutter run --flavor dev -t lib/main_dev.dart
flutter build apk --flavor prod -t lib/main_prod.dart

# Gradle commands
cd android && ./gradlew tasks
cd android && ./gradlew clean
cd android && ./gradlew --version

# Git commands
git status
git checkout clean_architecture
git log --oneline -n 10

# System info
sw_vers                    # macOS version
uname -a                   # System info
sysctl hw.memsize         # RAM size
sysctl -n machdep.cpu.brand_string  # CPU info
```

---

## Checklist for New Setup

- [ ] macOS 12.7+ installed (Intel or Apple Silicon)
- [ ] Xcode 14.1 installed and configured
- [ ] JDK 18.0.2 installed and JAVA_HOME set
- [ ] Android Studio 2023.2 installed
- [ ] Android SDK 34 with Build Tools 34.0.0 installed
- [ ] ANDROID_HOME environment variable set
- [ ] Flutter 3.13.8 (commit 6c4930c4ac) installed
- [ ] Flutter added to PATH
- [ ] CocoaPods 1.15.2 installed (macOS)
- [ ] Android licenses accepted
- [ ] `flutter doctor -v` shows no errors
- [ ] `verify-environment.sh` passes all checks
- [ ] Project builds successfully: `flutter run --flavor dev`

---

**Last Verified:** 10 December 2025  
**Status:** ✅ WORKING  
**Build Status:** No errors on macOS 12.7.6 Intel  
**Branch:** clean_architecture

For questions or issues, refer to other documentation files or run `verify-environment.sh`.

🚀 Happy Coding!
