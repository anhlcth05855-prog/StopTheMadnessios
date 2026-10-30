# StopTheMadness Pro for iOS (Swift & SwiftUI)

Ứng dụng **StopTheMadness Pro** cho iOS & iPadOS – trình duyệt web thông minh và tiện ích mở rộng Safari Web Extension chuyên lấy lại toàn bộ quyền kiểm soát duyệt web, loại bỏ các thủ thuật gây ức chế của trang web, dọn sạch URL theo dõi và tối ưu hóa trải nghiệm duyệt web di động.

- **GitLab iOS:** [https://gitlab.com/sondeptrai/stopthemadness_ios](https://gitlab.com/sondeptrai/stopthemadness_ios)
- **App Store Reference:** [StopTheMadness Pro on App Store](https://apps.apple.com/us/app/stopthemadness-pro/id6471380298?l=vi)
- **Bản Android tương ứng:** [StopTheMadness Pro Android (Kotlin)](https://gitlab.com/sondeptrai/stopthemadness_android)

---

## 🚀 Tính năng chính

### 1. 🛡️ Khôi phục quyền tương tác web (Interaction Restoration)
- **Cho phép bôi đen & sao chép văn bản:** Gỡ bỏ hoàn toàn thuộc tính hạn chế `-webkit-user-select: none` và `user-select: none`. Chặn trang web vô hiệu hóa các sự kiện `selectstart`, `selectionchange`, `copy`, `cut`.
- **Chống ghi đè Clipboard:** Bảo vệ bộ nhớ tạm (clipboard), ngăn các trang web bí mật chèn link tracking/tiếp thị liên kết vào văn bản đã copy qua `navigator.clipboard.writeText`.
- **Khôi phục Menu chuột phải & Chạm giữ:** Cho phép hiển thị native context menu và bôi đen từ khóa trên mọi trang web.
- **Mở khóa thu phóng (Pinch-to-zoom):** Tự động phát hiện và sửa thẻ `<meta name="viewport">` bị khóa (`user-scalable=no`, `maximum-scale=1`, `user-scalable=0`) thành `user-scalable=yes` với tỷ lệ phóng lên đến 5.0x.
- **Khôi phục cuộn trang:** Tự động sửa lỗi các trang web cố tình khóa cuộn bằng `overflow: hidden` hoặc chặn cảm ứng touch-action.

### 2. 🧹 Chặn theo dõi & Dọn sạch URL (Tracking Protection & URL Sanitizer)
- **Tự động xóa tham số theo dõi (Tracking Parameters):** Xóa sạch `utm_source`, `utm_medium`, `utm_campaign`, `fbclid`, `gclid`, `gbraid`, `wbraid`, `msclkid`, `igshid`, `si`, `_ga`, `_gl` khỏi mọi liên kết và thanh địa chỉ trước khi tải.
- **Bỏ qua Google AMP (AMP Bypasser):** Tự động nhận diện URL Google AMP (`google.com/amp/...`) và CDN AMP (`*.ampproject.org/c/...`), trích xuất và chuyển hướng trực tiếp đến trang web canonical chính thức của nhà xuất bản.
- **Vượt qua trình rút gọn liên kết (Link Unshortener):** Tự động gửi `HEAD` request và giải mã đích đến thực sự của các liên kết `bit.ly`, `t.co`, `tinyurl.com`, `is.gd` trước khi mở.
- **Giải mã redirect wrapper:** Gỡ bỏ lớp bọc link chuyển hướng theo dõi của Google (`google.com/url?q=...`), Facebook (`l.php?u=...`), Reddit (`out.reddit.com?url=...`).

### 3. 🎬 Kiểm soát Video & Âm thanh (Media Control)
- **Chặn Autoplay:** Tự động chặn các video/audio tự động phát khi chưa có sự cho phép hay tương tác trực tiếp của người dùng (`HTMLMediaElement.prototype.play` interception & WebKit media playback policy).
- **Buộc hiển thị bảng điều khiển gốc:** Đảm bảo thanh điều khiển video gốc (play, pause, seek, volume, PiP) luôn hiển thị đầy đủ và không bị che khuất bởi các overlay trong suốt.
- **Hỗ trợ Picture-in-Picture (PiP):** Thu nhỏ video nổi trên màn hình iOS với `AVPictureInPictureController`.
- **Ngăn tắt âm thanh khi ẩn tab / chạy ngầm:** Hỗ trợ `AVAudioSessionCategoryPlayback` kết hợp bảo vệ `document.visibilityState` và `document.hidden`, cho phép tiếp tục nghe nhạc/podcast khi chuyển tab hoặc khóa màn hình.

### 4. 🚫 Loại bỏ các thông báo làm phiền (Annoyance Removal)
- **Ẩn banner ép cài ứng dụng di động:** Tự động ẩn Smart App Banners trên Google, Reddit ("Get the Reddit app"), Quora ("Open in App"), LinkedIn, v.v.
- **Chặn thông báo web push:** Tự động từ chối các cửa sổ popup phiền toái xin cấp quyền Web Notification (`Notification.requestPermission`).
- **Chặn Google One Tap:** Tự động ẩn các popup đăng nhập "Sign in with Google" che khuất màn hình (`#credential_picker_container`, iframe smartlock/gsi).

### 5. ⚙️ Tùy biến nâng cao cho trình duyệt (Advanced Customization)
- **Chỉnh sửa URL trong cửa sổ lớn (Large URL Editor):** Chạm vào thanh địa chỉ để mở hộp thoại lớn, phân tích chi tiết từng query parameter, xem trước tham số tracker bị loại bỏ, nút "Dọn sạch URL", "Sao chép URL sạch", "Truy cập" và "Mở trong tab mới".
- **Tùy chỉnh CSS & JavaScript riêng:** Hỗ trợ nhập và chèn CSS / JS tùy chỉnh cho từng tên miền cụ thể hoặc toàn cầu (`*`).
- **Quản lý đa thẻ (Multi-tab browsing):** Chuyển đổi thẻ dễ dàng dạng lưới (Grid View), xem số lượng thẻ và quản lý danh sách thẻ mở.
- **Bảng điều khiển lá chắn (Shield Sheet):** Hiển thị số liệu thời gian thực (trackers đã xóa, AMP đã bỏ qua, autoplay đã chặn, thông báo đã chặn) và các công tắc bật/tắt tức thì theo từng tên miền.
- **Safari Web Extension Target:** Cung cấp extension chuẩn Safari Manifest V3, chia sẻ logic chặn quảng cáo/tracker trực tiếp vào trình duyệt Safari mặc định của iOS.

---

## 🛠️ Công nghệ & Kiến trúc

- **Ngôn ngữ:** Swift 5.9+ / Swift 6 ready (100% Native)
- **Nền tảng:** iOS 16.0+ / iPadOS 16.0+
- **Giao diện người dùng:** SwiftUI hiện đại kết hợp WebKit
- **Trình duyệt lõi:**
  - `WKWebView`, `WKUserContentController`, `WKUserScript`, `WKScriptMessageHandler`
  - Giao tiếp Native Bridge hai chiều (`StopTheMadnessBridge`)
  - `AVPictureInPictureController`, `AVAudioSession`
- **Safari Extension:** Safari Web Extension Manifest V3 (`SafariWebExtensionHandler.swift`)
- **Quản lý trạng thái:** MVVM với Combine (`ObservableObject`, `@Published`, `StateObject`)
- **Lưu trữ cấu hình:** `UserDefaults` & App Group chia sẻ cấu hình giữa App và Extension
- **Unit Testing:** XCTest Suite cho `UrlSanitizer`, `AmpBypasser`, `LinkUnshortener`

---

## 📁 Cấu trúc thư mục

```
StopTheMadness Pro ios/
├── StopTheMadnessPro.xcodeproj/    # Xcode Project cấu hình đầy đủ
├── Package.swift                    # Hỗ trợ Swift Package Manager
├── StopTheMadnessPro/
│   ├── App/
│   │   ├── StopTheMadnessProApp.swift # Điểm khởi chạy App & AudioSession
│   │   └── Info.plist                 # Quyền nền (Audio Background Mode, ATS)
│   ├── Core/
│   │   ├── Engine/
│   │   │   ├── UrlSanitizer.swift     # Thuật toán dọn dẹp URL & loại bỏ trackers
│   │   │   ├── AmpBypasser.swift      # Nhận diện và bỏ qua AMP
│   │   │   ├── LinkUnshortener.swift  # Giải mã link rút gọn (bit.ly, t.co...)
│   │   │   ├── ScriptInjector.swift   # Nạp UserScripts & Custom CSS/JS
│   │   │   └── WebBridgeHandler.swift # Cầu nối nhận tin nhắn JS -> Swift
│   │   └── WebView/
│   │       └── StopTheMadnessWebView.swift # UIViewRepresentable cho WKWebView
│   ├── Data/
│   │   ├── Models/
│   │   │   ├── BrowserTab.swift       # Model thẻ duyệt web
│   │   │   ├── CustomRule.swift       # Model quy tắc CSS/JS tùy chỉnh
│   │   │   ├── ProtectionSettings.swift # Cấu hình bảo vệ
│   │   │   └── ProtectionStats.swift  # Bộ đếm thống kê thời gian thực
│   │   └── Storage/
│   │       └── PreferenceManager.swift# Lưu trữ UserDefaults / App Group
│   ├── ViewModels/
│   │   └── BrowserViewModel.swift     # Quản lý Tabs, điều hướng & modal
│   ├── UI/
│   │   ├── MainView.swift             # Màn hình chính kết nối các thành phần
│   │   ├── Components/
│   │   │   ├── AddressBarView.swift   # Thanh địa chỉ capsule & tiến trình tải
│   │   │   └── BottomToolbarView.swift# Thanh công cụ dưới (Back/Forward/Tabs/Menu)
│   │   ├── Dialogs/
│   │   │   ├── ProtectionSheetView.swift # Sheet thống kê & công tắc bảo vệ
│   │   │   ├── UrlEditorView.swift    # Hộp thoại biên tập URL & phân tích Query
│   │   │   ├── TabSwitcherView.swift  # Trình quản lý thẻ dạng lưới
│   │   │   └── CustomRuleEditorView.swift # Trình soạn thảo CSS/JS cho trang web
│   │   └── Settings/
│   │       ├── SettingsView.swift     # Trung tâm cài đặt toàn diện
│   │       └── CustomRulesListView.swift # Danh sách quy tắc tùy biến
│   └── Resources/
│       ├── stopthemadness.js          # JavaScript Engine can thiệp trang web
│       ├── stopthemadness.css         # CSS Engine khôi phục tương tác & ẩn banner
│       └── Assets.xcassets/           # AccentColor, AppIcon
├── StopTheMadnessExtension/           # Safari Web Extension Target
│   ├── SafariWebExtensionHandler.swift# Xử lý native messaging với Safari
│   ├── Info.plist
│   └── Resources/
│       ├── manifest.json              # Khai báo Web Extension Manifest V3
│       ├── popup.html / popup.js / popup.css # Giao diện popup trên Safari
│       ├── stopthemadness.js
│       └── stopthemadness.css
└── StopTheMadnessProTests/            # Bộ kiểm thử Unit Tests
    ├── UrlSanitizerTests.swift
    ├── AmpBypasserTests.swift
    └── LinkUnshortenerTests.swift
```

---

## 🔨 Cách build & chạy trong Xcode

### Yêu cầu:
- macOS với Xcode 15.0 trở lên
- iOS SDK 16.0+

### Các bước:
1. Mở file `StopTheMadnessPro.xcodeproj` bằng Xcode:
   ```bash
   open StopTheMadnessPro.xcodeproj
   ```
2. Chọn Scheme:
   - **StopTheMadnessPro** (để chạy ứng dụng Smart Browser chính trên iPhone/iPad Simulator hoặc thiết bị thật).
   - **StopTheMadnessExtension** (để chạy và test tiện ích mở rộng trên Safari).
3. Nhấn `Cmd + R` để Build & Run.
4. Chạy Unit Tests bằng tổ hợp phím `Cmd + U`.

