//
//  MSummariesRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation

/// A request that your app uses to fetch music summaries for the user's library.
///
/// Use this request to fetch music summary data for the user's library, such as their most frequently played songs, albums, and playlists over the course of a year.
///
/// After creating an instance of this request, call the `response()` method to retrieve the music summary data for the user's library.
struct MSummariesRequest {

  /// The developer token used to authorize the request.
  private var developerToken: String

  /// Initializes a new `MSummariesRequest` instance.
  ///
  /// - Parameter developerToken: The priviledged developer token used to authorize the request.
  init(developerToken: String) {
    self.developerToken = developerToken
  }

  /// Fetches music summaries for the user's library.
  ///
  /// - Returns: An instance of `MReplaySummaries` containing the music summary data for the user's library.
  /// - Throws: An error of type `URLError` or `DecodingError` if the request fails or the response cannot be decoded.
  ///
  /// Example usage:
  ///
  ///     let request = MSummariesRequest(developerToken: "your_developer_token")
  ///     do {
  ///         let summaries = try await request.response()
  ///
  ///         for summary in summaries {
  ///             print("Year: \(summary.year), Playlist: \(summary.playlist)")
  ///         }
  ///     } catch {
  ///         print(error)
  ///     }
  func response() async throws -> MReplaySummaries {
    let url = try musicSummariesEndpointURL
    let request = MPriviledgedDataRequest(url: url, developerToken: developerToken)
    let response = try await request.response()
    return try JSONDecoder().decode(MReplaySummaries.self, from: response.data)
  }
}

extension MSummariesRequest {
  internal var musicSummariesEndpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/music-summaries/search"

      components.queryItems = [
        URLQueryItem(name: "period", value: "year"),
        URLQueryItem(name: "fields[music-summaries]", value: "period,year"),
        URLQueryItem(name: "include[music-summaries]", value: "playlist")
      ]

      guard let url = components.url else {
        throw URLError(.badURL)
      }
      return url
    }
  }
}
