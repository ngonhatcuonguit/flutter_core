# Quy trình deploy iOS lên App Store Connect

Tài liệu này áp dụng cho project Flutter hiện tại và bao quát toàn bộ quy trình từ chuẩn bị version, CocoaPods, signing, Archive, upload đến xử lý các lỗi thường gặp. Mục tiêu là mỗi lần phát hành đều có thể kiểm tra theo cùng một checklist, tránh tạo archive sai version hoặc chỉ phát hiện lỗi ở bước Distribute.

## 1. Cấu hình chuẩn của project

| Thành phần | Giá trị hiện tại |
| --- | --- |
| Flutter SDK | FVM `3.19.0` |
| Bundle Identifier | `vn.com.thp.payroll` |
| Apple Team ID | `D4V3H8CCZ9` |
| Workspace phải mở | `ios/Runner.xcworkspace` |
| Version hiện tại | `1.0.8` |
| Build hiện tại | `17` |
| Scheme `Runner` | Archive bằng `Release` |
| Scheme `prod` | Archive bằng `Release-prod` |
| Scheme `dev` | Archive bằng `Release-dev` |

Không mở `Runner.xcodeproj` để Archive vì project đang dùng CocoaPods. Trước khi phát hành, cần xác nhận scheme tương ứng với môi trường cần deploy; bản production thông thường dùng scheme `prod`, nhưng không tự ý đổi scheme nếu quy trình hiện tại của đội đang dùng `Runner`.

## 2. Quy tắc version và build number

Flutter khai báo version theo định dạng:

```yaml
version: 1.0.8+17
```

- `1.0.8` là App Version, tương ứng `CFBundleShortVersionString`/`MARKETING_VERSION`.
- `17` là Build Number, tương ứng `CFBundleVersion`/`CURRENT_PROJECT_VERSION`.
- Khi App Store đã duyệt version `1.0.8`, lần phát hành tiếp theo phải tăng App Version, ví dụ `1.0.9`.
- Mỗi build upload trong cùng một version phải có Build Number mới. Nếu `1.0.8 (17)` đã tồn tại trên App Store Connect, dùng ít nhất `1.0.8 (18)`.
- Nếu upload thất bại và App Store Connect đã xóa build lỗi, có thể upload lại cùng Build Number. Nếu Apple báo build đã tồn tại, tăng Build Number rồi Archive lại.

Khi đổi version, cập nhật `pubspec.yaml`, sau đó đồng bộ cấu hình Flutter/iOS:

```bash
cd /Volumes/MyData/project/flutter_core/flutter_core
.fvm/flutter_sdk/bin/flutter pub get
.fvm/flutter_sdk/bin/flutter build ios \
  --release \
  --config-only \
  --no-pub \
  --no-codesign \
  --build-name=1.0.8 \
  --build-number=17
```

Thay `1.0.8` và `17` bằng version thực tế của lần phát hành. Không dùng Flutter global nếu version global khác FVM `3.19.0`.

Kiểm tra dữ liệu đã đồng bộ:

```bash
rg -n '^version:' pubspec.yaml
rg -n 'FLUTTER_BUILD_NAME|FLUTTER_BUILD_NUMBER' ios/Flutter/Generated.xcconfig
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -showBuildSettings \
  | rg 'MARKETING_VERSION|CURRENT_PROJECT_VERSION|PRODUCT_BUNDLE_IDENTIFIER'
```

Nếu Archive bằng scheme `prod`, thay `Runner`/`Release` bằng `prod`/`Release-prod` trong lệnh kiểm tra.

## 3. Điều kiện trước khi deploy

### Apple Developer Account

