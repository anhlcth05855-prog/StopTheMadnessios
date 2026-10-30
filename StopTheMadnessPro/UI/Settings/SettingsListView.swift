//
//  SettingsListView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI

public struct SettingsListView: View {

    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss

    public init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
    }

    public var body: some View {
        List {
            // Master Switch
            Section {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .frame(width: 32, height: 32)
                        Image(systemName: "shield.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Enable StopTheMadness Pro")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Master toggle for all protection features")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $settingsManager.settings.masterEnabled)
                        .labelsHidden()
                        .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
                }
                .padding(.vertical, 4)
            }

            // Nhóm 1: Web Interactions
            Section(header: sectionHeader(title: "Web Interactions", icon: "hand.tap.fill", color: .blue)) {
                customToggleRow(
                    title: "Restore Text Selection & Copy",
                    subtitle: "Unblocks selectstart, copy, cut, paste, and right-click menus",
                    isOn: $settingsManager.settings.restoreInteractions
                )
                customToggleRow(
                    title: "Protect Clipboard",
                    subtitle: "Prevents websites from hijacking or overwriting your clipboard",
                    isOn: $settingsManager.settings.protectClipboard
                )
                customToggleRow(
                    title: "Allow Pinch-to-Zoom",
                    subtitle: "Forces viewport to allow zooming even if the page disables it",
                    isOn: $settingsManager.settings.allowZoom
                )
            }

            // Nhóm 2: Privacy & Tracking
            Section(header: sectionHeader(title: "Privacy & Tracking", icon: "eye.slash.fill", color: .indigo)) {
                customToggleRow(
                    title: "Remove Tracking Parameters",
                    subtitle: "Strips utm_*, fbclid, gclid, igshid, si, and ping attributes",
                    isOn: $settingsManager.settings.blockTrackers
                )
                customToggleRow(
                    title: "Bypass Google AMP",
                    subtitle: "Automatically redirects AMP pages to the original canonical URL",
                    isOn: $settingsManager.settings.bypassAmp
                )
                customToggleRow(
                    title: "Unwrap Redirect Links",
                    subtitle: "Decodes google.com/url, facebook.com/l.php, and outbound tracking links",
                    isOn: $settingsManager.settings.unshortenLinks
                )
            }

            // Nhóm 3: Media & Audio
            Section(header: sectionHeader(title: "Media & Audio", icon: "play.rectangle.fill", color: .purple)) {
                customToggleRow(
                    title: "Block Video Autoplay",
                    subtitle: "Stops videos and audio from playing without your explicit touch gesture",
                    isOn: $settingsManager.settings.blockAutoplay
                )
                customToggleRow(
                    title: "Allow Background Audio",
                    subtitle: "Keeps audio and video playing when switching tabs or locking screen",
                    isOn: $settingsManager.settings.backgroundAudio
                )
            }

            // Nhóm 4: Annoyance Blockers
            Section(header: sectionHeader(title: "Annoyance Blockers", icon: "xmark.octagon.fill", color: .orange)) {
                customToggleRow(
                    title: "Hide Mobile App Banners",
                    subtitle: "Hides Smart App Banners on Reddit, Quora, and modal app install popups",
                    isOn: $settingsManager.settings.removeAnnoyances
                )
                customToggleRow(
                    title: "Block Notification Prompts",
                    subtitle: "Automatically denies annoying Web Push notification permission popups",
                    isOn: $settingsManager.settings.removeAnnoyances
                )
            }

            // Nhóm 5: Custom Rules by Domain
            Section(header: sectionHeader(title: "Website Rules", icon: "slider.horizontal.3", color: .teal)) {
                NavigationLink(destination: CustomRulesListView(prefManager: PreferenceManager.shared)) {
                    HStack {
                        Text("Custom CSS & JavaScript")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(settingsManager.settings.customRules.count) rules")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Protection Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .font(.headline)
            }
        }
    }

    // MARK: - View Builders

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(nil)
        }
    }

    private func customToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding(.vertical, 2)
    }
}

