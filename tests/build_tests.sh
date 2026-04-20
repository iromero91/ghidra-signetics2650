#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TOOLS_DIR="$SCRIPT_DIR/_tools"
ASM2650="$TOOLS_DIR/asm2650"
ASM_URL="https://ztpe.nl/binaries/asm2650"

mkdir -p "$TOOLS_DIR"

if [ ! -f "$ASM2650" ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$ASM_URL" -o "$ASM2650"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$ASM2650" "$ASM_URL"
  else
    echo "[ERROR] Need curl or wget to download asm2650." >&2
    exit 1
  fi
fi

found=0

for src in "$SCRIPT_DIR"/*.2650; do
  if [ ! -f "$src" ]; then
    continue
  fi

  found=1
  base=${src%.2650}
  out_bin="$base.bin"
  out_lst="$base.lst"

  echo "[asm2650] $(basename "$src") -> $(basename "$out_bin")"

  python3 "$ASM2650" \
    --segments padded \
    --res 0xff \
    -W rel \
    -l "$out_lst" \
    -o "$out_bin" \
    "$src"

  wc -c "$out_bin"
done

if [ "$found" -eq 0 ]; then
  echo "[ERROR] No .2650 source files found in $SCRIPT_DIR" >&2
  exit 1
fi