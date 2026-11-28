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
                    Toggle("Enable StopTheMadness Pro", isOn: $prefManager.settings.masterEnabled)
                        .font(.headline)
                } footer: {
                    Text("When disabled, all website interactions, URL sanitization and tracker blocking are paused.")
                }

                // 1. Web Interactions
                Section(header: Text("Web Interactions Restoration")) {
                    Toggle("Restore Copy, Cut & Paste", isOn: $prefManager.settings.restoreInteractions)
                    Toggle("Protect Clipboard (Anti-Hijacking)", isOn: $prefManager.settings.protectClipboard)
                    Toggle("Enable Pinch-to-Zoom", isOn: $prefManager.settings.allowZoom)
                }

                // 2. Privacy & Tracking
                Section(header: Text("Privacy & URL Sanitizer")) {
                    Toggle("Strip Tracking Parameters (UTM, fbclid...)", isOn: $prefManager.settings.blockTrackers)
                    Toggle("Bypass Google AMP to Canonical", isOn: $prefManager.settings.bypassAmp)
                    Toggle("Unwrap Shortened Links & Redirects", isOn: $prefManager.settings.unshortenLinks)
                    Toggle("Force Open Links in Current Tab", isOn: $prefManager.settings.forceLinksCurrentTab)
                }

                // 3. Media & Audio
                Section(header: Text("Media & Audio Controls")) {
                    Toggle("Force Native Media Controls", isOn: $prefManager.settings.controlVideoAudio)
                    Toggle("Block Video & Audio Autoplay", isOn: $prefManager.settings.blockAutoplay)
                    Toggle("Allow Background Audio Playback", isOn: $prefManager.settings.backgroundAudio)
                }

                // 4. Annoyances
                Section(header: Text("Annoyance Blockers")) {
                    Toggle("Hide App Banners & Google One Tap", isOn: $prefManager.settings.removeAnnoyances)
                }

                // 5. Custom Rules
                Section(header: Text("Custom Domain Rules")) {
                    NavigationLink {
                        CustomRulesListView(prefManager: prefManager)
                    } label: {
                        HStack {
                            Text("Custom CSS / JS Rules")
                            Spacer()
                            Text("\(prefManager.customRules.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // About section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Pro iOS)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Safari Extension")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Settings")
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
    }
}

