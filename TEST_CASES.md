# Test Cases for Flutter Core Project

## 📱 Test Environment
- **Build Flavor**: Dev
- **Device**: Physical Android Device (BH9704FBGU)
- **Date**: December 1, 2025

---

## ✅ Test Cases

### 1. Authentication Flow
- [ ] **TC001**: First time user sees intro screens
- [ ] **TC002**: Returning user (logged in) goes directly to MainScreen
- [ ] **TC003**: User can skip intro and see SignIn/SignUp option
- [ ] **TC004**: Mock login works with any email/password
- [ ] **TC005**: Mock signup works with any credentials
- [ ] **TC006**: Login state persists after app restart

### 2. Bottom Navigation
- [ ] **TC007**: Home tab loads correctly
- [ ] **TC008**: Delivery (Daily News) tab loads without crashing
- [ ] **TC009**: Favorites tab loads correctly
- [ ] **TC010**: Profile tab loads correctly
- [ ] **TC011**: Active tab shows green circular indicator
- [ ] **TC012**: Navigation between tabs maintains state

### 3. Daily News Screen (Bug Fix)
- [ ] **TC013**: Navigate to Delivery tab without crash
- [ ] **TC014**: BLoC initializes correctly (no ArgumentError)
- [ ] **TC015**: Loading indicator shows while fetching articles
- [ ] **TC016**: Articles display correctly (or error icon if no data)
- [ ] **TC017**: No memory leaks when switching tabs

### 4. Profile Screen
- [ ] **TC018**: Profile displays user email and name
- [ ] **TC019**: All menu items display with correct icons and colors
  - Settings (gray)
  - Notification (blue)
  - Order History (orange)
  - Privacy & Policy (blue)
  - Terms & Conditions (yellow)
  - Log Out (red)
- [ ] **TC020**: Menu items are tappable
- [ ] **TC021**: Profile UI adapts to dark/light mode

### 5. Settings Screen (New Feature)
- [ ] **TC022**: Settings screen opens from Profile menu
- [ ] **TC023**: Theme selector displays Light/Dark options
- [ ] **TC024**: Current theme is highlighted (green border + icon)
- [ ] **TC025**: Switching to Light theme updates entire app
- [ ] **TC026**: Switching to Dark theme updates entire app
- [ ] **TC027**: Theme persists after app restart
- [ ] **TC028**: Language selector displays English/Vietnamese
- [ ] **TC029**: Current language is highlighted (green border + checkmark)
- [ ] **TC030**: Switching to English updates UI text
- [ ] **TC031**: Switching to Vietnamese updates UI text
- [ ] **TC032**: Language persists after app restart
- [ ] **TC033**: Settings UI adapts to current theme

### 6. Logout Flow
- [ ] **TC034**: Logout button shows confirmation dialog
- [ ] **TC035**: Cancel button dismisses dialog, stays logged in
- [ ] **TC036**: Logout button clears auth state
- [ ] **TC037**: After logout, user returns to GetStarted screen
- [ ] **TC038**: After logout and restart, user doesn't auto-login

### 7. Dark/Light Mode Integration
- [ ] **TC039**: All screens support dark mode
- [ ] **TC040**: All screens support light mode
- [ ] **TC041**: Theme changes apply instantly without restart
- [ ] **TC042**: Colors, backgrounds, text adapt correctly
- [ ] **TC043**: Bottom navigation adapts to theme

### 8. Language Integration
- [ ] **TC044**: Choose Mode screen shows correct language
- [ ] **TC045**: All translated strings work in English
- [ ] **TC046**: All translated strings work in Vietnamese
- [ ] **TC047**: Language changes apply instantly

### 9. Performance & Stability
- [ ] **TC048**: App launches without crash (cold start)
- [ ] **TC049**: App resumes without crash (warm start)
- [ ] **TC050**: No ANR (Application Not Responding) during navigation
- [ ] **TC051**: Smooth animations and transitions
- [ ] **TC052**: No excessive memory usage
- [ ] **TC053**: No memory leaks when navigating

### 10. Edge Cases
- [ ] **TC054**: Rapid tab switching doesn't crash app
- [ ] **TC055**: Rapid theme switching doesn't crash app
- [ ] **TC056**: Rapid language switching doesn't crash app
- [ ] **TC057**: Back button navigation works correctly
- [ ] **TC058**: System back button respects navigation stack

---

## 🐛 Known Issues Fixed

### Issue 1: Daily News BLoC Crash
**Problem**: `ArgumentError (Invalid argument(s): No host specified in URI)` when navigating to Delivery tab

**Root Cause**: BLoC context accessed in `initState()` before widget tree is ready

**Solution**: 
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) {
    try {
      final bloc = context.read<RemoteArticlesBloc>();
      if (!bloc.isClosed) {
        bloc.add(const GetArticles());
      }
    } catch (e) {
      debugPrint('RemoteArticlesBloc not found: $e');
    }
  }
});
```

---

## 📋 Test Execution Checklist

### Pre-Test Setup
- [x] Build app with dev flavor
- [ ] Install app on device
- [ ] Clear app data for fresh start
- [ ] Prepare test scenarios

### Test Execution
- [ ] Execute all 58 test cases
- [ ] Document any failures
- [ ] Capture screenshots/videos of issues
- [ ] Report bugs with reproduction steps

### Post-Test
- [ ] Verify all critical paths work
- [ ] Confirm bug fixes are effective
- [ ] Validate new features work as expected
- [ ] Document test results

---

## 🎯 Priority Test Cases (Must Pass)

1. **TC013**: Daily News loads without crash ⭐⭐⭐
2. **TC022**: Settings screen opens ⭐⭐⭐
3. **TC025/TC026**: Theme switching works ⭐⭐⭐
4. **TC030/TC031**: Language switching works ⭐⭐⭐
5. **TC036**: Logout clears state ⭐⭐⭐
6. **TC048**: App launches successfully ⭐⭐⭐

---

## 📊 Expected Results

✅ **Success Criteria**:
- 0 crashes during navigation
- All 6 priority test cases pass
- Theme/language changes apply instantly
- Settings screen fully functional
- Daily News bug is fixed

❌ **Failure Criteria**:
- Any crash during basic navigation
- Settings screen not working
- Theme/language changes don't persist
- Daily News still crashes
