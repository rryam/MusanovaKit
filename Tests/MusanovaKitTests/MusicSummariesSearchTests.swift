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
  @Test
  func testMusicSummariesDecoding() throws {
    let path = try #require(Bundle.module.path(forResource: "musicSummariesSearch", ofType: "json"))
    let dataURL = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: dataURL)
    let summaries = try JSONDecoder().decode(MusicSummarySearches.self, from: data)

    #expect(summaries.count == 1)
    let summary = try #require(summaries.first)
    #expect(summary.year == 2016)

    let playlist = summary.playlist
    #expect(playlist.id == "pl.rp-bppRCjG6wWzB")
    #expect(playlist.name == "Replay 2016")
  }
}
