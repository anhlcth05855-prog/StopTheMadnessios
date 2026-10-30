//
//  StopTheMadnessWebView.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI
import WebKit
import AVFoundation

public struct StopTheMadnessWebView: UIViewRepresentable {

    @ObservedObject var tab: BrowserTab
    @ObservedObject var prefManager: PreferenceManager
    var onOpenNewTab: ((URL) -> Void)?

    public init(
        tab: BrowserTab,
        prefManager: PreferenceManager = .shared,
        onOpenNewTab: ((URL) -> Void)? = nil
    ) {
        self.tab = tab
        self.prefManager = prefManager
        self.onOpenNewTab = onOpenNewTab
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Configure Media Playback & Picture-in-Picture
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = prefManager.settings.blockAutoplay ? .all : []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true

        // User Content Controller with Scripts & Bridge
        let userContentController = WKUserContentController()

        // Add Bridge
        let bridgeHandler = WebBridgeHandler(tab: tab, delegate: context.coordinator)
        context.coordinator.bridgeHandler = bridgeHandler
        userContentController.add(bridgeHandler, name: "StopTheMadnessBridge")

        // Add Injected User Scripts
        let userScripts = ScriptInjector.createUserScripts(settings: prefManager.settings)
        for script in userScripts {
            userContentController.addUserScript(script)
        }

        configuration.userContentController = userContentController

        // Enable background audio playback if enabled
        if prefManager.settings.backgroundAudio {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // Allow Pinch to Zoom
        webView.scrollView.minimumZoomScale = 0.5
        webView.scrollView.maximumZoomScale = 5.0

        tab.webView = webView
        context.coordinator.setupObservation(for: webView)

        if let targetUrl = URL(string: tab.url) {
            webView.load(URLRequest(url: targetUrl))
        }

        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // State updates if necessary
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WebBridgeDelegate {
        var parent: StopTheMadnessWebView
        var bridgeHandler: WebBridgeHandler?
        private var observations: [NSKeyValueObservation] = []

        init(_ parent: StopTheMadnessWebView) {
            self.parent = parent
        }

        func setupObservation(for webView: WKWebView) {
            observations.removeAll()

            // Observe title
            observations.append(webView.observe(\.title, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async {
                    if let title = wv.title, !title.isEmpty {
                        self?.parent.tab.title = title
                    }
                }
            })

            // Observe URL
            observations.append(webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async {
                    if let urlString = wv.url?.absoluteString {
                        self?.parent.tab.url = urlString
                    }
                }
            })

            // Observe Progress
            observations.append(webView.observe(\.estimatedProgress, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async {
                    self?.parent.tab.progress = wv.estimatedProgress
                }
            })

            // Observe Loading
            observations.append(webView.observe(\.isLoading, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async {
                    self?.parent.tab.isLoading = wv.isLoading
                    self?.parent.tab.canGoBack = wv.canGoBack
                    self?.parent.tab.canGoForward = wv.canGoForward
                }
            })
        }

        // MARK: - WKNavigationDelegate

        public func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let urlString = url.absoluteString
            let settings = parent.prefManager.settings

            guard settings.masterEnabled else {
                decisionHandler(.allow)
                return
            }

            // 1. AMP Bypasser
            if settings.bypassAmp && AmpBypasser.isAmpUrl(urlString) {
                if let canonical = AmpBypasser.extractCanonicalUrl(urlString),
                   canonical != urlString,
                   let target = URL(string: canonical) {
                    parent.tab.stats.ampBypassed += 1
                    decisionHandler(.cancel)
                    webView.load(URLRequest(url: target))
                    return
                }
            }

            // 2. Link Unshortener (bit.ly, t.co...)
            if settings.unshortenLinks && LinkUnshortener.shared.isShortened(urlString) {
                decisionHandler(.cancel)
                Task {
                    let unshortened = await LinkUnshortener.shared.unshorten(urlString)
                    let sanitized = settings.blockTrackers ? UrlSanitizer.sanitize(unshortened) : UrlSanitizer.SanitizeResult(cleanedUrl: unshortened, removedParams: [])
                    if !sanitized.removedParams.isEmpty {
                        await MainActor.run {
                            self.parent.tab.stats.trackersRemoved += sanitized.removedParams.count
                        }
                    }
                    if let targetUrl = URL(string: sanitized.cleanedUrl) {
                        await MainActor.run {
                            webView.load(URLRequest(url: targetUrl))
                        }
                    }
                }
                return
            }

            // 3. Tracking parameters cleaning
            if settings.blockTrackers {
                let result = UrlSanitizer.sanitize(urlString)
                if !result.removedParams.isEmpty || result.wasRedirectResolved {
                    parent.tab.stats.trackersRemoved += result.removedParams.count
                    if let targetUrl = URL(string: result.cleanedUrl) {
                        decisionHandler(.cancel)
                        webView.load(URLRequest(url: targetUrl))
                        return
                    }
                }
            }

            // Target _blank handling
            if navigationAction.targetFrame == nil {
                if settings.forceLinksCurrentTab {
                    decisionHandler(.cancel)
                    webView.load(navigationAction.request)
                    return
                } else {
                    parent.onOpenNewTab?(url)
                    decisionHandler(.cancel)
                    return
                }
            }

            decisionHandler(.allow)
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let host = webView.url?.host ?? ""
            if parent.prefManager.isDomainProtectionEnabled(for: host) {
                ScriptInjector.injectCustomRules(
                    for: host,
                    into: webView,
                    rules: parent.prefManager.getCustomRules()
                )
            }
        }

        // MARK: - WKUIDelegate

        public func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let targetUrl = navigationAction.request.url {
                if parent.prefManager.settings.forceLinksCurrentTab {
                    webView.load(navigationAction.request)
                } else {
                    parent.onOpenNewTab?(targetUrl)
                }
            }
            return nil
        }

        // MARK: - WebBridgeDelegate

        public func webBridgeDidReceiveAction(_ action: String, data: [String : Any], in tab: BrowserTab) {
            // Additional delegate actions
        }
    }
}

