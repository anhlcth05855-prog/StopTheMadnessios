//
//  ProtectionSettings.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public struct ProtectionSettings: Codable, Equatable {
    public var masterEnabled: BooleanLiteralType = true
    public var restoreInteractions: Bool = true
    public var blockTrackers: Bool = true
    public var controlVideoAudio: Bool = true
    public var removeAnnoyances: Bool = true
    public var blockAutoplay: Bool = true
    public var backgroundAudio: Bool = true
    public var bypassAmp: Bool = true
    public var unshortenLinks: Bool = true
    public var forceLinksCurrentTab: Bool = false
    public var allowZoom: Bool = true
    public var protectClipboard: Bool = true

    public init(
        masterEnabled: Bool = true,
        restoreInteractions: Bool = true,
        blockTrackers: Bool = true,
        controlVideoAudio: Bool = true,
        removeAnnoyances: Bool = true,
        blockAutoplay: Bool = true,
        backgroundAudio: Bool = true,
        bypassAmp: Bool = true,
        unshortenLinks: Bool = true,
        forceLinksCurrentTab: Bool = false,
        allowZoom: Bool = true,
        protectClipboard: Bool = true
    ) {
        self.masterEnabled = masterEnabled
        self.restoreInteractions = restoreInteractions
        self.blockTrackers = blockTrackers
        self.controlVideoAudio = controlVideoAudio
        self.removeAnnoyances = removeAnnoyances
        self.blockAutoplay = blockAutoplay
        self.backgroundAudio = backgroundAudio
        self.bypassAmp = bypassAmp
        self.unshortenLinks = unshortenLinks
        self.forceLinksCurrentTab = forceLinksCurrentTab
        self.allowZoom = allowZoom
        self.protectClipboard = protectClipboard
    }
}
