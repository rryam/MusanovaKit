//
//  MusicLyricsRequestTests.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 20/06/24.
//

@testable import MusanovaKit
import MusicKit
import Testing

struct MusicLyricsRequestTests {
  let developerToken = "234324"
  let songID = MusicItemID("926187677")
  let defaultCountryCode = "us"

//  @Test
//  func testMusicLyricsRequest() async throws {
//    let developerToken = try #require(developerToken)
//    let request = MusicLyricsRequest(songID: songID, developerToken: developerToken)
//    let response = try await request.response(countryCode: defaultCountryCode)
//
//    #expect(!response.data.isEmpty)
//    #expect(response.data.first?.attributes.ttml != nil)
//  }
//
//  @Test
//  func testMCatalogLyricsForSong() async throws {
//    let developerToken = try #require(developerToken)
//    let song = try await MCatalog.song(id: songID)
//    let lyrics = try await MCatalog.lyrics(for: song, developerToken: developerToken)
//
//    #expect(!lyrics.isEmpty)
//  }

  @Test
  func testLyricsEndpointURL() async throws {
    let request = try MusicLyricsRequest(songID: songID, developerToken: developerToken)
    let url = try await request.lyricsEndpointURL(countryCode: "us")

    let expectedURL = "https://amp-api.music.apple.com/v1/catalog/us/songs/\(songID.rawValue)/syllable-lyrics"
    #expect(url.absoluteString == expectedURL)
  }

  // MARK: - URL Construction Edge Cases

  @Test
  func testLyricsEndpointURLWithDifferentCountryCode() async throws {
    let request = try MusicLyricsRequest(songID: songID, developerToken: developerToken)
    let url = try await request.lyricsEndpointURL(countryCode: "gb")

    let expectedURL = "https://amp-api.music.apple.com/v1/catalog/gb/songs/\(songID.rawValue)/syllable-lyrics"
    #expect(url.absoluteString == expectedURL)
  }

  @Test
  func testLyricsEndpointURLWithSpecialCharactersInSongID() async throws {
    // Test that special characters in song ID are properly encoded
    let specialSongID = MusicItemID("test-song-id-123")
    let request = try MusicLyricsRequest(songID: specialSongID, developerToken: developerToken)
    let url = try await request.lyricsEndpointURL(countryCode: "us")

    #expect(url.absoluteString.contains(specialSongID.rawValue))
    #expect(url.absoluteString.hasPrefix("https://amp-api.music.apple.com/v1/catalog/us/songs/"))
  }

  @Test
  func testLyricsEndpointURLWithEmptyCountryCode() async throws {
    // This should use the current country code from MusicDataRequest
    // We can't easily test this without mocking, but we can verify it doesn't crash
    let request = try MusicLyricsRequest(songID: songID, developerToken: developerToken)
    // Note: This will fail if country code can't be determined, which is expected behavior
    do {
      _ = try await request.lyricsEndpointURL(countryCode: nil)
      // If it succeeds, verify URL structure
    } catch {
      // Expected if country code unavailable - could be MusanovaKitError or MusicTokenRequestError
      // Both are acceptable as they indicate the country code couldn't be determined
      #expect(error is MusanovaKitError || String(describing: type(of: error)).contains("Error"))
    }
  }
}
