//
//  ProtectionSettings.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public typealias CustomDomainRule = CustomRule

public struct ProtectionSettings: Codable, Equatable {
    public var masterEnabled: Bool = true
    public var restoreInteractions: Bool = true
    public var protectClipboard: Bool = true
    public var allowZoom: Bool = true
    public var blockTrackers: Bool = true
    public var bypassAmp: Bool = true
    public var unshortenLinks: Bool = true
    public var blockAutoplay: Bool = true
    public var backgroundAudio: Bool = true
    public var removeAnnoyances: Bool = true
    public var customRules: [String: CustomRule] = [:]

    // Compatibility fields
    public var controlVideoAudio: Bool = true
    public var forceLinksCurrentTab: Bool = false

    public init(
        masterEnabled: Bool = true,
        restoreInteractions: Bool = true,
        protectClipboard: Bool = true,
        allowZoom: Bool = true,
        blockTrackers: Bool = true,
        bypassAmp: Bool = true,
        unshortenLinks: Bool = true,
        blockAutoplay: Bool = true,
        backgroundAudio: Bool = true,
        removeAnnoyances: Bool = true,
        customRules: [String: CustomRule] = [:]
    ) {
        self.masterEnabled = masterEnabled
        self.restoreInteractions = restoreInteractions
        self.protectClipboard = protectClipboard
        self.allowZoom = allowZoom
        self.blockTrackers = blockTrackers
        self.bypassAmp = bypassAmp
        self.unshortenLinks = unshortenLinks
        self.blockAutoplay = blockAutoplay
        self.backgroundAudio = backgroundAudio
        self.removeAnnoyances = removeAnnoyances
        self.customRules = customRules
        self.controlVideoAudio = blockAutoplay || backgroundAudio
        self.forceLinksCurrentTab = false
    }
}
