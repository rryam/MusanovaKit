//
//  MusicSummarySearchRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation

public extension MReplay {
  /// Searches music summaries for the user's library.
  ///
  /// Use this method to search music summary playlists over the years.
  ///
  /// Example usage:
  ///
  ///     do {
  ///       let summaries = try await MReplay.searchSummaries(developerToken: "your_developer_token")
  ///
  ///       for summary in summaries {
  ///         print("Year: \(summary.year), Playlist: \(summary.playlist)")
  ///       }
  ///     } catch {
  ///       print(error)
  ///     }
  ///
  /// - Parameters:
  ///   - developerToken: The developer token used to authorize the request.
  ///
  /// - Returns: An instance of `MusicSummarySearches` containing the search results for music summary data for the user's library.
  ///
  /// - Throws: An error of type `URLError` or `DecodingError` if the request fails or the response cannot be decoded.
  static func searchSummaries(developerToken: String) async throws -> MusicSummarySearches {
    let request = MusicSummarySearchRequest(developerToken: developerToken)
    let response = try await request.response()
    return response
  }
}

/// A request that your app uses to fetch music summaries for the user's library.
///
/// Use this request to fetch music summary data for the user's library, such as their most frequently played songs, albums, and playlists over the course of a year.
/// After creating an instance of this request, call the `response()` method to retrieve the music summary data for the user's library.
struct MusicSummarySearchRequest {

  /// The developer token used to authorize the request.
  private var developerToken: String

  /// Initializes a new `MusicSummarySearchRequest` instance.
  ///
  /// - Parameter developerToken: The privileged developer token used to authorize the request.
  init(developerToken: String) {
    self.developerToken = developerToken
  }

  /// Fetches music summaries for the user's library.
  ///
  /// - Returns: An instance of `MusicSummarySearches` containing the music summary data for the user's library.
  /// - Throws: An error of type `URLError` or `DecodingError` if the request fails or the response cannot be decoded.
  ///
  /// Example usage:
  ///
  ///     let request = MusicSummarySearchRequest(developerToken: "your_developer_token")
  ///     do {
  ///       let summaries = try await request.response()
  ///
  ///       for summary in summaries {
  ///         print("Year: \(summary.year), Playlist: \(summary.playlist)")
  ///       }
  ///     } catch {
  ///       print(error)
  ///     }
  func response() async throws -> MusicSummarySearches {
    let url = try musicSummariesSearchEndpointURL
    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
    let response = try await request.response()
    return try JSONDecoder().decode(MusicSummarySearches.self, from: response.data)
  }
}

extension MusicSummarySearchRequest {
  internal var musicSummariesSearchEndpointURL: URL {
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
