//
//  AmpBypasserTests.swift
//  StopTheMadnessProTests
//
//  Created for StopTheMadness Pro iOS.
//

import XCTest
@testable import StopTheMadnessPro

final class AmpBypasserTests: XCTestCase {

    func testDetectGoogleAmp() {
        let ampUrl = "https://www.google.com/amp/s/www.theverge.com/article"
        XCTAssertTrue(AmpBypasser.isAmpUrl(ampUrl))

        let canonical = AmpBypasser.extractCanonicalUrl(ampUrl)
        XCTAssertEqual(canonical, "https://www.theverge.com/article")
    }

    func testDetectAmpprojectCdn() {
        let cdnAmp = "https://theverge-com.cdn.ampproject.org/c/s/theverge.com/article"
        XCTAssertTrue(AmpBypasser.isAmpUrl(cdnAmp))

        let canonical = AmpBypasser.extractCanonicalUrl(cdnAmp)
        XCTAssertEqual(canonical, "https://theverge.com/article")
    }

    func testNonAmpUrl() {
        let normalUrl = "https://www.theverge.com/article"
        XCTAssertFalse(AmpBypasser.isAmpUrl(normalUrl))
        XCTAssertNil(AmpBypasser.extractCanonicalUrl(normalUrl))
    }
}
