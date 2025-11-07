//
//  MusicLibraryPinsRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation

/// Represents the format for resource responses.
public enum ResourceFormat: String, Sendable {
  /// Map format for resource responses.
  case map
}

/// Represents metadata types for library pins.
public enum LibraryPinMeta: String, Sendable {
  /// Library pin metadata type.
  case libraryPin
}

/// A request that your app uses to fetch pinned items from the user's Apple Music library.
///
/// Use this request to fetch music content that the user has pinned in their library.
/// Pinned items represent content that users have marked as favorites or important,
/// and may appear prominently in the Apple Music interface.
///
/// Example usage:
///
///     let request = MusicLibraryPinsRequest(developerToken: token)
///     let response = try await request.response()
///     for pinRef in response.data {
///         print("Pinned: \(pinRef.id) of type \(pinRef.type)")
///     }
///
public struct MusicLibraryPinsRequest {
  /// The privileged developer token used to authorize the request.
  private let developerToken: String

  /// Whether to include artwork URLs in the response.
  public var includeArtworkURLs: Bool = true

  /// Fields to include for artists in the response.
  public var artistFields: [String] = ["artwork"]

  /// Response format for resources.
  public var resourceFormat: ResourceFormat = .map

  /// Relationships to include for library artists.
  public var libraryArtistIncludes: [String] = ["catalog"]

  /// Relationships to include for library music videos.
  public var libraryMusicVideoIncludes: [String] = ["albums", "playlists", "artists"]

  /// Relationships to include for library songs.
  public var librarySongIncludes: [String] = ["albums", "playlists", "artists"]

  /// The language/locale for the request.
  public var language: String = "en-GB"

  /// Maximum number of pins to return.
  public var limit: Int = 25

  /// Metadata type for the pins.
  public var meta: LibraryPinMeta = .libraryPin

  /// Initializes a new pins request.
  ///
  /// - Parameter developerToken: The privileged developer token for authentication.
  public init(developerToken: String) {
    self.developerToken = developerToken
  }

  /// Fetches pinned items from the user's library.
  ///
  /// - Returns: A `MusicLibraryPinsResponse` containing the pinned items.
  /// - Throws: `MusanovaKitError` if the request fails or the response cannot be decoded.
  public func response() async throws -> MusicLibraryPinsResponse {
    do {
      let url = try pinsEndpointURL
      let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
      let response = try await request.response()
      
      do {
        return try JSONDecoder().decode(MusicLibraryPinsResponse.self, from: response.data)
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

/// URL construction for the pins endpoint.
extension MusicLibraryPinsRequest {
  /// The endpoint URL for fetching library pins.
  var pinsEndpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/library/pins"

      var queryItems: [URLQueryItem] = []

      // Artwork URL parameter
      if includeArtworkURLs {
        queryItems.append(URLQueryItem(name: "art[url]", value: "f"))
      }

      // Artist fields
      addQueryItem(for: artistFields, key: "fields[artists]", to: &queryItems)

      // Resource format
      queryItems.append(URLQueryItem(name: "format[resources]", value: resourceFormat.rawValue))

      // Library includes
      addQueryItem(for: libraryArtistIncludes, key: "include[library-artists]", to: &queryItems)
      addQueryItem(for: libraryMusicVideoIncludes, key: "include[library-music-videos]", to: &queryItems)
      addQueryItem(for: librarySongIncludes, key: "include[library-songs]", to: &queryItems)

      // Language
      queryItems.append(URLQueryItem(name: "l", value: language))

      // Limit
      queryItems.append(URLQueryItem(name: "limit", value: String(limit)))

      // Meta
      queryItems.append(URLQueryItem(name: "meta", value: meta.rawValue))

      components.queryItems = queryItems

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(description: "Failed to construct pins endpoint URL with path: \(components.path)")
      }

      return url
    }
  }

  /// Adds a query item for an array of values if the array is not empty.
  ///
  /// - Parameters:
  ///   - values: The array of string values to join.
  ///   - key: The query parameter key.
  ///   - queryItems: The array to append the query item to.
  private func addQueryItem(for values: [String], key: String, to queryItems: inout [URLQueryItem]) {
    if !values.isEmpty {
      queryItems.append(URLQueryItem(name: key, value: values.joined(separator: ",")))
    }
  }
}
