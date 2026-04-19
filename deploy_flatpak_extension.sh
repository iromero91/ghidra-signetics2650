#!/usr/bin/env bash
set -euo pipefail

# Deploy the local Signetics2650 extension files into Flatpak Ghidra user extensions.
# Run this from anywhere after a successful ./build.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR"

EXT_NAME="${EXT_NAME:-Signetics2650}"
FLATPAK_GHIDRA_INSTANCE="${FLATPAK_GHIDRA_INSTANCE:-ghidra_12.0.4_FLATPAK}"
FLATPAK_GHIDRA_CONFIG="${FLATPAK_GHIDRA_CONFIG:-$HOME/.var/app/org.ghidra_sre.Ghidra/config/ghidra}"

DST_DIR_DEFAULT="$FLATPAK_GHIDRA_CONFIG/$FLATPAK_GHIDRA_INSTANCE/Extensions/$EXT_NAME"
DST_DIR="$DST_DIR_DEFAULT"
CLEAR_CACHE=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --dst <path>         Override destination extension directory.
  --no-cache-clear     Do not clear OSGi caches after copying.
  -h, --help           Show this help.

Environment overrides:
  EXT_NAME
  FLATPAK_GHIDRA_INSTANCE
  FLATPAK_GHIDRA_CONFIG
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dst)
      DST_DIR="$2"
      shift 2
      ;;
    --no-cache-clear)
      CLEAR_CACHE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for f in \
  "$SRC_DIR/extension.properties" \
  "$SRC_DIR/Module.manifest" \
  "$SRC_DIR/data/languages/2650.sla" \
  "$SRC_DIR/data/languages/2650.slaspec" \
  "$SRC_DIR/data/languages/2650.pspec" \
  "$SRC_DIR/data/languages/2650.cspec" \
  "$SRC_DIR/data/languages/2650.ldefs"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing expected source file: $f" >&2
    exit 1
  fi
done

mkdir -p "$DST_DIR/data/languages"

cp "$SRC_DIR/extension.properties" "$DST_DIR/extension.properties"
cp "$SRC_DIR/Module.manifest" "$DST_DIR/Module.manifest"
cp "$SRC_DIR/data/languages/2650.sla" "$DST_DIR/data/languages/2650.sla"
cp "$SRC_DIR/data/languages/2650.slaspec" "$DST_DIR/data/languages/2650.slaspec"
cp "$SRC_DIR/data/languages/2650.pspec" "$DST_DIR/data/languages/2650.pspec"
cp "$SRC_DIR/data/languages/2650.cspec" "$DST_DIR/data/languages/2650.cspec"
cp "$SRC_DIR/data/languages/2650.ldefs" "$DST_DIR/data/languages/2650.ldefs"

if [[ "$CLEAR_CACHE" -eq 1 ]]; then
  rm -rf \
    "$FLATPAK_GHIDRA_CONFIG/$FLATPAK_GHIDRA_INSTANCE/osgi/felixcache" \
    "$FLATPAK_GHIDRA_CONFIG/$FLATPAK_GHIDRA_INSTANCE/osgi/compiled-bundles"
fi

echo "Deployed to: $DST_DIR"
if [[ "$CLEAR_CACHE" -eq 1 ]]; then
  echo "OSGi caches cleared"
fi
