//
//  SafariWebExtensionHandler.swift
//  StopTheMadnessExtension
//
//  Created for StopTheMadness Pro iOS Safari Extension.
//

import SafariServices
import os.log

public final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    public func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any] else {
            let response = NSExtensionItem()
            response.userInfo = [SFExtensionMessageKey: ["error": "Invalid request message"]]
            context.completeRequest(returningItems: [response], completionHandler: nil)
            return
        }

        os_log(.default, "[StopTheMadness Safari Extension] Received message: %@", message.description)

        let action = message["action"] as? String ?? ""
        var reply: [String: Any] = [:]

        switch action {
        case "getSettings":
            reply = [
                "masterEnabled": true,
                "restoreInteractions": true,
                "blockTrackers": true,
                "controlVideoAudio": true,
                "removeAnnoyances": true
            ]
        case "statsUpdated":
            reply = ["status": "recorded"]
        default:
            reply = ["status": "ok"]
        }

        let response = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: reply]
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
