//
//  AddressBarView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct AddressBarView: View {

    @ObservedObject var viewModel: BrowserViewModel
    @ObservedObject var prefManager: PreferenceManager

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Shield Button (opens Protection Sheet)
                Button {
                    viewModel.isShowingProtectionSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(shieldColor.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: "shield.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(shieldColor)
                    }
                }

                // URL Capsule
                Button {
                    viewModel.isShowingUrlEditor = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isSecure ? "lock.fill" : "lock.open.trianglebadge.exclamationmark")
                            .font(.system(size: 12))
                            .foregroundColor(isSecure ? .secondary : .orange)

                        Text(displayHost)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(19)
                }

                // Reload Button
                Button {
                    viewModel.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Progress Bar
            if let tab = viewModel.currentTab, tab.isLoading {
                ProgressView(value: tab.progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    .frame(height: 2)
            }
        }
        .background(Color(.systemBackground))
    }

    private var currentHost: String {
        guard let urlString = viewModel.currentTab?.url,
              let url = URL(string: urlString),
              let host = url.host else {
            return ""
        }
        return host
    }

    private var displayHost: String {
        let host = currentHost
        return host.isEmpty ? (viewModel.currentTab?.url ?? "Nhập địa chỉ web...") : host
    }

    private var isSecure: Bool {
        guard let urlString = viewModel.currentTab?.url else { return true }
        return urlString.lowercased().hasPrefix("https://")
    }

    private var shieldColor: Color {
        let isEnabled = prefManager.isDomainProtectionEnabled(for: currentHost)
        return isEnabled ? .indigo : .gray
    }
}

