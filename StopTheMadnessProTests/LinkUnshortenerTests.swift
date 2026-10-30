//
//  LinkUnshortenerTests.swift
//  StopTheMadnessProTests
//
//  Created for StopTheMadness Pro iOS.
//

import XCTest
@testable import StopTheMadnessPro

final class LinkUnshortenerTests: XCTestCase {

    func testDetectShortenerDomains() {
        XCTAssertTrue(LinkUnshortener.shared.isShortened("https://bit.ly/3xyzABC"))
        XCTAssertTrue(LinkUnshortener.shared.isShortened("https://t.co/999111"))
        XCTAssertTrue(LinkUnshortener.shared.isShortened("https://tinyurl.com/fastlink"))
        XCTAssertFalse(LinkUnshortener.shared.isShortened("https://apple.com/ios"))
    }
}
