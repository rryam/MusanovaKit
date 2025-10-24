//
//  MusicLyricsRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 26/05/24.
//

import Foundation

/// Represents an error response from the Apple Music API.
public struct MusicErrorResponse: Codable {
  let errors: [MusicError]
}

/// Represents a single error from the Apple Music API.
public struct MusicError: Codable {
  let id: String
  let title: String
  let detail: String
  let status: String
  let code: String
}

/// Errors that can occur during lyrics operations.
public enum LyricsError: Error {
  case apiError(String)
}

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
  /// - Returns: A `LyricsResponse` object.
  func response(countryCode: String? = nil) async throws -> MusicLyricsResponse {
    let url = try await lyricsEndpointURL(countryCode: countryCode)
    print(url)
    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
    let response = try await request.response()

    if let jsonString = String(data: response.data, encoding: .utf8) {
      print("Raw response received:")
      print(jsonString)
    }

    // First try to decode as error response
    if let errorResponse = try? JSONDecoder().decode(MusicErrorResponse.self, from: response.data) {
      if let error = errorResponse.errors.first {
        throw LyricsError.apiError(error.detail)
      }
    }

    // If not an error, try to decode as successful response
    let lyricsResponse = try JSONDecoder().decode(MusicLyricsResponse.self, from: response.data)
    return lyricsResponse
  }
}

extension MusicLyricsRequest {
  internal func lyricsEndpointURL(countryCode: String? = nil) async throws -> URL {
    var components = AppleMusicAMPURLComponents()

    let resolvedCountryCode: String
    if let countryCode = countryCode {
      resolvedCountryCode = countryCode
    } else {
      resolvedCountryCode = try await MusicDataRequest.currentCountryCode
    }

    components.path = "catalog/\(resolvedCountryCode)/songs/\(songID.rawValue)/syllable-lyrics"

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }
}

public extension MCatalog {
  /// Fetches and parses the lyrics for a specified song.
  ///
  /// This method performs the following steps:
  /// 1. Creates a `MusicLyricsRequest` using the provided song ID and developer token.
  /// 2. Sends the request to fetch the lyrics data.
  /// 3. Extracts the TTML (Timed Text Markup Language) string from the response.
  /// 4. Parses the TTML string into a structured `LyricParagraphs` object.
  ///
  /// - Parameters:
  ///   - song: The `Song` object representing the song for which to fetch lyrics.
  ///     This object must have a valid `id` property.
  ///   - developerToken: A string containing the developer token used to authorize the request.
  ///     This token must be valid and have the necessary permissions to fetch lyrics.
  ///
  /// - Returns: A `LyricParagraphs` object containing the parsed lyrics.
  ///   This object is an array of `LyricParagraph` structures, each representing
  ///   a section of the song's lyrics.
  ///
  /// - Throws: This method can throw errors in the following situations:
  ///   - `MusicLyricsRequest.Error`: If there's an error creating or sending the lyrics request.
  ///   - `DecodingError`: If the response cannot be properly decoded into the expected format.
  ///   - `URLError`: If there's a network-related error during the request.
  ///   - `LyricsParser.Error`: If there's an error parsing the TTML string into `LyricParagraphs`.
  ///
  /// - Note: If no lyrics are found for the specified song, this method returns an empty `LyricParagraphs` array
  ///   instead of throwing an error.
  ///
  /// - Important: Ensure that you have the necessary permissions and a valid developer token
  ///   before calling this method. Unauthorized or incorrect usage may result in errors or empty results.
  static func lyrics(for song: Song, developerToken: String) async throws -> LyricParagraphs {
    let request = MusicLyricsRequest(songID: song.id, developerToken: developerToken)
    let response = try await request.response()

    guard let lyricsString = response.data.first?.attributes.ttml else {
      return []
    }

    let parser = LyricsParser()
    return parser.parse(lyricsString)
  }
}
