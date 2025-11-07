//
//  MusicLyricsRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 26/05/24.
//

import Foundation

/// Represents an error response from the Apple Music API.
public struct MusicErrorResponse: Codable, Sendable {
  let errors: [MusicError]
}

/// Represents a single error from the Apple Music API.
public struct MusicError: Codable, Sendable {
  let id: String
  let title: String
  let detail: String
  let status: String
  let code: String
}

/// A request object used to fetch lyrics for a specified song.
struct MusicLyricsRequest {
  /// The identifier of the song.
  let songID: MusicItemID

  /// The privileged developer token used to authorize the request.
  let developerToken: String

  /// Sends the request and returns a response object containing the fetched lyrics.
  ///
  /// - Returns: A `LyricsResponse` object.
  func response(countryCode: String? = nil) async throws -> MusicLyricsResponse {
    let url = try await lyricsEndpointURL(countryCode: countryCode)
    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
    
    do {
      let response = try await request.response()

      if response.data.isEmpty {
        throw MusanovaKitError.emptyResponse
      }

      // Check for API error responses first
      if let errorResponse = try? JSONDecoder().decode(MusicErrorResponse.self, from: response.data),
         !errorResponse.errors.isEmpty {
        let error = errorResponse.errors.first!
        throw MusanovaKitError.apiError(
          message: error.detail,
          code: error.code,
          status: error.status
        )
      }

      guard String(data: response.data, encoding: .utf8) != nil else {
        throw MusanovaKitError.invalidResponseFormat(description: "Response data is not valid UTF-8")
      }

      do {
        let lyricsResponse = try JSONDecoder().decode(MusicLyricsResponse.self, from: response.data)
        return lyricsResponse
      } catch let decodingError as DecodingError {
        throw MusanovaKitError.decodingError(decodingError.localizedDescription)
      } catch {
        throw MusanovaKitError.decodingError(error.localizedDescription)
      }
    } catch let error as MusanovaKitError {
      throw error
    } catch let error as URLError {
      throw MusanovaKitError.networkError(error.localizedDescription)
    } catch {
      throw MusanovaKitError.networkError(error.localizedDescription)
    }
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
      throw MusanovaKitError.invalidURL(description: "Failed to construct lyrics endpoint URL with path: \(components.path)")
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
  ///   - `MusanovaKitError.apiError`: If the API returns an error response.
  ///   - `MusanovaKitError.emptyResponse`: If the API returns an empty response.
  ///   - `MusanovaKitError.invalidResponseFormat`: If the response format is invalid.
  ///   - `MusanovaKitError.invalidURL`: If the request URL could not be constructed.
  ///   - `MusanovaKitError.decodingError`: If the response cannot be properly decoded.
  ///   - `MusanovaKitError.networkError`: If a network error occurs during the request.
  ///   - `MusanovaKitError.countryCodeUnavailable`: If the country code cannot be determined.
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
