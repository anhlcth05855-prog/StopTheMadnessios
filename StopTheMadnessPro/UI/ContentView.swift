//
//  ContentView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI
import UniformTypeIdentifiers

public struct ContentView: View {

    @StateObject private var settingsManager = SettingsManager.shared

    // Sheets & Dialog states
    @State private var isShowingSettingsList = false
    @State private var isShowingResetConfirmation = false
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportDocument: SettingsDocument?
    @State private var statusToast: String?

    private let supportWebsiteUrl = URL(string: "https://gitlab.com/sondeptrai/stopthemadness_ios")!

    public init() {}

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Header
                    VStack(spacing: 8) {
                        Image(systemName: "hand.raised.square.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)

                        Text("StopTheMadness Pro")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Take back control of your web browsing on iOS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Link(destination: supportWebsiteUrl) {
                            HStack(spacing: 4) {
                                Text("Open Support Website")
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .padding(.top, 4)
                        }
                    }
                    .padding(.top, 16)

                    // MARK: - 3 Pill Buttons Đặc Trưng StopTheMadness
                    VStack(spacing: 12) {
                        // Nút 1: Import
                        Button(action: {
                            isImporting = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Import extension settings from a file")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }

                        // Nút 2: Export
                        Button(action: {
                            exportDocument = settingsManager.exportAsDocument()
                            isExporting = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Export extension settings to a file")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }

                        // Nút 3: Reset
                        Button(action: {
                            isShowingResetConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Reset extension settings")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.red.opacity(0.25), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Quick Configure Button
                    NavigationLink(destination: SettingsListView(settingsManager: settingsManager)) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Configure Website Protection Rules")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)

                    // MARK: - In-App Test Browser
                    NavigationLink(destination: MainView()) {
                        HStack {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            Text("Launch In-App Test Browser")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Hướng dẫn: How to enable the Safari extension
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "safari.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .font(.title3)
                            Text("How to enable the Safari extension")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }

                        Divider()

                        // Step 1
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                stepBadge(number: "1")
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Open Safari Extensions Settings")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Text("Go to iOS Settings > Apps > Safari > Extensions, or tap the button below:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Button(action: openSettingsApp) {
                                HStack {
                                    Image(systemName: "gearshape.fill")
                                    Text("Open in Settings app")
                                        .font(.caption.weight(.bold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                .clipShape(Capsule())
                            }
                            .padding(.leading, 36)
                        }

                        // Step 2
                        HStack(alignment: .top, spacing: 12) {
                            stepBadge(number: "2")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Select StopTheMadness Pro")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text("Find StopTheMadness Pro under the Safari extensions list.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Step 3
                        HStack(alignment: .top, spacing: 12) {
                            stepBadge(number: "3")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Allow Extension & Website Permissions")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                                Text("Switch the extension toggle ON, then tap 'All Websites' and select 'Allow' for complete protection.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 20)

                    // Footer note
                    Text("StopTheMadness Pro iOS • Version 1.0.0\nProtected by App Group & MV3 Content Script Engine")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                }
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
        // MARK: - Confirmation Dialog Reset
        .confirmationDialog(
            "Reset extension settings?",
            isPresented: $isShowingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset to Defaults", role: .destructive) {
                settingsManager.resetToDefaults()
                statusToast = "Settings reset to defaults"
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will restore all interaction, privacy, media, and annoyance rules to their factory default settings.")
        }
        // MARK: - File Export
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "StopTheMadness-Settings.json"
        ) { result in
            switch result {
            case .success(let url):
                statusToast = "Settings exported to \(url.lastPathComponent)"
            case .failure(let error):
                statusToast = "Export failed: \(error.localizedDescription)"
            }
        }
        // MARK: - File Import
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let selectedUrl = urls.first else { return }
                do {
                    try settingsManager.importFromURL(selectedUrl)
                    statusToast = "Settings imported successfully!"
                } catch {
                    statusToast = "Import failed: \(error.localizedDescription)"
                }
            case .failure(let error):
                statusToast = "Import failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - UI Helpers

    private func stepBadge(number: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.0, green: 0.48, blue: 1.0))
                .frame(width: 24, height: 24)
            Text(number)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private func openSettingsApp() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
