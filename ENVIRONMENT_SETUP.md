# Flutter Core Project - Environment Setup Guide

## 🚀 Environment Configuration

This project supports multiple environments: **Development** and **Production**.

### 📁 Environment Files

- `.env.dev` - Development environment configuration
- `.env.prod` - Production environment configuration
- `.env.example` - Example template for environment variables

### 🔧 Environment Variables

```env
API_BASE_URL=https://newsapi.org/v2
API_KEY=your_api_key_here
ENVIRONMENT=development
```

### 📱 Running the App

#### Using VSCode (Recommended)

1. Open VSCode
2. Press `F5` or go to Run and Debug panel
3. Select one of the configurations:
   - **Flutter Dev** - Run in development mode
   - **Flutter Prod** - Run in production mode
   - **Flutter Dev (Profile)** - Profile mode for development
   - **Flutter Prod (Release)** - Release mode for production

#### Using Terminal

**Development:**
```bash
flutter run -t lib/main_dev.dart
```

**Production:**
```bash
flutter run -t lib/main_prod.dart
```

**Release Build:**
```bash
flutter build apk -t lib/main_prod.dart --release
```

### 🏗️ Build Configuration

#### Java Version
- **Java 21 (LTS)** - Latest long-term support version
- **Kotlin 1.9.22** - Modern Kotlin version
- **Android Gradle Plugin 8.3.0** - Latest stable AGP
- **Gradle 8.5** - Gradle wrapper version

#### Android Configuration
- **compileSdk**: 34
- **minSdk**: As specified in Flutter configuration
- **targetSdk**: As specified in Flutter configuration

### 🛠️ Development Commands

**Install dependencies:**
```bash
flutter pub get
```

**Generate code (Retrofit, JSON Serializable, Floor):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Run tests:**
```bash
flutter test
```

### 📦 Key Dependencies

- **State Management**: `flutter_bloc`, `hydrated_bloc`
- **Networking**: `dio`, `retrofit`
- **Database**: `floor`
- **Dependency Injection**: `get_it`
- **Environment Configuration**: `flutter_dotenv`
- **UI**: `flutter_svg`, `cached_network_image`

### 🔐 Security Notes

⚠️ **Important**: Never commit `.env.dev` or `.env.prod` files to version control!

These files are already in `.gitignore`. Always use `.env.example` as a template.

### 🐛 Troubleshooting

**Issue: Environment variables not loading**
```bash
# Make sure you've created the .env files
cp .env.example .env.dev
cp .env.example .env.prod
# Edit these files with your actual API keys
```

**Issue: Build errors after Java upgrade**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Issue: Generated files missing**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 📖 Project Structure

```
lib/
├── main.dart              # Default entry (exports main_dev.dart)
├── main_dev.dart          # Development entry point
├── main_prod.dart         # Production entry point
├── main_common.dart       # Shared app configuration
├── injection_container.dart  # Dependency injection setup
├── services/
│   └── env_manager.dart   # Environment configuration manager
├── core/
├── data/
├── domain/
└── presentation/
```

### 🎯 Next Steps

1. Copy `.env.example` to `.env.dev` and `.env.prod`
2. Add your API keys to both environment files
3. Run `flutter pub get`
4. Select "Flutter Dev" from VSCode Run and Debug
5. Press F5 to start developing! 🎉

---

**Happy Coding! 💙**
