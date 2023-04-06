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

  func testMusicSummaryMilestonesDecoding() throws {
    guard let path = Bundle.module.path(forResource: "musicSummariesMilestones", ofType: "json") else {
      fatalError("musicSummaryMilestones.json not found")
    }

    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let response = try JSONDecoder().decode(MusicSummaryMilestonesResponse.self, from: data)

    XCTAssertEqual(response.milestones.count, 1)

    guard let milestone = response.milestones.first else {
      XCTFail("Response is empty.")
      return
    }

    let id = milestone.id
    XCTAssertEqual(id, "year-2023-listen-time-minutes-5000")

    // Assert that the `listenTimeInMinutes` property of the `MusicSummaryMilestone` is decoded correctly
    let listenTime = milestone.listenTimeInMinutes
    XCTAssertEqual(listenTime, 5955)

    // Assert that the `dateReached` property of the `MusicSummaryMilestone` is decoded correctly
    let dateReached = milestone.dateReached
    XCTAssertEqual(dateReached, "2023-02-03")

    // Assert that the `value` property of the `MusicSummaryMilestone` is decoded correctly
    let value = milestone.value
    XCTAssertEqual(value, "5000")

    // Assert that the `kind` property of the `MusicSummaryMilestone` is decoded correctly
    let kind = milestone.kind
    XCTAssertEqual(kind, .listenTime)

    // Assert that the `topSongs` property of the `MusicSummaryMilestone` is decoded correctly
    let topSongs = milestone.topSongs
    XCTAssertEqual(topSongs.count, 3)
    XCTAssertEqual(topSongs.first?.id, "1625328892")

    // Assert that the `topArtists` property of the `MusicSummaryMilestone` is decoded correctly
    let topArtists = milestone.topArtists
    XCTAssertEqual(topArtists.count, 3)
    XCTAssertEqual(topArtists.first?.id, "1258279972")

    // Assert that the `topAlbums` property of the `MusicSummaryMilestone` is decoded correctly
    let topAlbums = milestone.topAlbums
    XCTAssertEqual(topAlbums.count, 3)
    XCTAssertEqual(topAlbums.first?.id, "1649039960")
  }
}
