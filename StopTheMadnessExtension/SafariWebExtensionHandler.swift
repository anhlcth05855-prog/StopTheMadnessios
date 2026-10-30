//
//  SafariWebExtensionHandler.swift
//  StopTheMadnessExtension
//
//  Created for StopTheMadness Pro iOS Safari Extension.
//

import SafariServices
import os.log

public final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    private let appGroupIdentifier = "group.com.stopthemadness.ios"
    private let fallbackAppGroupIdentifier = "group.com.stopthemadness.pro"
    private let settingsKey = "stopthemadness_settings"
    private let customRulesKey = "stopthemadness_custom_rules"

    private var sharedDefaults: UserDefaults {
        return UserDefaults(suiteName: appGroupIdentifier)
            ?? UserDefaults(suiteName: fallbackAppGroupIdentifier)
            ?? UserDefaults.standard
    }

    public func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any] else {
            completeWithError("Invalid request message", context: context)
            return
        }

        os_log(.default, "[StopTheMadness Extension] Received native message: %@", message.description)

        let action = message["action"] as? String ?? ""
        var replyData: [String: Any] = [:]

        switch action {
        case "getSettings":
            replyData = handleGetSettings(message: message)

        case "saveSettings":
            replyData = handleSaveSettings(message: message)

        case "ping":
            replyData = ["status": "pong", "version": "1.0.0"]

        default:
            replyData = ["status": "acknowledged"]
        }

        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: replyData]
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }

    // MARK: - Private Handlers

    private func handleGetSettings(message: [String: Any]) -> [String: Any] {
        let defaults = sharedDefaults

        // 1. Đọc ProtectionSettings đã lưu từ App Group
        var masterEnabled = true
        var restoreInteractions = true
        var protectClipboard = true
        var allowZoom = true
        var blockTrackers = true
        var bypassAmp = true
        var unshortenLinks = true
        var blockAutoplay = true
        var backgroundAudio = true
        var removeAnnoyances = true

        if let data = defaults.data(forKey: settingsKey),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            masterEnabled = json["masterEnabled"] as? Bool ?? true
            restoreInteractions = json["restoreInteractions"] as? Bool ?? true
            protectClipboard = json["protectClipboard"] as? Bool ?? true
            allowZoom = json["allowZoom"] as? Bool ?? true
            blockTrackers = json["blockTrackers"] as? Bool ?? true
            bypassAmp = json["bypassAmp"] as? Bool ?? true
            unshortenLinks = json["unshortenLinks"] as? Bool ?? true
            blockAutoplay = json["blockAutoplay"] as? Bool ?? true
            backgroundAudio = json["backgroundAudio"] as? Bool ?? true
            removeAnnoyances = json["removeAnnoyances"] as? Bool ?? true
        }

        // Nếu người dùng tắt Master Switch thì vô hiệu hóa tất cả tính năng
        if !masterEnabled {
            return [
                "masterEnabled": false,
                "restoreInteractions": false,
                "protectClipboard": false,
                "allowZoom": false,
                "blockTrackers": false,
                "bypassAmp": false,
                "unshortenLinks": false,
                "blockAutoplay": false,
                "backgroundAudio": false,
                "removeAnnoyances": false,
                "customCss": "",
                "customJs": ""
            ]
        }

        // 2. Tìm quy tắc CSS / JS tùy chỉnh cho Domain hiện tại
        var customCss = ""
        var customJs = ""

        let host = (message["host"] as? String ?? "").lowercased()
        if let rulesData = defaults.data(forKey: customRulesKey),
           let rules = try? JSONSerialization.jsonObject(with: rulesData) as? [String: [String: Any]] {

            // Ưu tiên domain khớp chính xác, sau đó đến rule toàn cục "*"
            if let matchedRule = rules[host] ?? rules["*"] {
                if (matchedRule["enabled"] as? Bool) ?? true {
                    customCss = matchedRule["customCss"] as? String ?? ""
                    customJs = matchedRule["customJs"] as? String ?? ""
                }
            }
        }

        return [
            "masterEnabled": masterEnabled,
            "restoreInteractions": restoreInteractions,
            "protectClipboard": protectClipboard,
            "allowZoom": allowZoom,
            "blockTrackers": blockTrackers,
            "bypassAmp": bypassAmp,
            "unshortenLinks": unshortenLinks,
            "blockAutoplay": blockAutoplay,
            "backgroundAudio": backgroundAudio,
            "removeAnnoyances": removeAnnoyances,
            "customCss": customCss,
            "customJs": customJs
        ]
    }

    private func handleSaveSettings(message: [String: Any]) -> [String: Any] {
        if let newSettings = message["settings"] as? [String: Any],
           let data = try? JSONSerialization.data(withJSONObject: newSettings) {
            sharedDefaults.set(data, forKey: settingsKey)
            return ["success": true]
        }
        return ["success": false, "error": "Invalid payload"]
    }

    private func completeWithError(_ message: String, context: NSExtensionContext) {
        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: ["error": message]]
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
