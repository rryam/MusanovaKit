//
//  MusicLyricsRequestTests.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 20/06/24.
//

import Testing
import MusicKit
@testable import MusanovaKit

struct MusicLyricsRequestTests {
  let developerToken = MusanovaKit.priviledgedDeveloperToken
  let songID = MusicItemID("926187677")
  let defaultCountryCode = "us"

  @Test func testMusicLyricsRequest() async throws {
    let developerToken = try #require(developerToken)
    let request = MusicLyricsRequest(songID: songID, developerToken: developerToken)
    let response = try await request.response(countryCode: defaultCountryCode)

    #expect(response.data.count > 0)
    #expect(response.data.first?.attributes.ttml != nil)
  }

  @Test func testMCatalogLyricsForSong() async throws {
    let developerToken = try #require(developerToken)
    let song = try await MCatalog.song(id: songID)
    let lyrics = try await MCatalog.lyrics(for: song, developerToken: developerToken)

    #expect(!lyrics.isEmpty)
  }

  @Test func testLyricsEndpointURL() async throws {
    let developerToken = try #require(developerToken)
    let request = MusicLyricsRequest(songID: songID, developerToken: developerToken)
    let url = try await request.lyricsEndpointURL(countryCode: "us")

    let expectedURL = "https://amp-api.music.apple.com/v1/catalog/us/songs/\(songID.rawValue)/syllable-lyrics"
    #expect(url.absoluteString == expectedURL)
  }
}
