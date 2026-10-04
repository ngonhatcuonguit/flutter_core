#!/bin/sh

set -eu

# Flutter 3.19 does not fully prepare App.framework metadata or copy the engine
# dSYM required by recent App Store validation. Keep normal simulator builds fast
# and apply these compatibility steps only to device builds/archives.
if [ "${PLATFORM_NAME:-}" != "iphoneos" ]; then
  exit 0
fi

app_framework_plist="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/App.framework/Info.plist"
deployment_target=${IPHONEOS_DEPLOYMENT_TARGET:-17.0}

if [ ! -f "$app_framework_plist" ]; then
  echo "error: App.framework Info.plist was not found at $app_framework_plist" >&2
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c "Set :MinimumOSVersion $deployment_target" "$app_framework_plist" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Add :MinimumOSVersion string $deployment_target" "$app_framework_plist"
fi

if [ "${ACTION:-}" != "install" ]; then
  exit 0
fi

flutter_binary="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/Flutter.framework/Flutter"
if [ ! -f "$flutter_binary" ]; then
  echo "error: Embedded Flutter framework was not found at $flutter_binary" >&2
  exit 1
fi

flutter_uuid=$(/usr/bin/xcrun dwarfdump --uuid "$flutter_binary" | /usr/bin/awk '/\(arm64\)/ { print $2; exit }')
if [ -z "$flutter_uuid" ]; then
  echo "error: Could not read the arm64 UUID from the embedded Flutter framework." >&2
  exit 1
fi

destination_dsym="${DWARF_DSYM_FOLDER_PATH}/Flutter.framework.dSYM"
destination_dwarf="$destination_dsym/Contents/Resources/DWARF/Flutter"

if [ -f "$destination_dwarf" ] && /usr/bin/xcrun dwarfdump --uuid "$destination_dwarf" | /usr/bin/grep -Fq "$flutter_uuid"; then
  exit 0
fi

flutter_root=${FLUTTER_ROOT:-}
engine_file="$flutter_root/bin/internal/engine.version"
if [ -z "$flutter_root" ] || [ ! -f "$engine_file" ]; then
  echo "error: FLUTTER_ROOT or its engine.version file is missing." >&2
  exit 1
fi

engine_revision=$(tr -d '[:space:]' < "$engine_file")
native_dsym="$flutter_root/bin/cache/artifacts/engine/ios-release/Flutter.xcframework/ios-arm64/dSYMs/Flutter.framework.dSYM"
cached_dsym="${SRCROOT}/../.dart_tool/flutter_engine_symbols/$engine_revision/Flutter.dSYM"

if [ -d "$native_dsym" ]; then
  source_dsym="$native_dsym"
else
  if [ ! -d "$cached_dsym" ]; then
    /bin/sh "${PROJECT_DIR}/scripts/download_flutter_dsym.sh"
  fi
  source_dsym="$cached_dsym"
fi

source_dwarf="$source_dsym/Contents/Resources/DWARF/Flutter"
if [ ! -f "$source_dwarf" ]; then
  echo "error: Flutter dSYM DWARF file was not found at $source_dwarf" >&2
  exit 1
fi

if ! /usr/bin/xcrun dwarfdump --uuid "$source_dwarf" | /usr/bin/grep -Fq "$flutter_uuid"; then
  echo "error: Flutter dSYM does not match embedded Flutter UUID $flutter_uuid." >&2
  exit 1
fi

mkdir -p "${DWARF_DSYM_FOLDER_PATH}"
/usr/bin/ditto "$source_dsym" "$destination_dsym"

if ! /usr/bin/xcrun dwarfdump --uuid "$destination_dwarf" | /usr/bin/grep -Fq "$flutter_uuid"; then
  echo "error: Copied Flutter dSYM failed UUID verification for $flutter_uuid." >&2
  exit 1
fi

echo "Prepared App.framework MinimumOSVersion=$deployment_target and Flutter dSYM UUID=$flutter_uuid"
