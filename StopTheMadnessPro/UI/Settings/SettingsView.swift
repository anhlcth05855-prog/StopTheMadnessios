//
//  SettingsView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct SettingsView: View {

    @ObservedObject var prefManager: PreferenceManager
    @Environment(\.dismiss) private var dismiss

    public init(prefManager: PreferenceManager = .shared) {
        self.prefManager = prefManager
    }

    public var body: some View {
        NavigationView {
            Form {
                // Master Switch Section
                Section {
                    Toggle("Bật StopTheMadness Pro", isOn: $prefManager.settings.masterEnabled)
                        .font(.headline)
                } footer: {
                    Text("Khi tắt, toàn bộ các tính năng can thiệp, dọn URL và chặn tracker sẽ dừng hoạt động.")
                }

                // 1. Khôi phục quyền tương tác
                Section(header: Text("Khôi phục quyền tương tác web")) {
                    Toggle("Cho phép bôi đen & sao chép", isOn: $prefManager.settings.restoreInteractions)
                    Toggle("Bảo vệ bộ nhớ tạm (Chống ghi đè)", isOn: $prefManager.settings.protectClipboard)
                    Toggle("Mở khóa thu phóng (Pinch-to-zoom)", isOn: $prefManager.settings.allowZoom)
                }

                // 2. Chặn theo dõi & Dọn sạch URL
                Section(header: Text("Chặn theo dõi & Dọn sạch URL")) {
                    Toggle("Xóa tham số theo dõi (UTM, fbclid...)", isOn: $prefManager.settings.blockTrackers)
                    Toggle("Bỏ qua Google AMP (Vào trang gốc)", isOn: $prefManager.settings.bypassAmp)
                    Toggle("Vượt qua link rút gọn (bit.ly, t.co)", isOn: $prefManager.settings.unshortenLinks)
                    Toggle("Buộc mở liên kết trong cùng tab", isOn: $prefManager.settings.forceLinksCurrentTab)
                }

                // 3. Kiểm soát Video & Âm thanh
                Section(header: Text("Kiểm soát Video & Âm thanh")) {
                    Toggle("Kiểm soát Media (Hiện controls gốc)", isOn: $prefManager.settings.controlVideoAudio)
                    Toggle("Chặn tự động phát (Autoplay)", isOn: $prefManager.settings.blockAutoplay)
                    Toggle("Duy trì phát âm thanh nền khi ẩn tab", isOn: $prefManager.settings.backgroundAudio)
                }

                // 4. Loại bỏ các thông báo làm phiền
                Section(header: Text("Loại bỏ thông báo làm phiền")) {
                    Toggle("Ẩn banner cài App & Google One Tap", isOn: $prefManager.settings.removeAnnoyances)
                }

                // 5. Tùy biến nâng cao
                Section(header: Text("Tùy biến nâng cao")) {
                    NavigationLink {
                        CustomRulesListView(prefManager: prefManager)
                    } label: {
                        HStack {
                            Text("Quy tắc CSS / JS tùy chỉnh")
                            Spacer()
                            Text("\(prefManager.customRules.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // About section
                Section(header: Text("Giới thiệu")) {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0 (Pro iOS)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Safari Extension")
                        Spacer()
                        Text("Đã hỗ trợ")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
    }
}
