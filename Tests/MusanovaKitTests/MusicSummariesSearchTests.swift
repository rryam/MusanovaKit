//
//  MusicSummariesSearchTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation
import MusicKit
import Testing

@testable import MusanovaKit

@Suite
struct MusicSummariesSearchTests {
  @Test
  func testMusicSummariesSearchEndpointURL() throws {
    let request = MusicSummarySearchRequest(developerToken: "")
    let endpointURL = try request.musicSummariesSearchEndpointURL
    let expectedURL = try #require(URL(string: "https://amp-api.music.apple.com/v1/me/music-summaries/search?period=year&fields[music-summaries]=period,year&include[music-summaries]=playlist"))
    #expect(endpointURL == expectedURL)
  }

  // MARK: - URL Construction Edge Cases

  @Test
  func testMusicSummariesSearchEndpointURLHasRequiredParameters() throws {
    let request = MusicSummarySearchRequest(developerToken: "")
    let endpointURL = try request.musicSummariesSearchEndpointURL
    let components = try #require(URLComponents(url: endpointURL, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)

    let queryDict = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })

    // Verify required parameters are present
    #expect(queryDict["period"] == "year")
    #expect(queryDict["fields[music-summaries]"] == "period,year")
    #expect(queryDict["include[music-summaries]"] == "playlist")
  }

  @Test
  func testMusicSummariesSearchEndpointURLStructure() throws {
    let request = MusicSummarySearchRequest(developerToken: "")
    let endpointURL = try request.musicSummariesSearchEndpointURL

    #expect(endpointURL.absoluteString.hasPrefix("https://amp-api.music.apple.com/v1/me/music-summaries/search"))
    #expect(endpointURL.path == "/v1/me/music-summaries/search")
  }
  @Test
  func testMusicSummariesDecoding() throws {
    let path = try #require(Bundle.module.path(forResource: "musicSummariesSearch", ofType: "json"))
    let dataURL = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: dataURL)
    let summaries = try JSONDecoder().decode(MusicSummarySearches.self, from: data)

    #expect(summaries.count == 1)
    let summary = try #require(summaries.first)
    #expect(summary.year == 2016)

    let playlist = try #require(Optional(summary.playlist))
    #expect(playlist.id == "pl.rp-bppRCjG6wWzB")
    #expect(playlist.name == "Replay 2016")
  }
}