- Account Holder đã đồng ý Program License Agreement mới nhất tại [Apple Developer Account](https://developer.apple.com/account/).
- Xcode đã đăng nhập đúng Apple ID tại **Xcode > Settings > Accounts**.
- Target `Runner` đang chọn đúng Team `D4V3H8CCZ9`.
- **Automatically manage signing** đang bật nếu dự án dùng automatic signing.
- Tài khoản có quyền upload build lên App Store Connect.

### Dung lượng máy

Xcode tạo nhiều file tạm trên ổ hệ thống dù source nằm ở `/Volumes/MyData`. Nên để trống tối thiểu `10 GB` trên `/System/Volumes/Data` trước khi Archive và Distribute.

```bash
df -h /System/Volumes/Data
df -h /Volumes/MyData
```

Không bắt đầu upload khi ổ hệ thống chỉ còn vài trăm MB. Chỉ chạy một tiến trình Archive/Distribute tại một thời điểm.

### Flutter và CocoaPods

```bash
cd /Volumes/MyData/project/flutter_core/flutter_core
.fvm/flutter_sdk/bin/flutter --version
.fvm/flutter_sdk/bin/flutter pub get
cd ios
pod install
cd ..
cmp -s ios/Podfile.lock ios/Pods/Manifest.lock \
  && echo 'Pod locks OK' \
  || echo 'Pod locks KHÔNG khớp'
```

Kết quả `.fvm/flutter_sdk/bin/flutter --version` phải là Flutter `3.19.0`. Kết quả cuối phải là `Pod locks OK`.

## 4. Checklist trước khi Archive

- [ ] Pull/checkout đúng source cần phát hành.
- [ ] Xác nhận đúng App Version và Build Number trong `pubspec.yaml`.
- [ ] Chạy `.fvm/flutter_sdk/bin/flutter pub get`.
- [ ] Chạy `pod install` trong thư mục `ios`.
- [ ] `Podfile.lock` và `Pods/Manifest.lock` khớp nhau.
- [ ] Ổ hệ thống còn tối thiểu khoảng `10 GB`.
- [ ] Apple Developer Agreement đã được Account Holder chấp nhận.
- [ ] Xcode đăng nhập đúng Apple ID và Team.
- [ ] Mở `ios/Runner.xcworkspace`.
- [ ] Chọn đúng scheme/môi trường phát hành.
- [ ] Chọn destination **Any iOS Device (arm64)**.
- [ ] Dừng các tiến trình upload/archive khác.

Chỉ dùng `.fvm/flutter_sdk/bin/flutter clean` khi cache build có dấu hiệu lỗi hoặc sau thay đổi lớn. Sau khi clean, luôn chạy lại `.fvm/flutter_sdk/bin/flutter pub get` và `pod install`.

## 5. Archive bằng Xcode

1. Mở `ios/Runner.xcworkspace`.
2. Chọn đúng scheme (`prod` cho production nếu đó là quy ước của đội, hoặc `Runner` theo luồng hiện tại).
3. Chọn destination **Any iOS Device (arm64)**.
4. Chọn **Product > Archive**.
5. Chờ Xcode mở Organizer.
6. Kiểm tra archive hiển thị đúng Version, Build Number, ngày tạo và App Name.

Không dùng lại archive cũ nếu vừa thay version, build number, signing hoặc source code.

## 6. Distribute lên App Store Connect

Trong Organizer:

1. Chọn archive vừa tạo.
2. Chọn **Distribute App**.
3. Chọn **App Store Connect**.
4. Chọn **Upload**.
5. Giữ automatic signing nếu dự án đang dùng cơ chế này.
6. Kiểm tra phần Review: bundle ID, version, build, signing certificate và provisioning profile.
7. Chọn **Upload** và đợi kết thúc; không mở thêm một upload khác cùng lúc.

Sau khi upload thành công, App Store Connect thường cần vài phút để xử lý build. Vào TestFlight hoặc trang version tương ứng để kiểm tra trạng thái processing.

## 7. Xác minh archive trước khi upload

Có thể kiểm tra trực tiếp `Info.plist` bên trong archive:

```bash
ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives/YYYY-MM-DD/Runner ... .xcarchive"
/usr/libexec/PlistBuddy -c 'Print :ApplicationProperties:CFBundleIdentifier' "$ARCHIVE_PATH/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :ApplicationProperties:CFBundleShortVersionString' "$ARCHIVE_PATH/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :ApplicationProperties:CFBundleVersion' "$ARCHIVE_PATH/Info.plist"
```

Đường dẫn archive có thể lấy bằng cách chọn archive trong Organizer rồi chọn **Show in Finder**.

## 8. Xử lý các lỗi thường gặp

### `The sandbox is not in sync with the Podfile.lock`

Nguyên nhân: `ios/Pods/Manifest.lock` bị thiếu hoặc không khớp `ios/Podfile.lock`.

```bash
cd /Volumes/MyData/project/flutter_core/flutter_core
.fvm/flutter_sdk/bin/flutter pub get
cd ios
pod install
```

Sau đó đóng project và mở lại `Runner.xcworkspace`. Xem hướng dẫn chi tiết tại [IOS_PODS_MANIFEST_LOCK_FIX.md](./IOS_PODS_MANIFEST_LOCK_FIX.md).

### Package yêu cầu Dart/Flutter mới hơn

Nguyên nhân thường là đã chạy `flutter pub get` bằng Flutter global thay vì FVM của project.

```bash
cd /Volumes/MyData/project/flutter_core/flutter_core
.fvm/flutter_sdk/bin/flutter --version
.fvm/flutter_sdk/bin/flutter pub get
```

Đảm bảo `.dart_tool/package_config.json` được sinh bởi Flutter `3.19.0`.

### `PLA Update available`

Đây là lỗi tài khoản, không phải lỗi source. Account Holder phải đăng nhập Apple Developer và chấp nhận Program License Agreement mới. Sau đó refresh tài khoản trong **Xcode > Settings > Accounts** rồi thử lại.

### `No signing certificate "iOS Distribution" found`

- Xác nhận đúng Apple ID và Team trong Xcode.
- Bật automatic signing và cho phép Xcode quản lý certificate/profile.
- Nếu dùng certificate thủ công, máy phải có cả certificate và private key tương ứng trong Keychain.
- Không copy riêng file certificate từ máy khác vì certificate không có private key sẽ không ký được app.

Kiểm tra signing identity trên máy:

```bash
security find-identity -v -p codesigning
```

### `Error while generating code signature`

Đọc `IDEDistributionPipeline.log` để phân biệt lỗi local signing với lỗi cloud signing. Nếu log có dạng sau thì request ký từ xa của Apple đã thất bại tạm thời, không đồng nghĩa archive hoặc framework bị hỏng:

```text
code: RESULTS_UNAVAILABLE
status: 404
resultCode: 3193
detail: Error while generating code signature.
```

Ở lần Distribute `1.0.8 (17)` ngày 05/10/2026, Apple trả lỗi trên khi ký `FirebaseCrashlytics.framework`. Export lại chính archive đó sau vài phút đã thành công và framework được ký bằng Apple Distribution certificate bình thường.

Cách xử lý theo thứ tự:

1. Đợi vài phút rồi Distribute lại cùng archive; không cần thay Firebase hoặc tạo archive mới.
2. Vào **Xcode > Settings > Accounts**, đăng nhập lại account có session hết hạn hoặc xóa account cũ nếu chắc chắn không còn dùng.
3. Chọn đúng account/Team phát hành rồi refresh thông tin account.
4. Nếu lỗi lặp lại nhiều lần, vào **Manage Certificates** và tạo/import một `Apple Distribution` certificate có private key để Xcode ký local thay vì phụ thuộc hoàn toàn vào cloud signing.
5. Không revoke certificate đang dùng trên Apple Developer Portal nếu chưa xác nhận ảnh hưởng tới các máy hoặc pipeline khác.

Apple xác nhận Xcode sẽ dùng cloud-managed certificate trong luồng Organizer khi máy không có local distribution certificate. Có thể chuyển sang local signing bằng cách thêm Apple Distribution certificate hợp lệ vào Keychain.

### `Invalid Pre-Release Train` hoặc version không cao hơn bản đã duyệt

App Version hiện tại đã đóng hoặc đã được duyệt. Tăng `CFBundleShortVersionString`, ví dụ từ `1.0.7` lên `1.0.8`, đồng bộ version rồi tạo archive mới. Chỉ tăng Build Number không giải quyết được lỗi release train đã đóng.

### `The uploaded package is corrupt` / `Invalid package`

Kiểm tra dung lượng trước tiên:

```bash
df -h /System/Volumes/Data
```

Ở lần upload `1.0.8 (17)` ngày 05/10/2026, log Xcode ghi `Free disk space: 0.236GB`. Đây là nguyên nhân trực tiếp khiến gói tạm bị lỗi trong quá trình Distribute, dù archive đã tạo thành công.

Cách xử lý:

1. Dừng các upload/archive đang chạy.
2. Giải phóng tối thiểu khoảng `10 GB` trên ổ hệ thống.
3. Không xóa archive mới nhất đang cần upload.
4. Có thể chuyển archive cũ sang `/Volumes/MyData` để giữ khả năng khôi phục.
5. Mở lại Organizer và upload lại đúng archive.
6. Nếu Apple báo Build Number đã tồn tại, tăng Build Number và Archive lại; nếu build lỗi đã bị Apple xóa thì có thể thử lại cùng Build Number.

### Build Number đã tồn tại

Tăng số sau dấu `+` trong `pubspec.yaml`, đồng bộ cấu hình bằng `.fvm/flutter_sdk/bin/flutter build ios --config-only`, rồi tạo archive mới. Không thể chỉ sửa metadata của archive đã tạo.

## 9. Đọc log khi Distribute thất bại

Trong hộp thoại lỗi, chọn **Show Logs**. Distribution logs thường nằm tại:

```text
/private/var/folders/.../T/*.xcdistributionlogs
```

Các file quan trọng:

- `IDEDistribution.verbose.log`: toàn bộ luồng export/sign/upload.
- `ContentDelivery.log`: lỗi phản hồi từ App Store Connect, dung lượng trống và trạng thái upload.
- `IDEDistribution.standard.log`: tóm tắt quá trình distribute.

Tìm nhanh log gần nhất và các dấu hiệu quan trọng:

```bash
find /private/var/folders -type d -name '*.xcdistributionlogs' 2>/dev/null | tail -20
rg -n 'Free disk space|Invalid package|Validation failed|ERROR|409' \
  /path/to/Runner_*.xcdistributionlogs
```

Luôn lưu lại Error ID/Request ID trong thông báo của Apple để đối chiếu nếu cần mở ticket hỗ trợ.

## 10. Dọn dung lượng an toàn

Ưu tiên các cách có thể khôi phục:

- Trong Organizer, xác nhận version/build rồi xóa archive cũ không còn dùng.
- Hoặc chuyển archive cũ sang ổ `/Volumes/MyData/XcodeArchiveBackup/` thay vì xóa ngay.
- Xóa Derived Data qua **Xcode > Settings > Locations > Derived Data**.
- Xóa simulator không dùng qua **Xcode > Settings > Platforms** hoặc cửa sổ Devices and Simulators.
- Dọn Trash sau khi đã xác nhận không cần khôi phục.

Không xóa hàng loạt toàn bộ thư mục Archives, DerivedData hoặc CoreSimulator khi chưa kiểm tra chính xác mục tiêu. Giữ archive mới nhất cho tới khi build đã xuất hiện trên App Store Connect.

## 11. Checklist sau khi upload

- [ ] Xcode báo upload thành công.
- [ ] Build xuất hiện trong App Store Connect/TestFlight.
- [ ] Version và Build Number đúng.
- [ ] Trạng thái processing hoàn tất, không có email cảnh báo nghiêm trọng từ Apple.
- [ ] Chọn đúng build cho version phát hành.
- [ ] Cập nhật release note và thông tin review nếu cần.
- [ ] Chỉ dọn archive sau khi chắc chắn build đã được xử lý thành công.

## 12. Tài liệu Apple tham khảo

- [Upload builds to App Store Connect](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
- [Overview of accounts and roles](https://developer.apple.com/help/account/access/roles/)
- [Resolve account access issues](https://developer.apple.com/help/account/access/resolving-access-issues/)
- [Cloud-managed certificates](https://developer.apple.com/help/account/certificates/cloud-managed-certificates/)
- [Certificates overview](https://developer.apple.com/help/account/certificates/certificates-overview/)
