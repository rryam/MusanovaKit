//
//  MusicSummarySearchRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation

public extension MSummaries {
  /// Searches music summaries for the user's library.
  ///
  /// Use this method to search music summary playlists over the years.
  ///
  /// Example usage:
  ///
  ///     do {
  ///       let summaries = try await MSummaries.search(developerToken: "your_developer_token")
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
  /// - Throws: `MusanovaKitError` if the request fails or the response cannot be decoded.
  static func search(developerToken: String) async throws -> MusicSummarySearches {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    let request = try MusicSummarySearchRequest(developerToken: developerToken)
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
  /// - Parameter developerToken: The privileged developer token used to authorize the request. Must not be empty.
  /// - Throws: `MusanovaKitError.missingDeveloperToken` if the developer token is empty.
  init(developerToken: String) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.developerToken = developerToken
  }

  /// Fetches music summaries for the user's library.
  ///
  /// - Returns: An instance of `MusicSummarySearches` containing the music summary data for the user's library.
  /// - Throws: `MusanovaKitError` if the request fails or the response cannot be decoded.
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
    do {
      let url = try musicSummariesSearchEndpointURL
      let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
      let response = try await request.response()

      do {
        return try JSONDecoder().decode(MusicSummarySearches.self, from: response.data)
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
        throw MusanovaKitError.invalidURL(description: "Failed to construct search endpoint URL with path: \(components.path)")
      }
      return url
    }
  }
}
