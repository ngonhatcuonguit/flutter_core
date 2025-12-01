# ⚡ Quick Testing Script

## 🎯 Test này app trên device của bạn ngay bây giờ!

App đang chạy trên device **802SO** (BH9704FBGU) ✅

---

## 📱 Test 1: Daily News Bug Fix (2 phút)

### Bước 1: Kiểm tra Bottom Navigation
1. Mở app (đang chạy)
2. Nếu chưa login → Sign In với email/password bất kỳ
3. Bạn sẽ thấy màn hình MainScreen với 4 tabs ở bottom

### Bước 2: Test Daily News Tab
1. **Tap vào tab thứ 2** (Delivery icon - có icon xe giao hàng)
2. **Quan sát**:
   - ✅ **PASS**: Màn hình load, show loading indicator hoặc articles
   - ❌ **FAIL**: App crash với error "ArgumentError: No host specified in URI"

3. **Switch tabs**: Home → Delivery → Favorites → Profile (3 lần)
   - ✅ **PASS**: Không crash, mượt mà
   - ❌ **FAIL**: Crash khi switch

**Expected**: ✅ Không crash, Daily News load bình thường

---

## ⚙️ Test 2: Settings Screen (3 phút)

### Bước 1: Mở Settings
1. Tap vào tab **Profile** (icon user, tab cuối cùng)
2. Tap vào **Settings** (menu item đầu tiên, icon xám)
3. **Quan sát**:
   - ✅ Màn hình Settings mở ra
   - ✅ Có 2 sections: "Appearance" và "Language"

