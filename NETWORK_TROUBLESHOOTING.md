# DNS/Network Connection Error Troubleshooting

## Vấn đề
Lỗi: `Failed host lookup: 'newsapi.org'` hoặc `SocketException: No address associated with hostname`

## Nguyên nhân có thể

### 1. **Không có kết nối Internet thực sự**
- WiFi/Mobile data đã bật nhưng không có kết nối thực sự
- Cần kiểm tra kết nối thực tế, không chỉ kiểm tra connectivity status

### 2. **DNS Resolution bị lỗi**
- DNS server không thể resolve domain `newsapi.org`
- Có thể do DNS server của ISP bị vấn đề

### 3. **Firewall/Security**
- MacOS Firewall đang chặn ứng dụng
- Antivirus/Security software chặn kết nối
- VPN đang hoạt động và chặn một số domain

### 4. **Network Configuration trên Mac mới**
- Máy Mac mới chưa được cấu hình đúng network settings
- DNS cache bị lỗi

## Giải pháp

### Bước 1: Kiểm tra kết nối cơ bản

```bash
# Terminal - Kiểm tra có thể ping được google không
ping -c 3 google.com

# Kiểm tra DNS resolution
nslookup newsapi.org
nslookup google.com

# Kiểm tra DNS server đang dùng
scutil --dns
```

### Bước 2: Test trong app

Mở Network Debug Page trong app:
1. Từ main screen, navigate to Settings (nếu có)
2. Hoặc thêm button debug vào DailyNews page
3. Chạy network diagnostics

```dart
// Thêm vào daily_news.dart để test nhanh
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NetworkDebugPage(),
      ),
    );
  },
  child: const Icon(Icons.network_check),
)
```

### Bước 3: Thay đổi DNS Server

**Cách 1: Thông qua System Preferences**
1. System Preferences → Network
2. Chọn WiFi/Ethernet → Advanced
3. Tab DNS → Thêm:
   - `8.8.8.8` (Google DNS)
   - `8.8.4.4` (Google DNS backup)
   - `1.1.1.1` (Cloudflare DNS)
4. Apply và test lại

**Cách 2: Terminal (Temporary)**
```bash
# Flush DNS cache
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Set DNS for current session
networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
```

### Bước 4: Kiểm tra Firewall

```bash
# Check firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Kiểm tra app có bị block không
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps
```

**Giải pháp:**
1. System Preferences → Security & Privacy → Firewall
2. Firewall Options → Tìm Flutter app
3. Set to "Allow incoming connections"

### Bước 5: Tắt VPN tạm thời

Nếu đang dùng VPN:
1. Tắt VPN
2. Test app
3. Nếu work → VPN đang chặn newsapi.org
4. Giải pháp: Whitelist newsapi.org trong VPN settings

### Bước 6: Test với API khác

Để verify không phải là vấn đề với newsapi.org:

```bash
# Test API endpoint trực tiếp
curl "https://newsapi.org/v2/top-headlines?country=us&apiKey=YOUR_API_KEY"

# Test DNS
host newsapi.org
dig newsapi.org
```

## Code Changes Implemented

### 1. Enhanced Network Detection
File: `lib/services/network_service.dart`
- Thêm DNS lookup test thay vì chỉ check connectivity status
- Test với google.com để verify kết nối thực sự

### 2. Better Error Messages
File: `lib/presentation/pages/news/daily_news.dart`
- Phát hiện connection error vs API error
- Hiển thị thông báo cụ thể: "DNS lookup failed for newsapi.org"
- Hướng dẫn user check connection

### 3. Debug Logging
File: `lib/data/repositories/news/article_repository_impl.dart`
- Log URL, API key (partial), status code
- Log chi tiết DioException type và error

### 4. Network Test Helper
File: `lib/utils/network_test_helper.dart`
- Test DNS resolution cho google.com và newsapi.org
- Cung cấp diagnosis dựa trên kết quả

### 5. Network Debug Page
File: `lib/presentation/pages/debug/network_debug_page.dart`
- UI để chạy network diagnostics
- Hiển thị kết quả và troubleshooting tips

## Testing Steps

### 1. Test No Internet
```bash
# Tắt WiFi hoàn toàn
# Open app → DailyNews
# Expected: "No Internet Connection" message
```

### 2. Test DNS Issue
```bash
# Set DNS server sai
networksetup -setdnsservers Wi-Fi 0.0.0.0

# Open app → DailyNews
# Expected: "DNS lookup failed" error
```

### 3. Test Working Connection
```bash
# Set DNS đúng
networksetup -setdnsservers Wi-Fi 8.8.8.8

# Open app → DailyNews
# Expected: Articles load successfully
```

## Quick Fix Commands

```bash
# 1. Flush DNS cache
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# 2. Set Google DNS
networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4

# 3. Test connectivity
curl -I https://newsapi.org

# 4. Check DNS resolution
nslookup newsapi.org

# 5. Reset network settings (extreme)
sudo networksetup -setnetworkserviceenabled "Wi-Fi" off
sudo networksetup -setnetworkserviceenabled "Wi-Fi" on
```

## Expected Console Output

### When DNS fails:
```
🔍 Checking network...
📶 Has Internet: true
✅ Internet available, loading articles...
📰 Dispatching GetArticles event
🌐 Fetching articles from NewsAPI...
📍 URL: https://newsapi.org/v2
🔑 API Key: ff957763...
❌ DioException caught in repository:
   Type: DioExceptionType.connectionError
   Message: The connection errored: Failed host lookup: 'newsapi.org'
   Error: SocketException: Failed host lookup: 'newsapi.org' (OS Error: No address associated with hostname, errno = 7)
⚠️ Connection/DNS error detected
```

### When working:
```
🔍 Checking network...
📶 Has Internet: true
✅ Internet available, loading articles...
📰 Dispatching GetArticles event
🌐 Fetching articles from NewsAPI...
📍 URL: https://newsapi.org/v2
🔑 API Key: ff957763...
✅ Response received: 200
📰 Articles count: 20
```

## Recommendation

**Khả năng cao nhất:** DNS resolution issue trên Mac mới

**Giải pháp nhanh nhất:**
1. Flush DNS cache
2. Set DNS to 8.8.8.8 and 8.8.4.4
3. Restart app
4. Test lại

Nếu vẫn không work sau khi thay DNS → Có thể là firewall hoặc VPN issue.
