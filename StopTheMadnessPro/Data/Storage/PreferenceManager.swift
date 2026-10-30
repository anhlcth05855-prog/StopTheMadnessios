//
//  PreferenceManager.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public final class PreferenceManager: ObservableObject {
    public static let shared = PreferenceManager()

    private let userDefaults: UserDefaults
    private let settingsKey = "stopthemadness_settings"
    private let customRulesKey = "stopthemadness_custom_rules"
    private let disabledDomainsKey = "stopthemadness_disabled_domains"
    private let appGroupSuite = "group.com.stopthemadness.ios"
    private let fallbackSuite = "group.com.stopthemadness.pro"

    @Published public var settings: ProtectionSettings {
        didSet {
            saveSettings(settings)
        }
    }

    @Published public var customRules: [String: CustomRule] {
        didSet {
            saveCustomRules(customRules)
        }
    }

    @Published public var disabledDomains: Set<String> {
        didSet {
            saveDisabledDomains(disabledDomains)
        }
    }

    public init() {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.stopthemadness.ios") {
            self.userDefaults = sharedDefaults
        } else if let fallbackDefaults = UserDefaults(suiteName: "group.com.stopthemadness.pro") {
            self.userDefaults = fallbackDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }

        // Load Settings
        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ProtectionSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = ProtectionSettings()
        }

        // Load Custom Rules
        if let data = userDefaults.data(forKey: customRulesKey),
           let decoded = try? JSONDecoder().decode([String: CustomRule].self, from: data) {
            self.customRules = decoded
        } else {
            self.customRules = [:]
        }

        // Load Disabled Domains
        if let array = userDefaults.stringArray(forKey: disabledDomainsKey) {
            self.disabledDomains = Set(array.map { $0.lowercased() })
        } else {
            self.disabledDomains = []
        }
    }

    public func saveSettings(_ newSettings: ProtectionSettings) {
        if let encoded = try? JSONEncoder().encode(newSettings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }

    public func getCustomRules() -> [String: CustomRule] {
        return customRules
    }

    public func saveCustomRule(_ rule: CustomRule) {
        let domain = rule.domain.lowercased()
        var rules = customRules
        rules[domain] = rule
        customRules = rules
    }

    public func removeCustomRule(domain: String) {
        let normalized = domain.lowercased()
        var rules = customRules
        rules.removeValue(forKey: normalized)
        customRules = rules
    }

    private func saveCustomRules(_ rules: [String: CustomRule]) {
        if let encoded = try? JSONEncoder().encode(rules) {
            userDefaults.set(encoded, forKey: customRulesKey)
        }
    }

    public func isDomainProtectionEnabled(for host: String) -> Bool {
        guard settings.masterEnabled else { return false }
        let normalized = host.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty { return settings.masterEnabled }
        return !disabledDomains.contains(normalized)
    }

    public func setDomainProtection(for host: String, enabled: Bool) {
        let normalized = host.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        var currentSet = disabledDomains
        if enabled {
            currentSet.remove(normalized)
        } else {
            currentSet.insert(normalized)
        }
        disabledDomains = currentSet
    }

    private func saveDisabledDomains(_ domains: Set<String>) {
        userDefaults.set(Array(domains), forKey: disabledDomainsKey)
    }
}

