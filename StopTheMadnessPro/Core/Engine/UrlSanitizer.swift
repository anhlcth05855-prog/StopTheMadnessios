//
//  UrlSanitizer.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public struct UrlSanitizer {

    public static let trackingParameters: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "utm_id",
        "fbclid", "gclid", "gbraid", "wbraid", "msclkid", "mc_eid", "igshid", "si",
        "_ga", "_gl", "yclid", "trk", "ref", "ref_src", "ref_url", "mkt_tok",
        "vgo_ee", "vero_id", "wickedid", "twclid", "pd_rd_r", "pd_rd_w", "pd_rd_wg",
        "pf_rd_r", "pf_rd_p", "spreportid", "spjobid"
    ]

    public struct SanitizeResult: Equatable {
        public let cleanedUrl: String
        public let removedParams: [String]
        public let wasRedirectResolved: Bool

        public init(cleanedUrl: String, removedParams: [String], wasRedirectResolved: Bool = false) {
            self.cleanedUrl = cleanedUrl
            self.removedParams = removedParams
            self.wasRedirectResolved = wasRedirectResolved
        }
    }

    public static func sanitize(_ rawUrl: String) -> SanitizeResult {
        var urlToProcess = rawUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlToProcess.isEmpty {
            return SanitizeResult(cleanedUrl: rawUrl, removedParams: [], wasRedirectResolved: false)
        }

        if !urlToProcess.lowercased().hasPrefix("http://") && !urlToProcess.lowercased().hasPrefix("https://") {
            urlToProcess = "https://" + urlToProcess
        }

        guard var components = URLComponents(string: urlToProcess) else {
            return SanitizeResult(cleanedUrl: rawUrl, removedParams: [], wasRedirectResolved: false)
        }

        var wasRedirectResolved = false

        // 1. Unwrap redirection wrappers (Google, Facebook, Reddit)
        let host = (components.host ?? "").lowercased()
        let queryItems = components.queryItems ?? []

        if host.contains("google.") && components.path == "/url" {
            if let target = queryItems.first(where: { $0.name == "q" || $0.name == "url" })?.value,
               !target.isEmpty,
               let targetComponents = URLComponents(string: target) {
                components = targetComponents
                wasRedirectResolved = true
            }
        } else if host.contains("facebook.com") && components.path.contains("/l.php") {
            if let target = queryItems.first(where: { $0.name == "u" })?.value,
               !target.isEmpty,
               let targetComponents = URLComponents(string: target) {
                components = targetComponents
                wasRedirectResolved = true
            }
        } else if host.contains("out.reddit.com") {
            if let target = queryItems.first(where: { $0.name == "url" })?.value,
               !target.isEmpty,
               let targetComponents = URLComponents(string: target) {
                components = targetComponents
                wasRedirectResolved = true
            }
        }

        // 2. Strip tracking query parameters
        guard let currentItems = components.queryItems, !currentItems.isEmpty else {
            let finalUrl = components.string ?? rawUrl
            return SanitizeResult(cleanedUrl: finalUrl, removedParams: [], wasRedirectResolved: wasRedirectResolved)
        }

        var removed: [String] = []
        var remaining: [URLQueryItem] = []

        for item in currentItems {
            if isTrackingParam(item.name) {
                removed.append(item.name)
            } else {
                remaining.append(item)
            }
        }

        components.queryItems = remaining.isEmpty ? nil : remaining
        let cleanedUrl = components.string ?? rawUrl
        return SanitizeResult(cleanedUrl: cleanedUrl, removedParams: removed, wasRedirectResolved: wasRedirectResolved)
    }

    public static func isTrackingParam(_ name: String) -> Bool {
        let lower = name.lowercased()
        if trackingParameters.contains(lower) { return true }
        if lower.hasPrefix("utm_") { return true }
        if lower.hasPrefix("fb_") { return true }
        if lower.hasPrefix("ga_") { return true }
        return false
    }

    public static func extractAllQueryParams(_ rawUrl: String) -> [(name: String, value: String, isTracker: Bool)] {
        guard let components = URLComponents(string: rawUrl), let queryItems = components.queryItems else {
            return []
        }
        return queryItems.map {
            (name: $0.name, value: $0.value ?? "", isTracker: isTrackingParam($0.name))
        }
    }
}

