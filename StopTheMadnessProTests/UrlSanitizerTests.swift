//
//  UrlSanitizerTests.swift
//  StopTheMadnessProTests
//
//  Created for StopTheMadness Pro iOS.
//

import XCTest
@testable import StopTheMadnessPro

final class UrlSanitizerTests: XCTestCase {

    func testStripTrackingParameters() {
        let dirtyUrl = "https://example.com/product?utm_source=facebook&utm_medium=cpc&utm_campaign=summer&fbclid=IwAR123&keep_this=123"
        let result = UrlSanitizer.sanitize(dirtyUrl)

        XCTAssertFalse(result.cleanedUrl.contains("utm_source"))
        XCTAssertFalse(result.cleanedUrl.contains("fbclid"))
        XCTAssertTrue(result.cleanedUrl.contains("keep_this=123"))
        XCTAssertEqual(result.removedParams.count, 4)
    }

    func testUnwrapGoogleRedirect() {
        let googleRedirect = "https://www.google.com/url?q=https://real-target.com/page%3Futm_source%3Dgoogle&sa=U"
        let result = UrlSanitizer.sanitize(googleRedirect)

        XCTAssertTrue(result.wasRedirectResolved)
        XCTAssertTrue(result.cleanedUrl.contains("real-target.com/page"))
        XCTAssertFalse(result.cleanedUrl.contains("utm_source"))
    }

    func testUnwrapFacebookRedirect() {
        let fbRedirect = "https://l.facebook.com/l.php?u=https%3A%2F%2Fclean-site.org%2Fnews&h=AT0"
        let result = UrlSanitizer.sanitize(fbRedirect)

        XCTAssertTrue(result.wasRedirectResolved)
        XCTAssertTrue(result.cleanedUrl.contains("clean-site.org/news"))
    }

    func testUnwrapRedditRedirect() {
        let redditRedirect = "https://out.reddit.com?url=https%3A%2F%2Fgithub.com%2Fproject"
        let result = UrlSanitizer.sanitize(redditRedirect)

        XCTAssertTrue(result.wasRedirectResolved)
        XCTAssertTrue(result.cleanedUrl.contains("github.com/project"))
    }
}

