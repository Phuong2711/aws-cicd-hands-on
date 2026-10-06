#!/usr/bin/env bash
# Đóng gói code Lambda (chỉ source, KHÔNG kèm dependencies) -> build/function.zip
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_ZIP="$ROOT_DIR/build/function.zip"

mkdir -p "$ROOT_DIR/build"
rm -f "$OUT_ZIP"

(cd "$ROOT_DIR/src" && zip -qr "$OUT_ZIP" . -x "__pycache__/*" "*.pyc" "requirements.txt")

echo "Function built: $OUT_ZIP ($(du -h "$OUT_ZIP" | cut -f1))"
