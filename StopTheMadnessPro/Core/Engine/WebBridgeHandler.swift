//
//  WebBridgeHandler.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation
import WebKit

public protocol WebBridgeDelegate: AnyObject {
    func webBridgeDidReceiveAction(_ action: String, data: [String: Any], in tab: BrowserTab)
}

public final class WebBridgeHandler: NSObject, WKScriptMessageHandler {

    private weak var tab: BrowserTab?
    public weak var delegate: WebBridgeDelegate?

    public init(tab: BrowserTab, delegate: WebBridgeDelegate? = nil) {
        self.tab = tab
        self.delegate = delegate
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "StopTheMadnessBridge" else { return }

        var action: String?
        var data: [String: Any] = [:]

        if let dict = message.body as? [String: Any] {
            action = dict["action"] as? String
            data = dict["data"] as? [String: Any] ?? [:]
        } else if let jsonString = message.body as? String,
                  let jsonData = jsonString.data(using: .utf8),
                  let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            action = dict["action"] as? String
            data = dict["data"] as? [String: Any] ?? [:]
        }

        guard let actionName = action, let tab = self.tab else { return }

        DispatchQueue.main.async { [weak self, weak tab] in
            guard let tab = tab else { return }

            switch actionName {
            case "trackerRemoved":
                tab.stats.trackersRemoved += 1
            case "ampDetected":
                tab.stats.ampBypassed += 1
                if let canonical = data["canonical"] as? String, let url = URL(string: canonical) {
                    tab.webView?.load(URLRequest(url: url))
                }
            case "autoplayBlocked":
                tab.stats.autoplayBlocked += 1
            case "notificationBlocked":
                tab.stats.annoyancesBlocked += 1
            case "clipboardWrite":
                break
            case "zoomRestored":
                break
            default:
                break
            }

            self?.delegate?.webBridgeDidReceiveAction(actionName, data: data, in: tab)
        }
    }
}
