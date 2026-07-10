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
    let request = try MusicSummarySearchRequest(developerToken: "test_token")
    let endpointURL = try request.musicSummariesSearchEndpointURL
    let expectedURL = try #require(URL(string: "https://amp-api.music.apple.com/v1/me/music-summaries/search?period=year&fields[music-summaries]=period,year&include[music-summaries]=playlist"))
    #expect(endpointURL == expectedURL)
  }

  // MARK: - URL Construction Edge Cases

  @Test
  func testMusicSummariesSearchEndpointURLHasRequiredParameters() throws {
    let request = try MusicSummarySearchRequest(developerToken: "test_token")
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
    let request = try MusicSummarySearchRequest(developerToken: "test_token")
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

  @Test
  func decodesReplayPlaylistWithoutCuratorSocialHandle() throws {
    let path = try #require(Bundle.module.path(forResource: "musicSummariesSearch", ofType: "json"))
    let fixtureData = try Data(contentsOf: URL(fileURLWithPath: path))
    let fixture = try #require(JSONSerialization.jsonObject(with: fixtureData) as? [String: Any])
    var data = try #require(fixture["data"] as? [[String: Any]])
    var summary = try #require(data.first)
    var relationships = try #require(summary["relationships"] as? [String: Any])
    var playlistRelationship = try #require(relationships["playlist"] as? [String: Any])
    var playlists = try #require(playlistRelationship["data"] as? [[String: Any]])
    var playlist = try #require(playlists.first)
    var attributes = try #require(playlist["attributes"] as? [String: Any])

    attributes.removeValue(forKey: "curatorSocialHandle")
    playlist["attributes"] = attributes
    playlists[0] = playlist
    playlistRelationship["data"] = playlists
    relationships["playlist"] = playlistRelationship
    summary["relationships"] = relationships
    data[0] = summary

    var liveResponse = fixture
    liveResponse["data"] = data
    let liveData = try JSONSerialization.data(withJSONObject: liveResponse)
    let normalizedData = try ReplayPlaylistResponseNormalizer.normalize(liveData)
    let summaries = try JSONDecoder().decode(MusicSummarySearches.self, from: normalizedData)

    #expect(summaries.first?.year == 2016)
    #expect(summaries.first?.playlist.name == "Replay 2016")
  }
}
