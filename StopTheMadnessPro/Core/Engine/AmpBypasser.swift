//
//  AmpBypasser.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public struct AmpBypasser {

    public static func isAmpUrl(_ urlString: String) -> Bool {
        var u = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !u.lowercased().hasPrefix("http://") && !u.lowercased().hasPrefix("https://") {
            u = "https://" + u
        }

        guard let components = URLComponents(string: u),
              let host = components.host?.lowercased() else {
            return false
        }

        let path = components.path
        if host.contains("google.") && path.hasPrefix("/amp/") {
            return true
        }
        if host.hasSuffix(".ampproject.org") {
            return true
        }
        return false
    }

    public static func extractCanonicalUrl(_ ampUrl: String) -> String? {
        var u = ampUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !u.lowercased().hasPrefix("http://") && !u.lowercased().hasPrefix("https://") {
            u = "https://" + u
        }

        guard let components = URLComponents(string: u),
              let host = components.host?.lowercased() else {
            return nil
        }

        let path = components.path
        let querySuffix = components.query.map { "?\($0)" } ?? ""

        // Format: https://www.google.com/amp/s/example.com/path
        if host.contains("google.") && path.hasPrefix("/amp/") {
            var subPath = String(path.dropFirst("/amp/".count))
            let base: String
            if subPath.hasPrefix("s/") {
                base = "https://" + subPath.dropFirst(2)
            } else if subPath.lowercased().hasPrefix("http://") || subPath.lowercased().hasPrefix("https://") {
                base = subPath
            } else {
                base = "https://" + subPath
            }
            return base + querySuffix
        }

        // Format: https://example-com.cdn.ampproject.org/c/s/example.com/path
        if host.hasSuffix(".ampproject.org") {
            let base: String?
            if path.hasPrefix("/c/s/") {
                base = "https://" + path.dropFirst("/c/s/".count)
            } else if path.hasPrefix("/c/") {
                base = "http://" + path.dropFirst("/c/".count)
            } else if path.hasPrefix("/v/s/") {
                base = "https://" + path.dropFirst("/v/s/".count)
            } else {
                base = nil
            }
            return base.map { $0 + querySuffix }
        }

        return nil
    }
}

