//
//  MusicLyricsRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 26/05/24.
//

import Foundation

/// A request object used to fetch lyrics for a specified song.
struct MusicLyricsRequest {

  /// The identifier of the song.
  let songID: MusicItemID

  /// The privileged developer token used to authorize the request.
  let developerToken: String

  /// Initializes a new `MusicLyricsRequest`.
  ///
  /// - Parameters:
  ///   - songID: The identifier of the song.
  ///   - developerToken: The privileged developer token used to authorize the request.
  init(songID: MusicItemID, developerToken: String) {
    self.songID = songID
    self.developerToken = developerToken
  }

  /// Sends the request and returns a response object containing the fetched lyrics.
  ///
  /// - Returns: A `MusicLyricsResponse` object.
  func response() async throws -> MusicLyricsResponse {
    let url = try await lyricsEndpointURL
    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
    let response = try await request.response()
    let lyricsResponse = try JSONDecoder().decode(MusicLyricsResponse.self, from: response.data)
    return lyricsResponse
  }
}

extension MusicLyricsRequest {
  private var lyricsEndpointURL: URL {
    get async throws {
      var components = AppleMusicAMPURLComponents()
      let countryCode = try await MusicDataRequest.currentCountryCode
      components.path = "/v1/catalog/\(countryCode)/songs/\(songID.rawValue)/syllable-lyrics"

      guard let url = components.url else {
        throw URLError(.badURL)
      }

      return url
    }
  }
}

public extension MCatalog {

  /// Fetches the lyrics for a specified song.
  ///
  /// - Parameters:
  ///   - song: The song to fetch the lyrics for.
  ///   - developerToken: The developer token used to authorize the request.
  ///
  /// - Returns: The lyrics for the specified song.
  ///
  /// - Throws: An error if the request fails or the response cannot be decoded.
  static func lyrics(for song: Song, developerToken: String) async throws -> String {
    let request = MusicLyricsRequest(songID: song.id, developerToken: developerToken)
    let response = try await request.response()

    guard let lyrics = response.data.first?.attributes.ttml else {
      throw URLError(.badServerResponse)
    }

    return lyrics
  }
}
