# 🧪 Network Connectivity Testing Guide

## Test Environment
- **Device**: Android (BH9704FBGU)
- **Build**: Dev flavor
- **Date**: December 6, 2025

---

## Pre-Test Setup

### 1. Build Latest Version
```bash
cd /Users/mac/Documents/flutter_core_project
flutter clean
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart -d BH9704FBGU
```

### 2. Verify Files Modified
- ✅ `pubspec.yaml` - Added `connectivity_plus`
- ✅ `lib/services/network_service.dart` - Created
- ✅ `lib/presentation/widgets/network/network_status_banner.dart` - Created
- ✅ `lib/main.dart` - Updated with NetworkService init
- ✅ `lib/presentation/pages/news/daily_news.dart` - Updated with network checks

### 3. Ensure Internet Access
- Test device should have working internet initially
- Have ability to toggle WiFi/Mobile data on device

---

## Test Cases

### Test 1: App Launches Successfully with Network
**Duration**: 2 minutes

**Steps**:
1. Device has WiFi/Mobile internet enabled
2. Build and run app
3. Observe splash screen
4. Navigate to home screen
5. App should load without errors

**Expected Results**:
- ✅ App launches successfully
- ✅ No network-related errors
- ✅ Splash screen displays normally
- ✅ MainScreen loads all tabs

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 2: Daily News Loads with Internet
**Duration**: 3 minutes

**Steps**:
1. App is running with internet enabled
2. Verify you're on home screen
3. Tap Delivery tab (2nd tab icon)
4. Observe loading indicator
5. Wait for articles to load

**Expected Results**:
- ✅ Loading indicator appears
- ✅ Articles load successfully
- ✅ No error messages
- ✅ News list displays correctly
- ✅ Each article is clickable

**Pass/Fail**: [ ] Pass [ ] Fail

**Screenshots**: [ ] Captured

---

### Test 3: Network Status Banner (Offline)
**Duration**: 5 minutes

**Steps**:
1. App is running with internet
2. Disable WiFi on device (or put in airplane mode)
3. Observe top of screen
4. A red banner should appear saying "No Internet Connection"
5. Navigate between tabs
6. Re-enable internet
7. Banner should disappear

**Expected Results**:
- ✅ Red banner appears immediately when offline
- ✅ Banner displays "No Internet Connection" text
- ✅ Cloud off icon is visible
- ✅ Banner persists across tab navigation
- ✅ Banner disappears when connection restored
- ✅ No app crash or errors

**Pass/Fail**: [ ] Pass [ ] Fail

**Screenshots**: [ ] With banner [ ] After reconnect

---

### Test 4: No Internet Dialog (Daily News)
**Duration**: 5 minutes

**Prerequisites**: Device must be able to toggle internet

**Steps**:
1. App is running
2. Disable all internet (WiFi and Mobile data OFF)
3. Kill app or clear it from recent apps
4. Reopen app
5. Navigate to Delivery tab
6. Observe dialog that appears

**Expected Results**:
- ✅ Dialog appears: "No Internet Connection"
- ✅ Large cloud-off icon displayed
- ✅ Message: "Please check your internet connection to load articles."
- ✅ Two buttons: "Cancel" and "Retry"
- ✅ Dialog is not dismissible by tapping outside

**Pass/Fail**: [ ] Pass [ ] Fail

**Dialog appears**: [ ] Yes [ ] No

---

### Test 5: No Internet Error UI (Daily News)
**Duration**: 3 minutes

**Prerequisites**: No internet connection

**Steps**:
1. Dialog from Test 4 is showing
2. Tap "Cancel" button
3. Observe main screen UI

**Expected Results**:
- ✅ Dialog closes
- ✅ Error UI is displayed with:
  - Error icon
  - "Unable to load news" title
  - "API service is not available..." message
  - Retry button
- ✅ Navigation to other tabs should work

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 6: Retry Button (No Internet)
**Duration**: 3 minutes

