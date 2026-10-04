# Fix lỗi iOS Pods Manifest.lock không đồng bộ

## Triệu chứng

Khi build/archive iOS trên Xcode gặp lỗi tương tự:

```text
diff: ios/Pods/Manifest.lock: No such file or directory
error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.
```

Nguyên nhân thường gặp là thư mục `ios/Pods` đã bị xóa, chưa được tạo lại, hoặc `ios/Pods/Manifest.lock` không còn khớp với `ios/Podfile.lock`. Trong project này, `ios/Pods` bị ignore bởi git nên sau khi clean máy, đổi branch, đổi Flutter package, hoặc xóa DerivedData/cache, Xcode có thể không còn đủ file Pods để build.

## Fix nhanh

Chạy từ thư mục gốc project:

```bash
cd /Volumes/MyData/project/flutter_core/flutter_core
flutter pub get
cd ios
pod install
```

Sau đó mở đúng workspace để build:

```bash
open Runner.xcworkspace
```

Không build bằng `ios/Runner.xcodeproj` khi project có CocoaPods.

## Kiểm tra sau khi fix

Từ thư mục gốc project, chạy:

```bash
diff -q ios/Podfile.lock ios/Pods/Manifest.lock
```

Nếu lệnh không in gì ra là hai file đang khớp.

Có thể kiểm tra file đã tồn tại:

```bash
ls -l ios/Pods/Manifest.lock
```

## Nếu vẫn lỗi trong Xcode

1. Đóng Xcode.
2. Chạy lại:

```bash
cd /Volumes/MyData/project/flutter_core/flutter_core
flutter clean
flutter pub get
cd ios
pod install
```

3. Xóa cache build của Xcode nếu vẫn còn báo lỗi cũ:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
```

4. Mở lại:

```bash
open /Volumes/MyData/project/flutter_core/flutter_core/ios/Runner.xcworkspace
```

## Khi nào cần chạy lại `pod install`

Chạy lại `pod install` sau các trường hợp này:

- Thay đổi package trong `pubspec.yaml`.
- Chạy `flutter clean`.
- Đổi branch có thay đổi `ios/Podfile.lock`, `ios/Podfile`, hoặc plugin Flutter.
- Xóa thư mục `ios/Pods`.
- Xcode báo `Manifest.lock` missing hoặc sandbox không đồng bộ.

## Ghi chú commit

- Nên commit `ios/Podfile.lock` nếu có thay đổi hợp lệ.
- Không cần commit `ios/Pods` vì thư mục này đang được ignore và có thể tạo lại bằng `pod install`.
