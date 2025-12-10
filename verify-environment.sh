#!/bin/bash

# Environment Verification Script
# Run this script to verify your environment matches the working setup
# Usage: bash verify-environment.sh

echo "======================================================================"
echo "🔍 FLUTTER CORE PROJECT - Environment Verification"
echo "======================================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Expected versions
EXPECTED_FLUTTER="3.13.8"
EXPECTED_DART="3.1.4"
EXPECTED_JAVA="18.0.2"
EXPECTED_NODE="20.19.4"
EXPECTED_COCOAPODS="1.15.2"
EXPECTED_XCODE="14.1"

errors=0
warnings=0

# Function to check version
check_version() {
    local tool=$1
    local actual=$2
    local expected=$3
    
    if [ "$actual" == "$expected" ]; then
        echo -e "${GREEN}✓${NC} $tool: $actual (OK)"
    else
        echo -e "${RED}✗${NC} $tool: $actual (Expected: $expected)"
        ((errors++))
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "📋 Checking Flutter & Dart..."
echo "----------------------------------------------------------------------"

# Check Flutter
if command_exists flutter; then
    FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
    check_version "Flutter" "$FLUTTER_VERSION" "$EXPECTED_FLUTTER"
    
    DART_VERSION=$(flutter --version | grep "Dart" | awk '{print $4}')
    check_version "Dart" "$DART_VERSION" "$EXPECTED_DART"
else
    echo -e "${RED}✗${NC} Flutter not found"
    ((errors++))
fi

echo ""
echo "☕ Checking Java..."
echo "----------------------------------------------------------------------"

# Check Java
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | grep "version" | awk -F '"' '{print $2}')
    check_version "Java" "$JAVA_VERSION" "$EXPECTED_JAVA"
else
    echo -e "${RED}✗${NC} Java not found"
    ((errors++))
fi

echo ""
echo "🤖 Checking Android SDK..."
echo "----------------------------------------------------------------------"

# Check ANDROID_HOME
if [ -n "$ANDROID_HOME" ]; then
    echo -e "${GREEN}✓${NC} ANDROID_HOME: $ANDROID_HOME"
    
    # Check Android SDK build tools
    if [ -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
        echo -e "${GREEN}✓${NC} Build Tools 34.0.0: Installed"
    else
        echo -e "${RED}✗${NC} Build Tools 34.0.0: Not found"
        ((errors++))
    fi
    
    # Check Android platform 34
    if [ -d "$ANDROID_HOME/platforms/android-34" ]; then
        echo -e "${GREEN}✓${NC} Android Platform 34: Installed"
    else
        echo -e "${RED}✗${NC} Android Platform 34: Not found"
        ((errors++))
    fi
else
    echo -e "${RED}✗${NC} ANDROID_HOME not set"
    ((errors++))
fi

echo ""
echo "🍎 Checking Xcode (macOS only)..."
echo "----------------------------------------------------------------------"

# Check Xcode (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command_exists xcodebuild; then
        XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | awk '{print $2}')
        check_version "Xcode" "$XCODE_VERSION" "$EXPECTED_XCODE"
    else
        echo -e "${YELLOW}⚠${NC} Xcode not found (optional for iOS development)"
        ((warnings++))
    fi
    
    # Check CocoaPods
    if command_exists pod; then
        POD_VERSION=$(pod --version)
        check_version "CocoaPods" "$POD_VERSION" "$EXPECTED_COCOAPODS"
    else
        echo -e "${YELLOW}⚠${NC} CocoaPods not found (optional for iOS development)"
        ((warnings++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Not running on macOS - iOS development not available"
fi

echo ""
echo "🌐 Checking Node.js (optional)..."
echo "----------------------------------------------------------------------"

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version | sed 's/v//')
    check_version "Node.js" "$NODE_VERSION" "$EXPECTED_NODE"
else
    echo -e "${YELLOW}⚠${NC} Node.js not found (optional for web development)"
    ((warnings++))
fi

echo ""
echo "🔧 Checking Environment Variables..."
echo "----------------------------------------------------------------------"

# Check JAVA_HOME
if [ -n "$JAVA_HOME" ]; then
    echo -e "${GREEN}✓${NC} JAVA_HOME: $JAVA_HOME"
else
    echo -e "${RED}✗${NC} JAVA_HOME not set"
    ((errors++))
fi

# Check Flutter in PATH
if echo "$PATH" | grep -q "flutter/bin"; then
    echo -e "${GREEN}✓${NC} Flutter in PATH"
else
    echo -e "${RED}✗${NC} Flutter not in PATH"
    ((errors++))
fi

echo ""
echo "📦 Checking Project Dependencies..."
echo "----------------------------------------------------------------------"

# Check if in project directory
if [ -f "pubspec.yaml" ]; then
    echo -e "${GREEN}✓${NC} pubspec.yaml found"
    
    # Check if dependencies are installed
    if [ -d ".dart_tool" ]; then
        echo -e "${GREEN}✓${NC} Dependencies installed"
    else
        echo -e "${YELLOW}⚠${NC} Dependencies not installed. Run: flutter pub get"
        ((warnings++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Not in project directory"
fi

echo ""
echo "======================================================================"
echo "📊 VERIFICATION SUMMARY"
echo "======================================================================"

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✓ Perfect!${NC} Your environment matches the working setup!"
    echo ""
    echo "You can now build and run the project:"
    echo "  flutter run --flavor dev -t lib/main_dev.dart"
    exit 0
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}⚠ Warnings: $warnings${NC}"
    echo ""
    echo "Your environment is mostly correct, but some optional tools are missing."
    echo "You should be able to build and run the project for most platforms."
    exit 0
else
    echo -e "${RED}✗ Errors: $errors${NC}"
    echo -e "${YELLOW}⚠ Warnings: $warnings${NC}"
    echo ""
    echo "Please fix the errors above before building the project."
    echo "Refer to ENVIRONMENT_CONFIG.md for detailed installation instructions."
    exit 1
fi
