//
//  BrowserViewModel.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI
import Combine

public final class BrowserViewModel: ObservableObject {

    @Published public var tabs: [BrowserTab] = []
    @Published public var currentTabIndex: Int = 0

    // Sheet / Dialog Presentation states
    @Published public var isShowingProtectionSheet: Bool = false
    @Published public var isShowingUrlEditor: Bool = false
    @Published public var isShowingTabSwitcher: Bool = false
    @Published public var isShowingCustomRuleEditor: Bool = false
    @Published public var isShowingSettings: Bool = false
    @Published public var editingDomainForRule: String = ""

    public var currentTab: BrowserTab? {
        guard currentTabIndex >= 0 && currentTabIndex < tabs.count else { return nil }
        return tabs[currentTabIndex]
    }

    public init(initialUrl: String = "https://duckduckgo.com") {
        addNewTab(url: initialUrl)
    }

    public func addNewTab(url: String = "https://duckduckgo.com") {
        let clean = UrlSanitizer.sanitize(url).cleanedUrl
        let newTab = BrowserTab(url: clean)
        tabs.append(newTab)
        currentTabIndex = tabs.count - 1
    }

    public func closeTab(_ tab: BrowserTab) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        tab.webView?.stopLoading()
        tab.webView = nil
        tabs.remove(at: index)

        if tabs.isEmpty {
            addNewTab()
        } else {
            currentTabIndex = min(index, tabs.count - 1)
        }
    }

    public func selectTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        currentTabIndex = index
    }

    public func navigate(to rawInput: String, inNewTab: Bool = false) {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let targetUrlString: String
        if !trimmed.lowercased().hasPrefix("http://") && !trimmed.lowercased().hasPrefix("https://") {
            if trimmed.contains(".") && !trimmed.contains(" ") {
                targetUrlString = "https://" + trimmed
            } else {
                let query = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
                targetUrlString = "https://duckduckgo.com/?q=\(query)"
            }
        } else {
            targetUrlString = trimmed
        }

        let cleaned = UrlSanitizer.sanitize(targetUrlString).cleanedUrl

        if inNewTab {
            addNewTab(url: cleaned)
        } else if let tab = currentTab {
            tab.url = cleaned
            if let url = URL(string: cleaned) {
                tab.webView?.load(URLRequest(url: url))
            }
        }
    }

    public func goBack() {
        currentTab?.webView?.goBack()
    }

    public func goForward() {
        currentTab?.webView?.goForward()
    }

    public func reload() {
        currentTab?.webView?.reload()
    }

    public func copyCleanUrl() {
        guard let currentUrl = currentTab?.url else { return }
        let clean = UrlSanitizer.sanitize(currentUrl).cleanedUrl
        UIPasteboard.general.string = clean
    }

    public func getCleanUrl() -> String {
        guard let currentUrl = currentTab?.url else { return "" }
        return UrlSanitizer.sanitize(currentUrl).cleanedUrl
    }
}
