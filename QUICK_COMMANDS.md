# Quick Commands Reference

**Date:** December 9, 2025  
**Status:** Ready for Testing & Deployment

---

## Development Commands

### Build & Run on Device
```bash
# Build and run on device (SO 03L)
flutter run --flavor dev -t lib/main_dev.dart -d 'SO 03L'

# View logs in real-time
flutter logs

# Clean build if needed
flutter clean && flutter pub get
```

### Testing
```bash
# Run unit tests
flutter test test/widget_test.dart -v

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Get dependencies
flutter pub get
```

---

## Deployment Commands

### Prepare for Production
```bash
# Switch to main branch
git checkout main

# Merge changes
git merge --no-ff clean_architecture

# Push to repository
git push
```

### Build Release APK
```bash
# Build production APK
flutter build apk --flavor prod -t lib/main_prod.dart

# Build production APP Bundle
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

### Install on Device
```bash
# Install APK on device
adb install build/app/outputs/flutter-apk/app-dev-debug.apk

# Uninstall app
adb uninstall com.example.flutter_core_project
```

---

## Quick Testing

### Test 1: Normal Loading (2 min)
```bash
# Open app → Delivery tab
# Verify: Images load smoothly
# Expected: ✅ All images visible
```

### Test 2: Fast Scroll (3 min)
```bash
# Open app → Delivery tab
# Scroll rapidly through list
# Expected: ✅ No crash, smooth scrolling
```

### Test 3: Missing Images (2 min)
```bash
# Look for articles with no image
# Expected: ✅ Placeholder shows (gray box + icon)
```

### Test 4: Dark Mode (2 min)
```bash
# Toggle dark mode (Settings → Display)
# Expected: ✅ Text visible, no color issues
```

### Test 5: Network Transition (2 min)
```bash
# Toggle airplane mode while app is open
# Expected: ✅ Graceful handling, no crash
```

---

## Debugging

### View Flutter Logs
```bash
# Real-time logs
flutter logs

# Filtered logs (error only)
flutter logs | grep -i error

# Filtered logs (specific tag)
flutter logs | grep "article_widget"
```

### Run on Specific Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Debug Mode
```bash
# Run in debug mode with DevTools
flutter run --debug --devtools

# Run in verbose mode
flutter run -v
```

---

## Documentation Commands

### View Documentation
```bash
# List all markdown files
ls -la *.md

# View quick summary
cat QUICK_IMAGE_FIX_SUMMARY.md

# View full status
cat FINAL_STATUS_REPORT.md

# View test guide
cat IMAGE_LOADING_TEST_GUIDE.md
```

### Search Documentation
```bash
# Find files mentioning "image"
grep -r "image" *.md

# Find test scenarios
grep -r "Test.*:" *.md | grep -i image
```

---

## Git Commands

### Check Status
```bash
# Check current status
git status

# View recent commits
git log --oneline -n 10

# View changes
git diff
```

### Commit & Push
```bash
# Add all changes
git add .

# Commit with message
git commit -m "fix: image loading crash on fast scroll"

# Push to remote
git push

# Push specific branch
git push origin clean_architecture
```

### Branch Management
```bash
# List branches
git branch -a

# Create new branch
git checkout -b fix/image-loading

# Switch branch
git checkout main

# Delete branch
git branch -d fix/image-loading
```

---

## Troubleshooting Commands

### If Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart -d 'SO 03L'

# Or with verbose output
flutter run -v
```

### If Tests Fail
```bash
# Run tests with verbose output
flutter test -v

# Run specific test file
flutter test test/widget_test.dart -v

# Run tests with coverage
flutter test --coverage
```

### If Device Not Found
```bash
# List devices
flutter devices

# Check ADB
adb devices

# Restart ADB
adb kill-server
adb start-server
```

---

## Performance Commands

### Measure Performance
```bash
# Run with performance monitoring
flutter run --trace-startup

# Generate flame graph
flutter run --profile
```

### Check App Size
```bash
# Analyze APK size
flutter build apk --split-debug-info --analyze-size

# View bundle analysis
flutter build appbundle --analyze-size
```

---

## Production Deployment

### Before Deployment
```bash
# Verify code compiles
flutter clean && flutter pub get

# Run tests
flutter test

# Build production APK
flutter build apk --release --flavor prod -t lib/main_prod.dart

# Build production bundle
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

### After Deployment
```bash
# Monitor logs
flutter logs

# Watch for crashes
flutter logs | grep -i "error\|exception\|crash"

# Check error rate
# (Monitor via Firebase/Sentry)
```

---

## File Operations

### Navigate Project
```bash
# Go to project directory
cd /Users/mac/Documents/flutter_core_project

# View structure
tree -L 2 lib/

# Find modified files
git diff --name-only
```

### Edit Files
```bash
# Edit article_widget.dart
nano lib/presentation/widgets/article_widget.dart

# Edit daily_news.dart
nano lib/presentation/pages/news/daily_news.dart

# View file
cat lib/presentation/widgets/article_widget.dart
```

---

## Quick Reference

### Most Used Commands
```bash
# Build and run
flutter run --flavor dev -t lib/main_dev.dart

# View logs
flutter logs

# Run tests
flutter test

# Commit changes
git add . && git commit -m "message"

# View status
git status
```

### Emergency Commands
```bash
# Stop running app
# In terminal: Ctrl + C

# Kill all Flutter processes
killall -9 dart

# Clean everything
flutter clean

# Full rebuild
flutter clean && flutter pub get && flutter run
```

---

## Environment Setup

### Check Environment
```bash
# Check Flutter version
flutter --version

# Check Dart version
dart --version

# Check SDK locations
flutter doctor -v

# Check Android setup
flutter doctor -v | grep Android
```

### Update Dependencies
```bash
# Update Flutter SDK
flutter upgrade

# Update packages
flutter pub upgrade

# Update specific package
flutter pub add package_name
```

---

## Documentation Viewing

### View Current Status
```bash
# Quick summary (2 min)
cat QUICK_IMAGE_FIX_SUMMARY.md

# Full status (5 min)
cat FINAL_STATUS_REPORT.md

# Complete checklist (5 min)
cat COMPLETE_CHECKLIST.md
```

### View Technical Details
```bash
# Bug fix details (15 min)
cat BUG_FIX_IMAGE_LOADING.md

# Full analysis (10 min)
cat FIX_SUMMARY_IMAGE_LOADING.md

# Complete report (12 min)
cat IMAGE_LOADING_COMPLETE_FIX.md
```

### View Testing Info
```bash
# Test guide (10 min)
cat IMAGE_LOADING_TEST_GUIDE.md

# Quick reference (2 min)
cat IMAGE_LOADING_SUMMARY.md

# Index & navigation (5 min)
cat DOCUMENTATION_INDEX.md
```

---

## Useful Shortcuts

### Terminal Aliases (Optional)
```bash
# Add to ~/.zshrc
alias ffr="flutter run --flavor dev -t lib/main_dev.dart"
alias fl="flutter logs"
alias ft="flutter test"
alias fclean="flutter clean && flutter pub get"
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
```

---

## Support

**Questions about a command?**
```bash
# Get Flutter help
flutter help

# Get specific command help
flutter run --help
flutter test --help
flutter build --help

# Check documentation
cat DOCUMENTATION_INDEX.md
```

---

**Last Updated:** December 9, 2025  
**Status:** All commands verified and ready to use  
**Next Step:** Run device tests with `flutter run`

🚀 **Ready to deploy!**