**Prerequisites**: No internet, on error UI

**Steps**:
1. Error UI is displaying (from Test 5)
2. Tap "Retry" button
3. Observe what happens

**Expected Results**:
- ✅ Dialog appears again: "No Internet Connection"
- ✅ Retry mechanism works
- ✅ No app crash

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 7: Retry with Internet Restored
**Duration**: 5 minutes

**Prerequisites**: No internet, showing no internet dialog

**Steps**:
1. No internet dialog is showing
2. Enable WiFi/Mobile internet on device
3. Tap "Retry" button
4. Wait for articles to load

**Expected Results**:
- ✅ Dialog closes
- ✅ Loading indicator appears
- ✅ Articles load successfully
- ✅ News list displays
- ✅ Red banner disappears (if it was showing)

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 8: Network Status Changes (Rapid Toggle)
**Duration**: 5 minutes

**Prerequisites**: App running, ability to toggle internet

**Steps**:
1. App is running on Daily News tab
2. Turn off WiFi → Observe red banner
3. Turn on WiFi → Banner disappears
4. Turn off WiFi → Banner reappears
5. Turn on WiFi → Banner disappears again
6. Repeat 2-3 times

**Expected Results**:
- ✅ Banner responds immediately to network changes
- ✅ No lag or delay in banner appearance/disappearance
- ✅ No app crashes
- ✅ App remains stable throughout

**Pass/Fail**: [ ] Pass [ ] Fail

**Stability**: [ ] Excellent [ ] Good [ ] Poor

---

### Test 9: Tab Navigation Without Internet
**Duration**: 3 minutes

**Prerequisites**: App offline (no internet)

**Steps**:
1. No internet enabled
2. App is running
3. Navigate through all tabs:
   - Home tab → Click
   - Delivery tab → Should show error/dialog
   - Favorites tab → Click
   - Profile tab → Click
4. Return to Delivery tab
5. Repeat navigation 3 times

**Expected Results**:
- ✅ All tabs navigate smoothly
- ✅ No app crashes
- ✅ Error dialog shows consistently on Delivery tab
- ✅ Red banner persists during navigation
- ✅ State is maintained properly

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 10: App Restart Without Internet
**Duration**: 5 minutes

**Prerequisites**: No internet connection

**Steps**:
1. App is running, showing no internet dialog/UI
2. Kill app (swipe away from recent apps)
3. Reopen app immediately
4. Navigate to Delivery tab
5. Observe behavior

**Expected Results**:
- ✅ Splash screen loads
- ✅ Main screen loads
- ✅ When navigating to Delivery tab, shows no internet dialog
- ✅ Error UI displays if dialog is dismissed
- ✅ App handles restart gracefully

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 11: Airplane Mode Test
**Duration**: 3 minutes

**Prerequisites**: App running with internet

**Steps**:
1. App is running normally
2. Enable Airplane Mode on device
3. Observe red banner
4. Disable Airplane Mode
5. Banner should disappear

**Expected Results**:
- ✅ Red banner appears immediately
- ✅ App remains usable
- ✅ Tab navigation works
- ✅ Network status updates correctly

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 12: Profile Tab (No Internet)
**Duration**: 3 minutes

**Prerequisites**: No internet connection

**Steps**:
1. No internet enabled
2. Navigate to Profile tab
3. Try tapping Settings
4. Navigate to Settings (no API calls expected)

**Expected Results**:
- ✅ Profile screen loads
- ✅ Settings screen opens (no network needed)
- ✅ Theme/Language switching works
- ✅ Red banner still visible

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 13: Memory Management (Long Duration)
**Duration**: 10 minutes

**Prerequisites**: Internet available

**Steps**:
1. App running with internet
2. Navigate through all tabs 20+ times
3. Toggle internet on/off 10+ times
4. Monitor app performance
5. Check device memory usage

**Expected Results**:
- ✅ App remains responsive
- ✅ No noticeable lag or stutter
- ✅ No memory leaks (smooth performance throughout)
- ✅ No crashes
- ✅ Navigation remains smooth

