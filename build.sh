#!/bin/bash
# Build and package the Signetics 2650 extension with a standard Ghidra-style release name.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GHIDRA_FLATPAK_ID="${GHIDRA_FLATPAK_ID:-org.ghidra_sre.Ghidra}"
GHIDRA_RELEASE_CHANNEL="${GHIDRA_RELEASE_CHANNEL:-PUBLIC}"
LANG_DIR="$SCRIPT_DIR/data/languages"
SLA_SPEC="$LANG_DIR/2650.slaspec"
SLA_FILE="$LANG_DIR/2650.sla"
BUILD_DIR="$SCRIPT_DIR/build"
PKG_ROOT="$BUILD_DIR/package"
DIST_DIR="$SCRIPT_DIR/dist"

read_property() {
  local key="$1"
  awk -F= -v key="$key" '$1 == key { print $2; exit }' "$SCRIPT_DIR/extension.properties"
}

MODULE_NAME="$(read_property name)"
GHIDRA_VERSION="$(read_property version)"
ZIP_OUTPUT="$DIST_DIR/ghidra_${GHIDRA_VERSION}_${GHIDRA_RELEASE_CHANNEL}_${MODULE_NAME}.zip"

compile_sla() {
  if command -v sleigh >/dev/null 2>&1; then
    echo "Compiling SLEIGH language with local Ghidra installation..."
    sleigh "$SLA_SPEC"
    return
  fi

  if command -v flatpak >/dev/null 2>&1; then
    echo "Compiling SLEIGH language inside Flatpak..."
    flatpak run --command=sh "$GHIDRA_FLATPAK_ID" -c "/app/lib/ghidra/support/sleigh '$SLA_SPEC'"
    return
  fi

  echo "[ERROR] Could not find 'sleigh' or a usable Flatpak Ghidra runtime." >&2
  exit 1
}

create_zip() {
  if command -v zip >/dev/null 2>&1; then
    (
      cd "$PKG_ROOT"
      zip -rq "$ZIP_OUTPUT" "$MODULE_NAME"
    )
    return
  fi

  if command -v flatpak >/dev/null 2>&1; then
    flatpak run --command=sh "$GHIDRA_FLATPAK_ID" -c "cd '$PKG_ROOT' && /usr/bin/zip -rq '$ZIP_OUTPUT' '$MODULE_NAME'"
    return
  fi

  echo "[ERROR] Could not find 'zip' or a usable Flatpak Ghidra runtime." >&2
  exit 1
}

mkdir -p "$DIST_DIR"
compile_sla

if [ ! -f "$SLA_FILE" ]; then
  echo "[ERROR] Compiled .sla file not found: $SLA_FILE" >&2
  exit 1
fi

echo "Packaging Ghidra extension archive..."
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/$MODULE_NAME"
cp -R "$SCRIPT_DIR/data" "$PKG_ROOT/$MODULE_NAME/"
cp "$SCRIPT_DIR/Module.manifest" "$PKG_ROOT/$MODULE_NAME/Module.manifest"
cp "$SCRIPT_DIR/extension.properties" "$PKG_ROOT/$MODULE_NAME/extension.properties"

rm -f "$ZIP_OUTPUT"
create_zip

echo "Extension zip created: $ZIP_OUTPUT"
