name: Build iOS IPA

on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Select Xcode 16
        run: sudo xcode-select -s /Applications/Xcode_16.4.app

      - name: Build and Archive
        run: |
          xcodebuild archive \
            -scheme "TinPlayer" \
            -destination "generic/platform=iOS" \
            -sdk iphoneos \
            -configuration Release \
            -archivePath ./TinPlayer.xcarchive \
            SKIP_INSTALL=NO \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO

      - name: Export IPA (Force App Structure)
        run: |
          # 创建标准的 .app 目录结构
          mkdir -p Payload/TinPlayer.app
          
          # 1. 查找二进制文件（根据你之前的日志，它在 usr/local/bin）
          BIN_PATH=$(find ./TinPlayer.xcarchive/Products -type f -name "TinPlayer" | head -n 1)
          echo "找到二进制文件: $BIN_PATH"
          
          if [ -n "$BIN_PATH" ]; then
            cp "$BIN_PATH" Payload/TinPlayer.app/
            chmod +x Payload/TinPlayer.app/TinPlayer
          else
            echo "❌ 错误：依然找不到二进制文件"
            find ./TinPlayer.xcarchive
            exit 1
          fi
          
          # 2. 尝试从 archive 中找 Info.plist
          PLIST_PATH=$(find ./TinPlayer.xcarchive -name "Info.plist" | head -n 1)
          if [ -n "$PLIST_PATH" ]; then
            cp "$PLIST_PATH" Payload/TinPlayer.app/
          fi

          # 3. 查找并拷贝资源文件（Assets.car 等）
          find ./TinPlayer.xcarchive/Products -name "*.car" -exec cp {} Payload/TinPlayer.app/ \;
          find ./TinPlayer.xcarchive/Products -name "*.png" -exec cp {} Payload/TinPlayer.app/ \;

          # 打包 IPA
          zip -qr TinPlayer.ipa Payload
          
          echo "=== IPA 最终大小 ==="
          ls -lh TinPlayer.ipa

      - name: Upload IPA Artifact
        uses: actions/upload-artifact@v4
        with:
          name: TinPlayer-IPA
          path: TinPlayer.ipa
