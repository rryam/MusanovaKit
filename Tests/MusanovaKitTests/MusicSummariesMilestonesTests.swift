//
//  MusicSummariesMilestonesTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 07/04/23.
//

@testable import MusanovaKit
import MusicKit
import XCTest

final class MusicSummariesMilestonesTests: XCTestCase {
  func testMusicSummariesMilestonesEndpointURL() throws {
    let request = MusicSummaryMilestonesRequest(year: 2022, types: [], developerToken: "")
    let endpointURL = try request.musicSummariesMilestonesEndpointURL
    let url = "https://amp-api.music.apple.com/v1/me/music-summaries/milestones?ids=year-2022"
    XCTAssertEqualEndpoint(endpointURL, url)
  }
}
