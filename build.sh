#!/bin/bash
# Build and package Signetics 2650 Ghidra processor definition (Flatpak Ghidra, sandbox-safe)

set -e

# --- CONFIGURATION ---
GHIDRA_FLATPAK_ID="org.ghidra_sre.Ghidra"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_NAME="Signetics2650"
LANG_DIR="$SCRIPT_DIR/ghidra_2650/data/languages"
SLA_FILE="$LANG_DIR/2650.sla"
DIST_DIR="$SCRIPT_DIR/dist"
PKG_ROOT="$SCRIPT_DIR/build/package"
ZIP_OUTPUT="$DIST_DIR/${MODULE_NAME}.zip"

# --- PREPARE OUTPUT DIR ---
mkdir -p "$DIST_DIR"

# --- BUILD (inside Flatpak sandbox) ---
echo "Compiling SLEIGH language inside Flatpak..."
if ! flatpak run --command=sh $GHIDRA_FLATPAK_ID -c "/app/lib/ghidra/support/sleigh $LANG_DIR/2650.slaspec"; then
  echo "[ERROR] SLEIGH compilation failed." >&2
  exit 1
fi

if [ ! -f "$SLA_FILE" ]; then
  echo "[ERROR] Compiled .sla file not found: $SLA_FILE." >&2
  exit 1
fi

# --- PACKAGE ZIP FOR GUI INSTALL ---
echo "Packaging GUI-installable extension zip..."
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/$MODULE_NAME/data/languages"
cp "$SLA_FILE"                        "$PKG_ROOT/$MODULE_NAME/data/languages/2650.sla"
cp "$LANG_DIR/2650.slaspec"           "$PKG_ROOT/$MODULE_NAME/data/languages/2650.slaspec"
cp "$LANG_DIR/2650.pspec"             "$PKG_ROOT/$MODULE_NAME/data/languages/2650.pspec"
cp "$LANG_DIR/2650.ldefs"             "$PKG_ROOT/$MODULE_NAME/data/languages/2650.ldefs"
cp "$LANG_DIR/2650.cspec"             "$PKG_ROOT/$MODULE_NAME/data/languages/2650.cspec"
cp "$SCRIPT_DIR/ghidra_2650/Module.manifest"      "$PKG_ROOT/$MODULE_NAME/Module.manifest"
cp "$SCRIPT_DIR/ghidra_2650/extension.properties" "$PKG_ROOT/$MODULE_NAME/extension.properties"

rm -f "$ZIP_OUTPUT"
if ! flatpak run --command=sh "$GHIDRA_FLATPAK_ID" -c "cd '$PKG_ROOT' && /usr/bin/zip -r '$ZIP_OUTPUT' '$MODULE_NAME' >/dev/null"; then
  echo "[ERROR] Failed to package extension zip." >&2
  exit 1
fi

echo "Extension zip created: $ZIP_OUTPUT"
