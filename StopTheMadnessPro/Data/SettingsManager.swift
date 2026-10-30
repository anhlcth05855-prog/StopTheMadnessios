//
//  SettingsManager.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

/// Document wrapper để hỗ trợ SwiftUI FileExporter & FileImporter
public struct SettingsDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.json] }

    public var settings: ProtectionSettings

    public init(settings: ProtectionSettings = ProtectionSettings()) {
        self.settings = settings
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.settings = try JSONDecoder().decode(ProtectionSettings.self, from: data)
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)
        return FileWrapper(regularFileWithContents: data)
    }
}

public final class SettingsManager: ObservableObject {
    public static let shared = SettingsManager()

    public static let primaryAppGroupSuite = "group.com.stopthemadness.ios"
    public static let fallbackAppGroupSuite = "group.com.stopthemadness.pro"

    private let settingsKey = "stopthemadness_settings"
    private let customRulesKey = "stopthemadness_custom_rules"

    private let userDefaults: UserDefaults

    @Published public var settings: ProtectionSettings {
        didSet {
            saveSettings()
        }
    }

    @Published public var alertMessage: String?
    @Published public var showAlert: Bool = false

    public init() {
        if let sharedSuite = UserDefaults(suiteName: Self.primaryAppGroupSuite) {
            self.userDefaults = sharedSuite
        } else if let fallbackSuite = UserDefaults(suiteName: Self.fallbackAppGroupSuite) {
            self.userDefaults = fallbackSuite
        } else {
            self.userDefaults = UserDefaults.standard
        }

        // 1. Tải Cài đặt từ App Group
        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ProtectionSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = ProtectionSettings()
        }

        // 2. Tải custom rules riêng nếu có
        if let rulesData = userDefaults.data(forKey: customRulesKey),
           let decodedRules = try? JSONDecoder().decode([String: CustomRule].self, from: rulesData) {
            self.settings.customRules = decodedRules
        }
    }

    // MARK: - Lưu & Đồng bộ

    public func saveSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }

        if let rulesEncoded = try? encoder.encode(settings.customRules) {
            userDefaults.set(rulesEncoded, forKey: customRulesKey)
        }

        userDefaults.synchronize()
    }

    // MARK: - Quản lý Custom Domain Rules

    public func saveCustomRule(_ rule: CustomRule) {
        let normalized = rule.domain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var updated = settings.customRules
        updated[normalized] = rule
        settings.customRules = updated
    }

    public func removeCustomRule(domain: String) {
        let normalized = domain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var updated = settings.customRules
        updated.removeValue(forKey: normalized)
        settings.customRules = updated
    }

    // MARK: - Khôi phục cài đặt gốc (Reset)

    public func resetToDefaults() {
        self.settings = ProtectionSettings()
        saveSettings()
    }

    // MARK: - Import / Export JSON

    public func exportAsDocument() -> SettingsDocument {
        return SettingsDocument(settings: self.settings)
    }

    public func importFromURL(_ url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw CocoaError(.fileReadNoPermission)
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let data = try Data(contentsOf: url)
        try importSettings(from: data)
    }

    public func importSettings(from data: Data) throws {
        let decoded = try JSONDecoder().decode(ProtectionSettings.self, from: data)
        DispatchQueue.main.async {
            self.settings = decoded
            self.saveSettings()
        }
    }
}
