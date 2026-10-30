//
//  CustomRule.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public struct CustomRule: Codable, Identifiable, Equatable {
    public var id: String { domain }
    public var domain: String
    public var customCss: String
    public var customJs: String
    public var enabled: Bool

    public init(domain: String, customCss: String = "", customJs: String = "", enabled: Bool = true) {
        self.domain = domain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.customCss = customCss
        self.customJs = customJs
        self.enabled = enabled
    }
}

