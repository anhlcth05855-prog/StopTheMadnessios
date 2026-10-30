//
//  ScriptInjector.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation
import WebKit

public struct ScriptInjector {

    private static var cachedJs: String?
    private static var cachedCss: String?

    public static func loadBundleAssets() {
        if cachedJs == nil {
            if let jsUrl = Bundle.main.url(forResource: "stopthemadness", withExtension: "js"),
               let content = try? String(contentsOf: jsUrl, encoding: .utf8) {
                cachedJs = content
            }
        }
        if cachedCss == nil {
            if let cssUrl = Bundle.main.url(forResource: "stopthemadness", withExtension: "css"),
               let content = try? String(contentsOf: cssUrl, encoding: .utf8) {
                cachedCss = content
            }
        }
    }

    public static func createUserScripts(settings: ProtectionSettings) -> [WKUserScript] {
        loadBundleAssets()
        var scripts: [WKUserScript] = []

        guard settings.masterEnabled else { return scripts }

        // 1. Inject CSS via Javascript wrapper at document start
        if let css = cachedCss ?? defaultCss() {
            let encoded = Data(css.utf8).base64EncodedString()
            let cssInjectionJs = """
            (function() {
                const styleId = 'stm-injected-style';
                if (!document.getElementById(styleId)) {
                    const style = document.createElement('style');
                    style.id = styleId;
                    style.type = 'text/css';
                    style.innerHTML = window.atob('\(encoded)');
                    (document.head || document.documentElement).appendChild(style);
                }
            })();
            """
            let cssScript = WKUserScript(
                source: cssInjectionJs,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            scripts.append(cssScript)
        }

        // 2. Inject JS Engine at document start
        if let js = cachedJs ?? defaultJs() {
            let jsScript = WKUserScript(
                source: js,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            scripts.append(jsScript)
        }

        return scripts
    }

    public static func injectCustomRules(for host: String, into webView: WKWebView, rules: [String: CustomRule]) {
        let normalizedHost = host.lowercased()
        let matchedRules = rules.values.filter { rule in
            rule.enabled && (rule.domain == "*" || normalizedHost.hasSuffix(rule.domain.lowercased()))
        }

        for rule in matchedRules {
            if !rule.customCss.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let encoded = Data(rule.customCss.utf8).base64EncodedString()
                let ruleCss = """
                (function() {
                    const style = document.createElement('style');
                    style.type = 'text/css';
                    style.innerHTML = window.atob('\(encoded)');
                    (document.head || document.documentElement).appendChild(style);
                })();
                """
                webView.evaluateJavaScript(ruleCss, completionHandler: nil)
            }

            if !rule.customJs.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                webView.evaluateJavaScript(rule.customJs, completionHandler: nil)
            }
        }
    }

    private static func defaultCss() -> String {
        return """
        * { -webkit-user-select: text !important; user-select: text !important; }
        .smartbanner, .app-banner, .mobile-app-banner, #credential_picker_container, [class*="AppInstallBanner"], [class*="OpenInAppModal"] { display: none !important; visibility: hidden !important; }
        video { pointer-events: auto !important; }
        html, body { overflow-y: auto !important; touch-action: pan-y pinch-zoom !important; }
        """
    }

    private static func defaultJs() -> String {
        return """
        (function() {
            if (window.__stopTheMadnessLoaded) return;
            window.__stopTheMadnessLoaded = true;
            ['selectstart', 'copy', 'cut', 'contextmenu'].forEach(evt => {
                window.addEventListener(evt, e => { e.stopImmediatePropagation = () => {}; }, true);
            });
        })();
        """
    }
}
