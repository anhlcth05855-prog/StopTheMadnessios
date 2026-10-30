//
//  LinkUnshortener.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public final class LinkUnshortener: NSObject, URLSessionTaskDelegate {

    public static let shared = LinkUnshortener()

    private let shortenerDomains: Set<String> = [
        "bit.ly", "t.co", "tinyurl.com", "is.gd", "buff.ly", "ow.ly", "goo.gl", "rebrand.ly", "lnkd.in"
    ]

    private lazy var noRedirectSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 4.0
        configuration.timeoutIntervalForResource = 4.0
        configuration.httpShouldSetCookies = false
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    // Prevent automatic redirect following so we can inspect Location header
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // Stop automatic redirection
        completionHandler(nil)
    }

    public func isShortened(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString), let host = url.host?.lowercased() else {
            return false
        }
        return shortenerDomains.contains(host)
    }

    public func unshorten(_ rawUrl: String) async -> String {
        var currentUrl = rawUrl
        var maxHops = 5

        while maxHops > 0 && isShortened(currentUrl) {
            maxHops -= 1
            guard let targetURL = URL(string: currentUrl) else { break }

            var request = URLRequest(url: targetURL)
            request.httpMethod = "HEAD"
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")

            do {
                let (_, response) = try await noRedirectSession.data(for: request)
                if let httpResponse = response as? HTTPURLResponse,
                   (300...399).contains(httpResponse.statusCode),
                   let location = httpResponse.value(forHTTPHeaderField: "Location"),
                   !location.isEmpty {
                    if let resolved = URL(string: location, relativeTo: targetURL)?.absoluteString {
                        currentUrl = resolved
                    } else {
                        break
                    }
                } else {
                    break
                }
            } catch {
                break
            }
        }

        return currentUrl
    }
}

