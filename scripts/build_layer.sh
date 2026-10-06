#!/usr/bin/env bash
# Build Lambda Layer từ src/requirements.txt -> build/layer.zip
#
# Cấu trúc bắt buộc của Python layer:
#   layer.zip
#   └── python/
#       ├── requests/
#       ├── urllib3/
#       └── ...
# Lambda sẽ tự thêm /opt/python vào PYTHONPATH khi runtime khởi động.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
BUILD_DIR="$ROOT_DIR/build/layer"
OUT_ZIP="$ROOT_DIR/build/layer.zip"

rm -rf "$BUILD_DIR" "$OUT_ZIP"
mkdir -p "$BUILD_DIR/python"

# --platform / --only-binary: ép pip tải wheel cho Linux x86_64 (môi trường Lambda),
# thay vì wheel của máy build (macOS/Ubuntu). Rất quan trọng với thư viện có native code.
pip install \
  --requirement "$ROOT_DIR/src/requirements.txt" \
  --target "$BUILD_DIR/python" \
  --platform manylinux2014_x86_64 \
  --implementation cp \
  --python-version "$PYTHON_VERSION" \
  --only-binary=:all: \
  --upgrade

# Dọn rác để layer nhỏ hơn
find "$BUILD_DIR/python" -type d -name "__pycache__" -prune -exec rm -rf {} +
find "$BUILD_DIR/python" -type d -name "*.dist-info" -exec rm -rf {}/RECORD \; 2>/dev/null || true

(cd "$BUILD_DIR" && zip -qr "$OUT_ZIP" python)

echo "Layer built: $OUT_ZIP ($(du -h "$OUT_ZIP" | cut -f1))"