**Pass/Fail**: [ ] Pass [ ] Fail

**Performance**: [ ] Excellent [ ] Good [ ] Fair [ ] Poor

---

### Test 14: User Permissions
**Duration**: 2 minutes

**Steps**:
1. Build and run app
2. Check logcat for permission requests
3. Verify app doesn't crash without permissions

**Expected Results**:
- ✅ App requests network permission if needed
- ✅ Works with permissions granted
- ✅ Handles permission denial gracefully

**Pass/Fail**: [ ] Pass [ ] Fail

---

### Test 15: API Failure vs Network Failure
**Duration**: 5 minutes

**Prerequisites**: Internet available

**Steps**:
1. Internet is on
2. Navigate to Delivery tab
3. If articles load successfully → Good
4. If API error occurs → Observe error UI
5. Compare error message with "No Internet" error

**Expected Results**:
- ✅ Two error states are distinct:
  - Network error: "No Internet Connection"
  - API error: "Failed to load articles"
- ✅ Both show appropriate messages
- ✅ Both offer retry

**Pass/Fail**: [ ] Pass [ ] Fail

---

## Summary Results

### Overall Results
| Test # | Test Name | Status | Notes |
|--------|-----------|--------|-------|
| 1 | App Launches | [ ] | |
| 2 | Daily News Loads | [ ] | |
| 3 | Network Banner | [ ] | |
| 4 | No Internet Dialog | [ ] | |
| 5 | Error UI | [ ] | |
| 6 | Retry (Offline) | [ ] | |
| 7 | Retry (Online) | [ ] | |
| 8 | Rapid Toggle | [ ] | |
| 9 | Tab Navigation | [ ] | |
| 10 | App Restart | [ ] | |
| 11 | Airplane Mode | [ ] | |
| 12 | Profile Tab | [ ] | |
| 13 | Memory Management | [ ] | |
| 14 | Permissions | [ ] | |
| 15 | API vs Network | [ ] | |

### Critical Test Results
- [ ] Tests 1-7: All passing (required for production)
- [ ] Tests 8-15: All passing (recommended)

### Overall Status
- [ ] 🟢 **READY** - All tests pass
- [ ] 🟡 **MINOR ISSUES** - Some tests fail, but not critical
- [ ] 🔴 **MAJOR ISSUES** - Critical tests failing

---

## Known Issues & Workarounds

### Issue: Dialog doesn't appear when offline
**Cause**: Network check might be passing despite no internet
**Workaround**: Ensure device has internet fully disabled, not just WiFi

### Issue: Red banner shows but no dialog
**Cause**: DailyNews screen not updated with network checks
**Workaround**: Manually check code in `daily_news.dart`

### Issue: App crashes on network toggle
**Cause**: Rapid state changes not handled
**Workaround**: Use debouncing or throttling for network status changes

---

## Performance Metrics

**Baseline** (with internet):
- App launch time: _____ seconds
- Daily News load time: _____ seconds
- Memory usage: _____ MB

**During network change**:
- Banner appearance delay: _____ ms
- API cancellation delay: _____ ms

---

## Regression Testing

After fixing any bugs, rerun these critical tests:
- [ ] Test 1: App launch
- [ ] Test 3: Network banner
- [ ] Test 4: No internet dialog
- [ ] Test 7: Retry with internet
- [ ] Test 13: Memory management

---

## Sign-Off

**Tester**: _________________________  
**Date**: _________________________  
**Build Version**: _________________________  
**Overall Result**: 🟢 Pass / 🟡 Minor Issues / 🔴 Fail  

**Critical Issues Found**: _________________________  

**Comments**:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Next Steps

1. ✅ Run all 15 tests
2. ✅ Document results
3. ✅ Fix any critical issues
4. ✅ Rerun critical tests
5. ✅ Sign-off on results
6. ➡️ Merge to production branch

