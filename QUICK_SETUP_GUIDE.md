# 🚀 Quick Setup Guide - Cài đặt nhanh cho máy mới

**Thời gian dự kiến:** 2-3 giờ (tùy tốc độ internet)

---

## 📝 Chuẩn bị

1. **Máy tính:** macOS 12.x trở lên (Intel hoặc Apple Silicon)
2. **Dung lượng:** ~20GB trống cho các công cụ
3. **Internet:** Kết nối ổn định để download
4. **Apple ID:** Để download Xcode (free)

---

## ⚡ Các bước cài đặt nhanh

### BƯỚC 1: Cài Xcode và Command Line Tools (macOS only)
⏱️ ~45-60 phút

```bash
# 1. Download Xcode 14.1 từ:
# https://developer.apple.com/download/all/
# (Đăng nhập bằng Apple ID)

# 2. Cài đặt Xcode.app vào /Applications/

# 3. Mở Terminal và chạy:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch

# 4. Cài Command Line Tools:
xcode-select --install

# 5. Verify:
xcodebuild -version
# Should show: Xcode 14.1, Build version 14B47b
```

---

### BƯỚC 2: Cài Java JDK 18.0.2
⏱️ ~10 phút

```bash
# 1. Download JDK 18.0.2 từ:
# https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html
# Chọn: macOS x64 DMG Installer (hoặc ARM64 nếu Apple Silicon)

# 2. Cài đặt file .dmg

# 3. Set JAVA_HOME:
echo 'export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 4. Verify:
java -version
# Should show: java version "18.0.2"
```

---

### BƯỚC 3: Cài Android Studio
⏱️ ~30 phút

```bash
# 1. Download Android Studio 2023.2 (Hedgehog) từ:
# https://developer.android.com/studio/archive

# 2. Cài đặt Android Studio.app vào /Applications/

# 3. Mở Android Studio lần đầu:
#    - Chọn "Standard" installation
#    - Chọn theme (tùy thích)
#    - Chờ download Android SDK

# 4. Install SDK components:
#    Tools → SDK Manager → SDK Platforms
#    ✓ Android 14.0 (API 34) - CHECK
#    ✓ Android 13.0 (API 33)
#    
#    SDK Tools tab:
#    ✓ Android SDK Build-Tools 34.0.0 - CHECK
#    ✓ Android SDK Platform-Tools
#    ✓ Android SDK Tools

# 5. Set ANDROID_HOME:
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_HOME/emulator"' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_HOME/platform-tools"' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_HOME/tools"' >> ~/.zshrc
source ~/.zshrc

# 6. Install Flutter & Dart plugins:
#    Android Studio → Settings → Plugins → Marketplace
#    Search "Flutter" → Install
#    Search "Dart" → Install
#    Restart Android Studio

# 7. Verify:
echo $ANDROID_HOME
ls $ANDROID_HOME/build-tools/34.0.0
```

---

### BƯỚC 4: Cài Flutter SDK
⏱️ ~15 phút

```bash
# 1. Clone Flutter SDK:
git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter

# 2. Checkout version 3.13.8:
cd ~/development/flutter
git checkout 6c4930c4ac

# 3. Add to PATH:
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# 4. Run Flutter doctor:
flutter doctor

# 5. Accept Android licenses:
flutter doctor --android-licenses
# Press 'y' for all prompts

# 6. Verify:
flutter --version
# Should show: Flutter 3.13.8 • channel stable
```

---

### BƯỚC 5: Cài CocoaPods (macOS - iOS development)
⏱️ ~5 phút

```bash
# 1. Install CocoaPods:
sudo gem install cocoapods -v 1.15.2

# 2. Setup CocoaPods:
pod setup

# 3. Verify:
pod --version
# Should show: 1.15.2
```

---

### BƯỚC 6: Cài Node.js (Optional - web development)
⏱️ ~10 phút

```bash
# 1. Install nvm (Node Version Manager):
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 2. Reload terminal:
source ~/.zshrc

# 3. Install Node.js 20.19.4:
nvm install 20.19.4
nvm use 20.19.4
nvm alias default 20.19.4

# 4. Verify:
node --version  # v20.19.4
npm --version   # 10.8.2
```

---

### BƯỚC 7: Cài VS Code
⏱️ ~5 phút

```bash
# 1. Download VS Code từ:
# https://code.visualstudio.com/

# 2. Cài đặt VS Code.app vào /Applications/

# 3. Mở VS Code:
#    Extensions (Cmd+Shift+X) → Search:
#    - "Flutter" → Install
#    - "Dart" → Install

# 4. Restart VS Code
```

---

### BƯỚC 8: Clone và Setup Project
⏱️ ~10 phút

```bash
# 1. Clone project:
git clone https://github.com/ngonhatcuonguit/flutter_core.git
cd flutter_core

# 2. Checkout branch:
git checkout clean_architecture

# 3. Get dependencies:
flutter pub get

# 4. Verify setup:
bash verify-environment.sh
```

---

### BƯỚC 9: Build và chạy thử
⏱️ ~5 phút

```bash
# 1. List available devices:
flutter devices

# 2. Run on device (dev flavor):
flutter run --flavor dev -t lib/main_dev.dart

# Hoặc run từ VS Code:
# - Mở project trong VS Code
# - Press F5 hoặc Run → Start Debugging
```

---

## ✅ Checklist hoàn thành

Sau khi cài xong, verify bằng cách chạy:

```bash
cd /path/to/flutter_core_project
bash verify-environment.sh
```

Nếu mọi thứ OK, bạn sẽ thấy:
```
✓ Perfect! Your environment matches the working setup!
```

---

## 🐛 Các lỗi thường gặp

### Lỗi 1: "Flutter command not found"
```bash
# Kiểm tra PATH:
echo $PATH | grep flutter

# Nếu không thấy, add lại:
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Lỗi 2: "Android licenses not accepted"
```bash
flutter doctor --android-licenses
# Press 'y' cho tất cả
```

### Lỗi 3: "java: command not found"
```bash
# Kiểm tra JAVA_HOME:
echo $JAVA_HOME

# Nếu empty, set lại:
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.0.2.jdk/Contents/Home
```

### Lỗi 4: iOS build fails (CocoaPods)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run --flavor dev
```

### Lỗi 5: Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run --flavor dev
```

---

## 📞 Cần trợ giúp?

1. **Check Flutter doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Xem chi tiết lỗi:**
   ```bash
   flutter run --flavor dev -v
   ```

3. **So sánh environment:**
   - Xem file `ENVIRONMENT_CONFIG.md` để biết chi tiết versions
   - Run `verify-environment.sh` để tự động check

---

## 🎯 Next Steps

Sau khi setup xong:

1. **Đọc documentation:**
   - `README.md` - Project overview
   - `DOCUMENTATION_INDEX.md` - Tất cả docs

2. **Test build:**
   ```bash
   flutter run --flavor dev -t lib/main_dev.dart
   ```

3. **Test APK build:**
   ```bash
   flutter build apk --flavor dev -t lib/main_dev.dart
   ```

4. **Start development! 🚀**

---

**Total setup time:** ~2-3 giờ  
**Prerequisite:** macOS 12.7+ với Apple ID  
**Result:** Môi trường phát triển giống hệt máy working!

*Chúc bạn setup thành công! 🎉*
