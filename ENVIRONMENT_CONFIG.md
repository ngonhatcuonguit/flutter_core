# 🔧 Environment Configuration - Working Setup

**Máy innit dự án:** macOS 12.7.6 (Monterey) - x86_64  
**Ngày xuất:** 10 December 2025  
**Dự án:** Flutter Core Project  
**Trạng thái:** ✅ STABLE - Chạy và build không lỗi

---

## 📋 TÓM TẮT NHANH

Đây là cấu hình môi trường đang chạy ổn định trên máy văn phòng. Bạn cần cài đặt **CHÍNH XÁC** các version này để tránh lỗi.

**Các công cụ quan trọng nhất:**
- Flutter: **3.13.8** (stable channel)
- Dart: **3.1.4**
- Java: **JDK 18.0.2** (Oracle)
- Xcode: **14.1**
- Android Studio: **2023.2**
- CocoaPods: **1.15.2**

---

## 🖥️ SYSTEM INFORMATION

### Operating System
```
OS Name: macOS Monterey
Version: 12.7.6
Build: 21H1320
Architecture: x86_64 (Intel)
Kernel: Darwin 21.6.0
```

### Shell
```bash
Default Shell: zsh
Terminal: VS Code integrated terminal
```

---

## 🔵 FLUTTER & DART

### Flutter SDK
```
Version: 3.13.8
Channel: stable
Installation Path: /Users/mac/development/flutter
Framework Revision: 6c4930c4ac (18 Oct 2023)
Engine Revision: 767d8c75e8
DevTools: 2.25.0
Upstream: https://github.com/flutter/flutter.git
```

**Cài đặt Flutter 3.13.8:**
```bash
# Clone Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter

# Checkout exact version
cd ~/development/flutter
git checkout 6c4930c4ac

# Add to PATH (thêm vào ~/.zshrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify
flutter --version
```

### Dart SDK
```
Version: 3.1.4
Included with Flutter SDK
```

### Environment Variables for Flutter
```bash
# Add to ~/.zshrc
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
```

---

## ☕ JAVA & JDK

### Java Development Kit
```
Version: JDK 18.0.2
Build: 18.0.2+9-61
Vendor: Oracle (Java HotSpot VM)
Installation Path: /Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
Type: Java(TM) SE Runtime Environment
```

**Download Link:**
https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html

**Cài đặt:**
1. Download JDK 18.0.2 từ Oracle
2. Cài đặt file .dmg
3. Set JAVA_HOME:

```bash
# Add to ~/.zshrc
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Verify
java -version
```

**⚠️ LƯU Ý:** Android Studio sử dụng JDK 17.0.9 riêng, nhưng project build bằng JDK 18.0.2

---

## 🤖 ANDROID DEVELOPMENT

### Android SDK
```
Version: 34.0.0
Location: /Users/mac/Library/Android/sdk
Platform: android-35
Build Tools: 34.0.0
```

**Android Platforms Installed:**
- android-22
- android-29
- android-30
- android-31
- android-32
- android-33
- android-34 ✅ (Primary)
- android-35

**Build Tools Versions:**
- 29.0.2
- 29.0.3
- 30.0.2
- 30.0.3
- 33.0.1
- 34.0.0 ✅ (Primary)

### Android Studio
```
Version: 2023.2 (Hedgehog)
Location: /Applications/Android Studio.app/Contents
Bundled JDK: OpenJDK 17.0.9
Plugins Required:
  - Flutter plugin
  - Dart plugin
```

**Download:**
https://developer.android.com/studio/archive

### Environment Variables for Android
```bash
# Add to ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
```

### Gradle
```
Version: 7.5
Kotlin: 1.6.21
Groovy: 3.0.10
JVM: 18.0.2
Build Time: 14 Jul 2022
Revision: c7db7b958189ad2b0c1472b6fe663e6d654a5103
```

**Gradle Wrapper được cấu hình trong project, không cần cài riêng**

---

## 🍎 iOS DEVELOPMENT (macOS only)

### Xcode
```
Version: 14.1
Build: 14B47b
Location: /Applications/Xcode.app/Contents/Developer
Command Line Tools: Installed
```

**Download Xcode 14.1:**
https://developer.apple.com/download/all/
(Cần Apple Developer account)

**Cài đặt Command Line Tools:**
```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### CocoaPods
```
Version: 1.15.2
Ruby Version: 2.6.10p210
```

**Cài đặt CocoaPods:**
```bash
sudo gem install cocoapods -v 1.15.2

# Verify
pod --version
```

---

## 🌐 WEB DEVELOPMENT

### Node.js & npm
```
Node.js: v20.19.4
npm: 10.8.2
Installation: nvm (Node Version Manager)
Location: /Users/mac/.nvm/versions/node/v20.19.4
```

**Cài đặt với nvm:**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Node.js 20.19.4
nvm install 20.19.4
nvm use 20.19.4
nvm alias default 20.19.4

# Verify
node --version
npm --version
```

