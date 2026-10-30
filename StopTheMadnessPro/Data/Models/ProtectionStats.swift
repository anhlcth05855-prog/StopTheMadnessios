//
//  ProtectionStats.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import Foundation

public struct ProtectionStats: Codable, Equatable {
    public var trackersRemoved: Int = 0
    public var ampBypassed: Int = 0
    public var autoplayBlocked: Int = 0
    public var annoyancesBlocked: Int = 0

    public init(
        trackersRemoved: Int = 0,
        ampBypassed: Int = 0,
        autoplayBlocked: Int = 0,
        annoyancesBlocked: Int = 0
    ) {
        self.trackersRemoved = trackersRemoved
        self.ampBypassed = ampBypassed
        self.autoplayBlocked = autoplayBlocked
        self.annoyancesBlocked = annoyancesBlocked
    }

    public mutating func reset() {
        trackersRemoved = 0
        ampBypassed = 0
        autoplayBlocked = 0
        annoyancesBlocked = 0
    }
}
