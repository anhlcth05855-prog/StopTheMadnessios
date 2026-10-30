//
//  ProtectionSheetView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct ProtectionSheetView: View {

    @ObservedObject var viewModel: BrowserViewModel
    @ObservedObject var prefManager: PreferenceManager
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Domain Header & Master Toggle
                    VStack(spacing: 8) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(isDomainEnabled ? Color.indigo.opacity(0.15) : Color.gray.opacity(0.15))
                                    .frame(width: 50, height: 50)

                                Image(systemName: "shield.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(isDomainEnabled ? .indigo : .gray)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(currentHost)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(isDomainEnabled ? "Đang được bảo vệ toàn diện" : "Đã tạm dừng bảo vệ")
                                    .font(.caption)
                                    .foregroundColor(isDomainEnabled ? .green : .secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { isDomainEnabled },
                                set: { newValue in
                                    prefManager.setDomainProtection(for: currentHost, enabled: newValue)
                                    viewModel.reload()
                                }
                            ))
                            .labelsHidden()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }

                    // Live Statistics Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("THỐNG KÊ TRÊN TRANG NÀY")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(
                                title: "Tracker đã xóa",
                                count: tabStats.trackersRemoved,
                                icon: "trash.fill",
                                color: .purple
                            )
                            StatCard(
                                title: "Bỏ qua AMP",
                                count: tabStats.ampBypassed,
                                icon: "bolt.horizontal.fill",
                                color: .orange
                            )
                            StatCard(
                                title: "Chặn Autoplay",
                                count: tabStats.autoplayBlocked,
                                icon: "pause.circle.fill",
                                color: .red
                            )
                            StatCard(
                                title: "Chặn làm phiền",
                                count: tabStats.annoyancesBlocked,
                                icon: "bell.slash.fill",
                                color: .blue
                            )
                        }
                    }

                    // Feature Toggles Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CÔNG CỤ BẢO VỆ TÍCH CỰC")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            ToggleRow(
                                title: "Khôi phục tương tác web",
                                subtitle: "Cho phép copy, chuột phải, chọn chữ, cuộn & zoom",
                                icon: "hand.tap.fill",
                                color: .blue,
                                isOn: Binding(
                                    get: { prefManager.settings.restoreInteractions },
                                    set: { prefManager.settings.restoreInteractions = $0; viewModel.reload() }
                                )
                            )

                            Divider().padding(.leading, 56)

                            ToggleRow(
                                title: "Chặn theo dõi & Dọn URL",
                                subtitle: "Xóa sạch UTM, fbclid, gclid và giải mã liên kết",
                                icon: "shield.lefthalf.filled",
                                color: .purple,
                                isOn: Binding(
                                    get: { prefManager.settings.blockTrackers },
                                    set: { prefManager.settings.blockTrackers = $0; viewModel.reload() }
                                )
                            )

                            Divider().padding(.leading, 56)

                            ToggleRow(
                                title: "Kiểm soát Video & Âm thanh",
                                subtitle: "Chặn phát tự động, hiện điều khiển gốc & phát ngầm",
                                icon: "play.rectangle.fill",
                                color: .red,
                                isOn: Binding(
                                    get: { prefManager.settings.controlVideoAudio },
                                    set: { prefManager.settings.controlVideoAudio = $0; viewModel.reload() }
                                )
                            )

                            Divider().padding(.leading, 56)

                            ToggleRow(
                                title: "Loại bỏ thông báo làm phiền",
                                subtitle: "Ẩn banner ép tải App, Google One Tap & push prompt",
                                icon: "bell.slash.fill",
                                color: .orange,
                                isOn: Binding(
                                    get: { prefManager.settings.removeAnnoyances },
                                    set: { prefManager.settings.removeAnnoyances = $0; viewModel.reload() }
                                )
                            )
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            dismiss()
                            viewModel.editingDomainForRule = currentHost
                            viewModel.isShowingCustomRuleEditor = true
                        } label: {
                            HStack {
                                Image(systemName: "curlybraces")
                                Text("Tùy biến CSS / JS cho trang này")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 15, weight: .medium))
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)

                        Button {
                            dismiss()
                            viewModel.isShowingSettings = true
                        } label: {
                            HStack {
                                Image(systemName: "gearshape")
                                Text("Tất cả cài đặt StopTheMadness")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(size: 15, weight: .medium))
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding()
            }
            .navigationTitle("Lá chắn bảo vệ")
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

    private var currentHost: String {
        guard let urlString = viewModel.currentTab?.url,
              let url = URL(string: urlString),
              let host = url.host else {
            return "Trang web"
        }
        return host
    }

    private var isDomainEnabled: Bool {
        prefManager.isDomainProtectionEnabled(for: currentHost)
    }

    private var tabStats: ProtectionStats {
        viewModel.currentTab?.stats ?? ProtectionStats()
    }
}

// MARK: - Subviews

struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(count)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
