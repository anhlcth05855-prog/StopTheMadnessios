#!/bin/bash
set -e

echo "=== Đang bắt đầu đóng gói StopTheMadness Pro sang file IPA ==="

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_IPA="$PROJECT_DIR/StopTheMadnessPro.ipa"

echo "[1/4] Dọn dẹp thư mục build cũ..."
rm -rf "$BUILD_DIR"
rm -rf "$PROJECT_DIR/Payload"
rm -f "$OUTPUT_IPA"

echo "[2/4] Biên dịch dự án bằng xcodebuild cho iOS Device (arm64)..."
xcodebuild clean build \
    -project "$PROJECT_DIR/StopTheMadnessPro.xcodeproj" \
    -scheme "StopTheMadnessPro" \
    -configuration Release \
    -sdk iphoneos \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY=""

APP_PATH="$BUILD_DIR/Build/Products/Release-iphoneos/StopTheMadnessPro.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Lỗi: Không tìm thấy file $APP_PATH sau khi build!"
    exit 1
fi

echo "[3/4] Cấu trúc thư mục Payload của IPA..."
mkdir -p "$PROJECT_DIR/Payload"
cp -r "$APP_PATH" "$PROJECT_DIR/Payload/"

echo "[4/4] Nén thành file StopTheMadnessPro.ipa..."
cd "$PROJECT_DIR"
zip -qry "$OUTPUT_IPA" Payload

rm -rf "$PROJECT_DIR/Payload"
echo "=== HOÀN TẤT! File IPA đã được tạo thành công tại: $OUTPUT_IPA ==="
