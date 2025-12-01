# 🌍 Hướng dẫn sử dụng các tính năng

## Tính năng đã tích hợp

### 1. 🌓 Dark Mode / Light Mode

**Cách hoạt động:**
- App hỗ trợ 2 chế độ: Sáng (Light) và Tối (Dark)
- Theme được lưu tự động và giữ nguyên khi mở lại app
- Sử dụng `HydratedBloc` để persist state

**Cách sử dụng:**

#### Trong màn hình Choose Mode:
```dart
// Chuyển sang Dark Mode
context.read<ThemeCubit>().updateTheme(ThemeMode.dark);

// Chuyển sang Light Mode
context.read<ThemeCubit>().updateTheme(ThemeMode.light);

// Toggle giữa Dark và Light
context.read<ThemeCubit>().toggleTheme();
```

#### Thêm Settings Widget vào bất kỳ màn hình nào:
```dart
import 'package:flutter_core_project/common/widgets/settings/settings_widget.dart';

// Trong build method
SettingsWidget(
  showTheme: true,
  showLanguage: true,
)
```

### 2. 🌐 Đa ngôn ngữ (Internationalization)

**Ngôn ngữ hỗ trợ:**
- 🇬🇧 English (en)
- 🇻🇳 Tiếng Việt (vi)

**Cách hoạt động:**
- Ngôn ngữ được lưu tự động và giữ nguyên khi mở lại app
- Sử dụng `HydratedBloc` để persist state
- File ngôn ngữ ở: `lib/l10n/en.json` và `lib/l10n/vi.json`

**Cách sử dụng:**

#### Chuyển đổi ngôn ngữ:
```dart
// Chuyển sang tiếng Việt
context.read<LocaleCubit>().changeLocale('vi');

// Chuyển sang tiếng Anh
context.read<LocaleCubit>().changeLocale('en');

// Toggle giữa en và vi
context.read<LocaleCubit>().toggleLanguage();
```

#### Sử dụng text đã dịch trong UI:
```dart
final localizations = AppLocalizations.of(context);

Text(localizations?.translate('welcome') ?? 'Welcome')
```

#### Thêm key mới vào file ngôn ngữ:

**en.json:**
```json
{
  "your_new_key": "Your English Text"
}
```

**vi.json:**
```json
{
  "your_new_key": "Văn bản tiếng Việt của bạn"
}
```

### 3. 🎯 Onboarding / Intro chỉ hiển thị 1 lần

**Cách hoạt động:**
- Lần đầu mở app: Hiển thị màn hình intro (GetStartedPage)
- Từ lần thứ 2 trở đi: Bỏ qua intro, vào thẳng màn hình chính
- Sử dụng `SharedPreferences` để lưu flag `has_seen_intro`

**Cách sử dụng:**

#### Check trạng thái intro:
```dart
import 'package:flutter_core_project/services/onboarding_service.dart';

// Check xem user đã xem intro chưa
bool hasSeenIntro = await OnboardingService.hasSeenIntro();

if (hasSeenIntro) {
  // Navigate to main screen
} else {
  // Show intro
}
```

#### Đánh dấu đã xem intro:
```dart
await OnboardingService.setIntroSeen();
```

#### Reset intro (để test):
```dart
await OnboardingService.resetIntro();
```

## 📂 Cấu trúc File

```
lib/
├── l10n/
│   ├── en.json              # Ngôn ngữ tiếng Anh
│   └── vi.json              # Ngôn ngữ tiếng Việt
├── services/
│   ├── localization_service.dart    # Service xử lý đa ngôn ngữ
│   └── onboarding_service.dart      # Service xử lý intro flag
├── presentation/
│   └── choose_mode/
│       └── bloc/
│           ├── theme_cubit.dart     # Quản lý theme state
│           └── locale_cubit.dart    # Quản lý locale state
└── common/
    └── widgets/
        └── settings/
            └── settings_widget.dart  # Widget settings tái sử dụng
```

## 🎨 Tùy chỉnh Theme

### Màu sắc:
File: `lib/core/configs/theme/app_colors.dart`

### Theme configuration:
File: `lib/core/configs/theme/app_theme.dart`

```dart
// Light Theme
AppTheme.lightTheme

// Dark Theme
AppTheme.darkTheme
```

## 🧪 Testing

### Test Theme Toggle:
1. Mở app
2. Vào màn hình Choose Mode
3. Nhấn vào biểu tượng mặt trăng (Dark) hoặc mặt trời (Light)
4. Đóng app và mở lại → Theme vẫn giữ nguyên

### Test Language Switch:
1. Mở app
2. Vào màn hình Choose Mode
3. Nhấn vào EN hoặc VI
4. Quan sát text trên màn hình thay đổi
5. Đóng app và mở lại → Ngôn ngữ vẫn giữ nguyên

### Test Onboarding:
1. Xóa app hoàn toàn khỏi thiết bị
2. Cài đặt lại
3. Mở app lần đầu → Hiển thị intro
4. Nhấn "Get Started" / "Bắt đầu"
5. Đóng app
6. Mở lại → Không hiển thị intro nữa

### Reset Onboarding (cho dev):
```dart
// Thêm vào màn hình settings hoặc debug menu
ElevatedButton(
  onPressed: () async {
    await OnboardingService.resetIntro();
    // Restart app hoặc navigate về splash
  },
  child: Text('Reset Intro'),
)
```

## 📝 Lưu ý quan trọng

1. **Theme State**: Được persist bằng `HydratedBloc`, cần khởi tạo storage trong `main.dart`
2. **Locale State**: Được persist bằng `HydratedBloc`, cần khởi tạo storage trong `main.dart`
3. **Onboarding Flag**: Được persist bằng `SharedPreferences`, không cần setup thêm
4. **Localization Files**: Cần thêm vào `pubspec.yaml` assets: `- lib/l10n/`
5. **flutter_localizations**: Phải thêm vào dependencies trong `pubspec.yaml`

## 🚀 Khởi chạy

### Development Mode:
```bash
flutter run -t lib/main_dev.dart
```

### Production Mode:
```bash
flutter run -t lib/main_prod.dart
```

### Sử dụng VS Code:
- Mở Run and Debug (F5)
- Chọn "Flutter Dev" hoặc "Flutter Prod"
- Nhấn Play

---

**Hoàn thành!** 🎉 App hiện đã có đầy đủ 3 tính năng: Dark/Light Mode, Đa ngôn ngữ, và Onboarding chỉ hiển thị 1 lần.
