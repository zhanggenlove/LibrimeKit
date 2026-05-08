#!/usr/bin/env bash
# Strip non-iOS slices from each xcframework, then zip each one
# and emit a manifest with sha256 checksums for SwiftPM
# `binaryTarget(url:checksum:)`. Output:
#   /tmp/librimekit-release/stripped/<name>.xcframework  (rebuilt)
#   /tmp/librimekit-release/zips/<name>.xcframework.zip  (release asset)
#   /tmp/librimekit-release/manifest.txt                 (name + checksum + size)
#
# Inputs are read from the existing LibrimeKit working tree.

set -euo pipefail

# Resolve repo root from this script's location so the script
# works from any clone (not hardcoded to one machine).
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

# Override any of these via env var if you want a different
# input/output layout. Defaults match the README workflow:
# drop xcframeworks into ./Frameworks, run script, find zips
# under /tmp/librimekit-release/zips/.
SRC="${SRC_FRAMEWORKS:-$REPO_ROOT/Frameworks}"
OUT_STRIPPED="${OUT_STRIPPED:-/tmp/librimekit-release/stripped}"
OUT_ZIPS="${OUT_ZIPS:-/tmp/librimekit-release/zips}"
MANIFEST="${MANIFEST:-/tmp/librimekit-release/manifest.txt}"

if [[ ! -d "$SRC" ]]; then
    echo "Error: source directory not found: $SRC" >&2
    echo "Drop the 9 xcframeworks into $REPO_ROOT/Frameworks/" >&2
    echo "or set SRC_FRAMEWORKS to point elsewhere." >&2
    exit 1
fi

rm -rf "$OUT_STRIPPED" "$OUT_ZIPS" "$MANIFEST"
mkdir -p "$OUT_STRIPPED" "$OUT_ZIPS"
: > "$MANIFEST"

for fw in "$SRC"/*.xcframework; do
    name=$(basename "$fw" .xcframework)
    out_xcf="$OUT_STRIPPED/$name.xcframework"
    out_zip="$OUT_ZIPS/$name.xcframework.zip"

    # Find the .a (static lib) inside each iOS slice. Library
    # files have varying names — librime uses suffix-based names
    # (librime-arm64.a / librime-simulator.a) while boost uses
    # the same name in both slices (libboost_atomic.a).
    device_a=$(ls "$fw/ios-arm64/"*.a 2>/dev/null | head -1)
    sim_a=$(ls "$fw/ios-arm64-simulator/"*.a 2>/dev/null | head -1)

    if [[ -z "$device_a" || -z "$sim_a" ]]; then
        echo "[$name] missing ios-arm64 or ios-arm64-simulator slice; skipping" >&2
        exit 1
    fi

    # If the device slice has a Headers/ directory (currently only
    # librime does), pass it through. xcodebuild -create-xcframework
    # only accepts -headers when -library is used.
    extra_args=()
    if [[ -d "$fw/ios-arm64/Headers" ]]; then
        extra_args+=(-headers "$fw/ios-arm64/Headers")
    fi

    echo "[$name] rebuilding xcframework (ios-arm64 + ios-arm64-simulator only)"
    xcodebuild -create-xcframework \
        -library "$device_a" "${extra_args[@]}" \
        -library "$sim_a" \
        -output "$out_xcf" >/dev/null

    # Zip with -X to suppress extra attributes that change every
    # invocation; -r recurse, -y store symlinks not copies.
    echo "[$name] zipping"
    (cd "$OUT_STRIPPED" && zip -qry -X "$out_zip" "$name.xcframework")

    # SwiftPM-canonical sha256: `swift package compute-checksum`
    # is the supported way (matches what the package manager
    # validates against on resolve).
    checksum=$(swift package compute-checksum "$out_zip")
    size=$(stat -f%z "$out_zip")
    printf "%s\t%s\t%s\n" "$name" "$checksum" "$size" >>"$MANIFEST"
    echo "[$name] sha256=$checksum size=$size"
done

echo
echo "Manifest written to $MANIFEST:"
cat "$MANIFEST"