### Chrome
```
Version: 143.0.7499.41
Location: /Applications/Google Chrome.app
```

---

## 🛠️ OTHER DEVELOPMENT TOOLS

### Git
```
Version: 2.37.1 (Apple Git-137.1)
```

**Cài đặt:**
```bash
# Thường đã có sẵn trên macOS
git --version

# Nếu chưa có, cài Xcode Command Line Tools
xcode-select --install
```

### VS Code
```
Version: 1.105.1
Location: /Users/mac/Downloads/Visual Studio Code.app
Flutter Extension: 3.124.0
```

**Extensions cần cài:**
- Flutter (version 3.124.0)
- Dart
- Flutter Widget Snippets (optional)

---

## 📦 PROJECT DEPENDENCIES

### pubspec.yaml - Environment
```yaml
environment:
  sdk: '>=3.1.4 <4.0.0'
```

### Main Dependencies (với versions đang dùng)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  bloc: ^8.1.1                    # Actual: 8.1.4
  flutter_bloc: latest            # Actual: 8.1.6
  hydrated_bloc: latest           # Actual: 9.1.5
  
  # Networking
  http: ^0.13.5                   # Actual: 0.13.6
  dio: latest                     # Actual: 5.8.0+1
  retrofit: latest                # Actual: 4.4.2
  pretty_dio_logger: latest       # Actual: 1.4.0
  connectivity_plus: ^5.0.0       # Actual: 5.0.2
  
  # Data & Storage
  shared_preferences: ^2.0.6      # Actual: 2.2.3
  path_provider: latest           # Actual: 2.0.15
  floor: latest                   # Actual: 1.4.2
  
  # Utilities
  equatable: ^2.0.5               # Actual: 2.0.7
  get_it: latest                  # Actual: 8.0.3
  intl: latest                    # Actual: 0.18.1
  json_annotation: latest         # Actual: 4.9.0
  
  # UI & Assets
  cupertino_icons: ^1.0.2         # Actual: 1.0.8
  flutter_svg: ^0.22.0            # Actual: 0.22.0
  cached_network_image: latest    # Actual: 3.3.1
  flutter_hooks: latest           # Actual: 0.20.5
  
  # Configuration
  flutter_dotenv: latest          # Actual: 5.2.1
  
  # Repository
  repository: latest              # Actual: 3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0           # Actual: 2.0.3
  build_runner: latest            # Actual: 2.4.9
  json_serializable: latest       # Actual: 6.8.0
  retrofit_generator: latest      # Actual: 8.2.1
```

### Cài đặt dependencies:
```bash
cd /path/to/flutter_core_project
flutter pub get
```

---

## 🔨 ANDROID PROJECT CONFIGURATION

### Root build.gradle
```gradle
buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

### App build.gradle
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
        versionName "1.0"
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

---

## 🚀 BUILD & RUN COMMANDS

### Kiểm tra môi trường
```bash
flutter doctor -v
```

### Clean & Get Dependencies
```bash
flutter clean
flutter pub get
```

### Build & Run (Development)
```bash
# Run on connected device (dev flavor)
flutter run --flavor dev -t lib/main_dev.dart

# Run on specific device
flutter run --flavor dev -t lib/main_dev.dart -d <device-id>

# List devices
flutter devices
```

### Build & Run (Production)
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### Build APK
```bash
# Debug APK (dev)
flutter build apk --flavor dev -t lib/main_dev.dart

# Release APK (prod)
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

### Build iOS (macOS only)
```bash
# Debug
flutter build ios --flavor dev -t lib/main_dev.dart

# Release
flutter build ios --release --flavor prod -t lib/main_prod.dart
```

---

## 🔧 ENVIRONMENT VARIABLES SUMMARY

### Complete ~/.zshrc Configuration
```bash
# Flutter
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

### Apply changes
```bash
source ~/.zshrc
```

---

## ✅ INSTALLATION CHECKLIST

Làm theo thứ tự này để setup môi trường tương tự:

### 1️⃣ System Requirements
- [ ] macOS 12.7.6 (Monterey) hoặc tương thích
- [ ] Architecture: x86_64 (Intel Mac) hoặc Apple Silicon với Rosetta 2

### 2️⃣ Install Xcode (macOS only)
- [ ] Download và cài Xcode 14.1
- [ ] Cài Xcode Command Line Tools: `xcode-select --install`
- [ ] Accept license: `sudo xcodebuild -license accept`
- [ ] Run first launch: `sudo xcodebuild -runFirstLaunch`

### 3️⃣ Install Java JDK
- [ ] Download JDK 18.0.2 từ Oracle
- [ ] Cài đặt JDK
- [ ] Set JAVA_HOME trong ~/.zshrc
- [ ] Verify: `java -version`

