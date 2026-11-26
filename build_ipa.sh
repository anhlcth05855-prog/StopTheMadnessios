#!/bin/bash
set -e

echo "=== Đang bắt đầu đóng gói StopTheMadness Pro sang file IPA ==="

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_IPA="$PROJECT_DIR/StopTheMadnessPro.ipa"

echo "[1/5] Dọn dẹp thư mục build cũ..."
rm -rf "$BUILD_DIR"
rm -rf "$PROJECT_DIR/Payload"
rm -f "$OUTPUT_IPA"

echo "[2/5] Biên dịch Main App bằng xcodebuild cho iOS Device (arm64)..."
xcodebuild clean build \
    -project "$PROJECT_DIR/StopTheMadnessPro.xcodeproj" \
    -scheme "StopTheMadnessPro" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER=""

echo "[3/5] Biên dịch Safari Web Extension bằng xcodebuild..."
xcodebuild build \
    -project "$PROJECT_DIR/StopTheMadnessPro.xcodeproj" \
    -scheme "StopTheMadnessExtension" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER="" || true

APP_PATH="$BUILD_DIR/Build/Products/Release-iphoneos/StopTheMadnessPro.app"
EXTENSION_PATH="$BUILD_DIR/Build/Products/Release-iphoneos/StopTheMadnessExtension.appex"

if [ ! -d "$APP_PATH" ]; then
    echo "Lỗi: Không tìm thấy file $APP_PATH sau khi build!"
    exit 1
fi

echo "[4/5] Cấu trúc thư mục Payload và nhúng Safari Web Extension..."
mkdir -p "$PROJECT_DIR/Payload"
cp -r "$APP_PATH" "$PROJECT_DIR/Payload/"
mkdir -p "$PROJECT_DIR/Payload/StopTheMadnessPro.app/PlugIns"

if [ -d "$EXTENSION_PATH" ]; then
    cp -r "$EXTENSION_PATH" "$PROJECT_DIR/Payload/StopTheMadnessPro.app/PlugIns/"
fi

if [ -f "$PROJECT_DIR/iTunesMetadata.plist" ]; then
    cp "$PROJECT_DIR/iTunesMetadata.plist" "$PROJECT_DIR/Payload/"
fi

echo "[5/5] Nén thành file StopTheMadnessPro.ipa..."
cd "$PROJECT_DIR"
zip -qry "$OUTPUT_IPA" Payload iTunesMetadata.plist

rm -rf "$PROJECT_DIR/Payload"
echo "=== HOÀN TẤT! File IPA đã được tạo thành công tại: $OUTPUT_IPA ==="
