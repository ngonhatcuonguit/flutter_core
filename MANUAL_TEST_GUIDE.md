# 🧪 Manual Testing Guide

## ⚡ Quick Test Sequence

### Phase 1: Critical Bug Fix - Daily News (TC013-TC017)
1. **Launch App** → Should see Splash screen
2. **Navigate** → Sign In (if first time) or go to MainScreen (if logged in)
3. **Tap "Delivery" tab** (second icon in bottom nav)
   - ✅ **PASS**: Screen loads without crash
   - ❌ **FAIL**: App crashes with ArgumentError
4. **Check Loading** → Should see loading indicator or articles/error icon
5. **Switch tabs** → Home → Delivery → Favorites → Profile
   - ✅ **PASS**: No crashes, smooth navigation
6. **Repeat 3-4 times** → Ensure stability

**Expected Result**: No crashes, Daily News loads correctly

---

### Phase 2: Settings Screen (TC022-TC033)
1. **Navigate to Profile** → Tap Profile icon (4th tab)
2. **Tap Settings** → First menu item with gray icon
3. **Verify UI**:
   - Section headers: "Appearance", "Language"
   - Theme options: Light (sun icon), Dark (moon icon)
   - Language options: English (EN), Tiếng Việt (VI)
   - Current selections have green border and checkmark

**Expected Result**: Settings screen displays correctly

---

### Phase 3: Theme Switching (TC024-TC027)
1. **In Settings** → Note current theme
2. **Tap Light Theme** → App should instantly update to light colors
   - Background: White
   - Text: Black
   - Cards: Light gray
3. **Tap Dark Theme** → App should instantly update to dark colors
   - Background: Dark gray (#1C1C1C)
   - Text: White
   - Cards: Darker gray (#2C2C2C)
4. **Navigate back to Profile** → Theme should persist
5. **Navigate to Home, Delivery, Favorites** → All screens use new theme
6. **Kill app and restart** → Theme should persist

**Expected Result**: Theme changes apply instantly, persist across screens and restarts

---

### Phase 4: Language Switching (TC028-TC032)
1. **In Settings** → Scroll to Language section
2. **Tap English (EN)**:
   - UI should show English text
   - Settings title: "Settings"
   - Sections: "Appearance", "Language"
3. **Tap Tiếng Việt (VI)**:
   - UI should show Vietnamese text
   - Settings title might change
4. **Navigate to other screens** → Check if language applies
5. **Kill app and restart** → Language should persist

**Expected Result**: Language changes apply instantly and persist

---

### Phase 5: Profile Menu Navigation (TC019-TC020)
1. **In Profile** → Verify all menu items display:
   - ⚙️ Settings (gray background)
   - 🔔 Notification (blue background)
   - 📦 Order History (orange background)
   - 🔒 Privacy & Policy (blue background)
   - 📄 Terms & Conditions (yellow background)
   - 🚪 Log Out (red background)
2. **Tap each item** → Should be tappable (Settings works, others can be placeholders)

**Expected Result**: All menu items display with correct colors and are interactive

---

### Phase 6: Logout Flow (TC034-TC038)
1. **In Profile** → Tap "Log Out" (red menu item)
2. **Verify Dialog** → Shows "Logout" title and confirmation message
3. **Tap Cancel** → Dialog dismisses, stays on Profile
4. **Tap Log Out again** → Tap "Logout" in dialog
5. **Verify Navigation** → Redirects to GetStarted screen
6. **Kill app and restart** → Should show intro/login, not auto-login to MainScreen

**Expected Result**: Logout clears auth state and prevents auto-login

---

### Phase 7: Stress Testing (TC054-TC058)
1. **Rapid Tab Switching**:
   - Tap tabs quickly: Home → Delivery → Favorites → Profile → repeat 10x
   - ✅ **PASS**: No crashes, smooth navigation
   
2. **Rapid Theme Switching**:
   - Settings → Tap Light → Dark → Light → Dark (10x fast)
   - ✅ **PASS**: No lag, no crash
   
3. **Rapid Language Switching**:
   - Settings → Tap EN → VI → EN → VI (10x fast)
   - ✅ **PASS**: No lag, no crash

4. **System Back Button**:
   - Profile → Settings → Press device back button
   - Should return to Profile, not exit app
   
5. **App Back Button**:
   - Profile → Settings → Tap back arrow in AppBar
   - Should return to Profile

**Expected Result**: App remains stable under stress, back navigation works correctly

---

## ✅ Final Checklist

### Must-Pass Tests
- [ ] Daily News tab loads without crash
- [ ] Settings screen opens and displays correctly
- [ ] Theme switching (Light ↔ Dark) works and persists
- [ ] Language switching (EN ↔ VI) works and persists
- [ ] Logout clears state and returns to GetStarted
- [ ] All tabs navigate smoothly without crashes

### Nice-to-Have Tests
- [ ] Profile menu items have correct icon colors
- [ ] UI adapts to dark/light mode on all screens
- [ ] Bottom navigation shows active state correctly
- [ ] Rapid switching doesn't cause issues
- [ ] Memory usage remains stable

---

## 🐛 Bug Reporting Template

If you find a bug, report it like this:

**Bug ID**: BUG-XXX  
**Title**: [Screen] Short description  
**Severity**: Critical / Major / Minor  
**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Result**: What should happen  
**Actual Result**: What actually happens  
**Screenshots**: (if applicable)  
**Device**: 802SO (BH9704FBGU)  
**Build**: Dev flavor, December 1, 2025

---

## 🎬 Test Execution

**Start Time**: _____  
**End Time**: _____  
**Tester**: _____  
**Total Tests**: 58  
**Passed**: _____  
**Failed**: _____  
**Blocked**: _____  

**Critical Issues Found**: _____  
**Overall Status**: ✅ Pass / ❌ Fail / ⚠️ With Issues