### 4️⃣ Install Android Studio
- [ ] Download Android Studio 2023.2
- [ ] Cài đặt Android Studio
- [ ] Cài Android SDK 34
- [ ] Cài Build Tools 34.0.0
- [ ] Cài Flutter và Dart plugins
- [ ] Set ANDROID_HOME trong ~/.zshrc

### 5️⃣ Install Flutter SDK
- [ ] Clone Flutter SDK stable channel
- [ ] Checkout version 3.13.8 (commit: 6c4930c4ac)
- [ ] Add Flutter to PATH
- [ ] Run: `flutter doctor`
- [ ] Accept Android licenses: `flutter doctor --android-licenses`

### 6️⃣ Install CocoaPods (macOS only)
- [ ] Install Ruby (đã có sẵn trên macOS)
- [ ] Install CocoaPods: `sudo gem install cocoapods -v 1.15.2`
- [ ] Verify: `pod --version`

### 7️⃣ Install Node.js (Optional - for web)
- [ ] Install nvm
- [ ] Install Node.js 20.19.4: `nvm install 20.19.4`
- [ ] Set default: `nvm alias default 20.19.4`

### 8️⃣ Install VS Code
- [ ] Download VS Code 1.105.1
- [ ] Cài Flutter extension (3.124.0)
- [ ] Cài Dart extension

### 9️⃣ Clone và Setup Project
```bash
# Clone project
git clone <your-repo-url> flutter_core_project
cd flutter_core_project

# Checkout branch
git checkout clean_architecture

# Get dependencies
flutter pub get

# Run flutter doctor
flutter doctor -v
```

### 🔟 Verify Setup
```bash
# Should show all checkmarks
flutter doctor -v

# Test build
flutter run --flavor dev -t lib/main_dev.dart
```

---

## 🐛 TROUBLESHOOTING

### Problem 1: Flutter command not found
```bash
# Solution: Add Flutter to PATH
export PATH="$PATH:$HOME/development/flutter/bin"
source ~/.zshrc
```

### Problem 2: Android licenses not accepted
```bash
flutter doctor --android-licenses
# Accept all licenses
```

### Problem 3: CocoaPods not found (iOS)
```bash
sudo gem install cocoapods -v 1.15.2
pod setup
```

### Problem 4: Xcode build fails
```bash
# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Problem 5: Gradle build fails
```bash
# Clean Android build
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem 6: Java version mismatch
```bash
# Ensure JDK 18.0.2 is used
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
java -version
```

---

## 📝 IMPORTANT NOTES

### ⚠️ Version Compatibility
- Flutter 3.13.8 **requires** Dart 3.1.4 (bundled)
- Android compileSdkVersion **34** requires Build Tools 34.0.0
- Kotlin 1.7.10 is compatible with Gradle 7.3.0
- JDK 18 is used for building (not JDK 17 from Android Studio)

### 💡 Tips
1. **Always use exact versions** để tránh compatibility issues
2. **Run `flutter doctor -v`** sau mỗi thay đổi môi trường
3. **Clean build** khi đổi version: `flutter clean && flutter pub get`
4. **Check PATH** nếu command không tìm thấy: `echo $PATH`
5. **Use nvm** để quản lý Node.js versions nếu cần

### 🔄 Update Strategy
- **DO NOT** update Flutter/Dart trừ khi necessary
- **Test** trên môi trường dev trước khi update production
- **Backup** project trước khi update major versions
- **Document** mọi thay đổi về versions

---

## 📞 SUPPORT

Nếu gặp vấn đề khi setup môi trường theo config này:

1. **Verify versions exactly match** bằng các commands:
```bash
flutter --version
java -version
xcodebuild -version
pod --version
node --version
```

2. **Check flutter doctor output:**
```bash
flutter doctor -v
```

3. **Check environment variables:**
```bash
echo $JAVA_HOME
echo $ANDROID_HOME
echo $PATH
```

4. **Try clean build:**
```bash
flutter clean
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart -v
```

---

## 📄 FILE LOCATIONS REFERENCE

```
Flutter SDK:           /Users/mac/development/flutter
Java JDK:              /Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk
Android SDK:           ~/Library/Android/sdk
Android Studio:        /Applications/Android Studio.app
Xcode:                 /Applications/Xcode.app
VS Code:               /Applications/Visual Studio Code.app
Node.js (nvm):         ~/.nvm/versions/node/v20.19.4

Project:               /Users/mac/Documents/flutter_core_project
Git Branch:            clean_architecture
```

---

**✅ Setup Complete Checklist:**
- [ ] All tools installed with correct versions
- [ ] Environment variables configured
- [ ] `flutter doctor -v` shows no errors
- [ ] Project builds successfully with `flutter run --flavor dev`
- [ ] Can build APK with `flutter build apk --flavor dev`
- [ ] (macOS) iOS builds successfully

**Sau khi complete checklist, máy của bạn sẽ có môi trường giống hệt máy này!**

---

*Generated: 10 December 2025*  
*Status: Verified and Working*  
*Project: Flutter Core Project*  
*Branch: clean_architecture*
