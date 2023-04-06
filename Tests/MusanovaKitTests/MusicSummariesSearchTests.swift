//
//  MusicSummariesSearchTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 04/04/23.
//

@testable import MusanovaKit
import MusicKit
import XCTest

final class MusicSummariesSearchTests: XCTestCase {
  func testMusicSummariesSearchEndpointURL() throws {
    let request = MusicSummarySearchRequest(developerToken: "")
    let endpointURL = try request.musicSummariesSearchEndpointURL
    let url = "https://amp-api.music.apple.com/v1/me/music-summaries/search?period=year&fields[music-summaries]=period,year&include[music-summaries]=playlist"
    XCTAssertEqualEndpoint(endpointURL, url)
  }

  func testMusicSummariesDecoding() throws {
    guard let path = Bundle.module.path(forResource: "musicSummariesSearch", ofType: "json") else {
      fatalError("replaySummaries.json not found")
    }

    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let summaries = try JSONDecoder().decode(MusicSummarySearches.self, from: data)

    XCTAssertEqual(summaries.count, 1)
    XCTAssertEqual(summaries.first?.year, 2016)

    // Assert that the `playlist` property of the `MusicSummarySearch` is decoded correctly
    let playlist = summaries.first?.playlist
    XCTAssertNotNil(playlist)
    XCTAssertEqual(playlist?.id, "pl.rp-bppRCjG6wWzB")
    XCTAssertEqual(playlist?.name, "Replay 2016")
  }
}
