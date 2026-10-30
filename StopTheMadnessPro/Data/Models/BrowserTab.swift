//
//  BrowserTab.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation
import WebKit

public class BrowserTab: Identifiable, ObservableObject {
    public let id: UUID
    @Published public var title: String
    @Published public var url: String
    @Published public var stats: ProtectionStats
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var progress: Double = 0.0

    public var webView: WKWebView?

    public init(id: UUID = UUID(), title: String = "Thẻ mới", url: String = "https://duckduckgo.com") {
        self.id = id
        self.title = title
        self.url = url
        self.stats = ProtectionStats()
    }
}

