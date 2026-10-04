#!/bin/sh

set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
project_root=$(CDPATH= cd "$script_dir/../.." && pwd)

flutter_root=${FLUTTER_ROOT:-}
if [ -z "$flutter_root" ] && [ -d "$project_root/.fvm/flutter_sdk" ]; then
  flutter_root="$project_root/.fvm/flutter_sdk"
fi

engine_file="$flutter_root/bin/internal/engine.version"
if [ -z "$flutter_root" ] || [ ! -f "$engine_file" ]; then
  echo "error: Cannot determine Flutter engine revision. Set FLUTTER_ROOT or run FVM first." >&2
  exit 1
fi

engine_revision=$(tr -d '[:space:]' < "$engine_file")
cache_dir="$project_root/.dart_tool/flutter_engine_symbols/$engine_revision"
cached_dsym="$cache_dir/Flutter.dSYM"
cached_dwarf="$cached_dsym/Contents/Resources/DWARF/Flutter"

if [ -f "$cached_dwarf" ]; then
  exit 0
fi

mkdir -p "$cache_dir"
temporary_dir=$(mktemp -d "$cache_dir/download.XXXXXX")
trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM

archive_url="https://storage.googleapis.com/flutter_infra_release/flutter/$engine_revision/ios-release/Flutter.dSYM.zip"
archive_path="$temporary_dir/Flutter.dSYM.zip"
extract_dir="$temporary_dir/extracted"

echo "Downloading Flutter engine dSYM for $engine_revision..."
/usr/bin/curl \
  --fail \
  --location \
  --retry 3 \
  --show-error \
  --silent \
  --output "$archive_path" \
  "$archive_url"

mkdir -p "$extract_dir"
/usr/bin/ditto -x -k "$archive_path" "$extract_dir"
downloaded_dsym=$(/usr/bin/find "$extract_dir" -type d -name Flutter.dSYM -print -quit)

if [ -z "$downloaded_dsym" ] || [ ! -f "$downloaded_dsym/Contents/Resources/DWARF/Flutter" ]; then
  echo "error: The Flutter dSYM archive did not contain a valid Flutter.dSYM bundle." >&2
  exit 1
fi

/usr/bin/ditto "$downloaded_dsym" "$cached_dsym"
echo "Cached Flutter engine dSYM at $cached_dsym"