### Bước 2: Test Theme Switching
1. Note theme hiện tại (Light hay Dark)
2. **Tap vào Light theme** (icon mặt trời):
   - ✅ Background chuyển sang màu trắng
   - ✅ Text chuyển sang màu đen
   - ✅ Border xanh lá (#42C83C) xuất hiện quanh Light option
   
3. **Tap vào Dark theme** (icon mặt trăng):
   - ✅ Background chuyển sang màu đen (#1C1C1C)
   - ✅ Text chuyển sang màu trắng
   - ✅ Border xanh lá xuất hiện quanh Dark option

4. **Navigate về Profile** → Theme vẫn giữ nguyên
5. **Navigate qua Home, Delivery, Favorites** → Tất cả đều dùng theme mới

### Bước 3: Test Language Switching
1. Trong Settings, scroll xuống "Language"
2. **Tap English (EN)**:
   - ✅ Green border + checkmark xuất hiện
   - ✅ UI text chuyển sang tiếng Anh (nếu có translation)
   
3. **Tap Tiếng Việt (VI)**:
   - ✅ Green border + checkmark xuất hiện
   - ✅ UI text chuyển sang tiếng Việt (nếu có translation)

**Expected**: ✅ Theme và Language switch instant, không lag

---

## 🚪 Test 3: Logout & Persistence (2 phút)

### Bước 1: Test Logout
1. Từ Settings, back về Profile
2. Scroll xuống, tap **Log Out** (menu item màu đỏ)
3. **Quan sát dialog**:
   - ✅ Hiện dialog "Logout" với 2 buttons: Cancel và Logout
4. Tap **Cancel** → Dialog đóng, vẫn ở Profile
5. Tap **Log Out** lại → Tap **Logout** button
6. **Quan sát navigation**:
   - ✅ Redirect về màn hình GetStarted
   - ✅ Không còn login state

### Bước 2: Test Persistence
1. **Kill app** (swipe away from recent apps)
2. **Mở lại app**
3. **Quan sát**:
   - ✅ Không auto-login (phải login lại)
   - ✅ Theme vẫn giữ nguyên (Light/Dark)
   - ✅ Language vẫn giữ nguyên (EN/VI)

4. **Login lại** → Navigate to Settings
5. **Thay đổi theme** (Light ↔ Dark)
6. **Kill app** → **Mở lại**
7. **Login** → **Quan sát**:
   - ✅ Theme đã thay đổi vẫn được giữ

**Expected**: ✅ Logout xóa auth state, nhưng settings (theme/language) persist

---

## 🔥 Test 4: Stress Test (2 phút)

### Test 4.1: Rapid Tab Switching
1. Tap nhanh liên tục: Home → Delivery → Favorites → Profile
2. Lặp lại 10 lần
3. **Quan sát**:
   - ✅ **PASS**: Không lag, không crash
   - ❌ **FAIL**: Lag, crash, hoặc UI freeze

### Test 4.2: Rapid Theme Switching
1. Vào Settings
2. Tap nhanh: Light → Dark → Light → Dark (10 lần)
3. **Quan sát**:
   - ✅ **PASS**: Instant switch, không lag
   - ❌ **FAIL**: Lag, delay, hoặc crash

### Test 4.3: Rapid Language Switching
1. Vào Settings
2. Tap nhanh: EN → VI → EN → VI (10 lần)
3. **Quan sát**:
   - ✅ **PASS**: Instant switch, không lag
   - ❌ **FAIL**: Lag, delay, hoặc crash

**Expected**: ✅ App stable, không crash dưới stress

---

## ✅ Quick Result Checklist

### Critical Tests (Must Pass)
- [ ] ✅ Daily News tab loads without crash
- [ ] ✅ Settings screen opens and displays correctly
- [ ] ✅ Theme switching works (Light ↔ Dark)
- [ ] ✅ Theme persists after app restart
- [ ] ✅ Language switching works (EN ↔ VI)
- [ ] ✅ Language persists after app restart
- [ ] ✅ Logout clears auth but keeps settings
- [ ] ✅ Rapid switching doesn't crash app

### Overall Status
- [ ] 🟢 **All Pass** - Ready for production
- [ ] 🟡 **Minor Issues** - Need fixes but usable
- [ ] 🔴 **Major Issues** - Need urgent fixes

---

## 🐛 If You Find Bugs

**Cách report**:
1. Screenshot/screen record lỗi
2. Note lại steps để reproduce
3. Check console log in terminal (terminal đang chạy app)
4. Share với developer

**Common Issues & Solutions**:

### Issue: App crash khi mở Daily News
**Solution**: Already fixed! Nếu vẫn crash → Hot reload app:
- Press `r` in terminal (hot reload)
- Press `R` in terminal (hot restart)

### Issue: Settings không mở được
**Solution**: Check console log, có thể thiếu BLoC provider
- Press `R` in terminal (full restart)

### Issue: Theme/Language không persist
**Solution**: Check HydratedBloc initialization
- Verify `await HydratedBloc.build()` in main.dart

---

## 🎬 Demo Flow (1 phút)

**Perfect demo sequence**:
1. **Launch app** → Splash → Login
2. **Tap Delivery** → Daily News loads ✅
3. **Tap Profile** → Profile screen
4. **Tap Settings** → Settings opens
5. **Switch Dark → Light** → Instant change ✅
6. **Switch EN → VI** → Language updates ✅
7. **Back to Profile** → Theme persisted ✅
8. **Navigate all tabs** → Everything works ✅
9. **Logout** → Returns to GetStarted ✅
10. **Kill & restart** → Settings persisted ✅

**Total time**: ~1 phút
**Expected result**: 🟢 All features working perfectly

---

## 📊 Test Summary Template

**Tester**: _______________  
**Date**: December 1, 2025  
**Device**: 802SO (BH9704FBGU)  
**Build**: Dev flavor  

**Test Results**:
- Test 1 (Daily News): ✅ Pass / ❌ Fail
- Test 2 (Settings): ✅ Pass / ❌ Fail  
- Test 3 (Logout): ✅ Pass / ❌ Fail
- Test 4 (Stress): ✅ Pass / ❌ Fail

**Bugs Found**: _____  
**Critical Issues**: _____  
**Status**: 🟢 Ready / 🟡 Minor Issues / 🔴 Major Issues

**Notes**: 
_______________________________
_______________________________

---

## 🚀 Hot Commands

App đang chạy, bạn có thể dùng commands trong terminal:

- **`r`** - Hot reload (apply code changes instantly)
- **`R`** - Hot restart (restart app completely)
- **`c`** - Clear console
- **`q`** - Quit app
- **`h`** - Show help

**Terminal path**: Đang mở terminal với app running

---

## ✨ Expected Final State

Sau khi test xong, app phải:
- ✅ Không crash ở bất cứ đâu
- ✅ Daily News load successfully
- ✅ Settings screen fully functional
- ✅ Theme switching works perfectly
- ✅ Language switching works perfectly
- ✅ Logout flow works correctly
- ✅ Settings persist across restarts
- ✅ Smooth performance, no lag

**If all ✅** → 🎉 **READY FOR PRODUCTION!**
