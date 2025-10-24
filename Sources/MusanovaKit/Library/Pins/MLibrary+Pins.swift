//
//  MLibrary+Pins.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation

public extension MLibrary {

  /// Fetches pinned items from the user's Apple Music library.
  ///
  /// This method retrieves music content that the user has pinned in their library.
  /// Pinned items represent content that users have marked as favorites or important,
  /// and may appear prominently in the Apple Music interface.
  ///
  /// - Parameters:
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///   - limit: The maximum number of pins to return. Defaults to 25.
  ///
  /// - Returns: An array of `LibraryPin` objects representing the user's pinned items.
  ///
  /// - Throws: An error if the request fails or the response cannot be decoded.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     do {
  ///         let pins = try await MLibrary.pins(developerToken: "your_token", limit: 10)
  ///         for pin in pins {
  ///             print("Pinned: \(pin.attributes.name ?? "Unknown") - Type: \(pin.type)")
  ///         }
  ///     } catch {
  ///         print("Failed to fetch pins: \(error)")
  ///     }
  ///
  static func pins(developerToken: String, limit: Int = 25) async throws -> LibraryPins {
    var request = MusicLibraryPinsRequest(developerToken: developerToken)
    request.limit = limit
    request.includeArtworkURLs = true

    let response = try await request.response()
    return Array(response.pins.values)
  }

  /// Fetches pinned items with custom configuration options.
  ///
  /// This method provides full control over the pins request parameters,
  /// allowing customization of included relationships, fields, and other options.
  ///
  /// - Parameter configuration: A pre-configured `MusicLibraryPinsRequest` object with custom parameters and developer token.
  ///
  /// - Returns: A `MusicLibraryPinsResponse` containing the raw response data.
  ///
  /// - Throws: An error if the request fails or the response cannot be decoded.
  ///
  /// Example usage:
  ///
  ///     var configuration = MusicLibraryPinsRequest(developerToken: token)
  ///     configuration.limit = 50
  ///     configuration.librarySongIncludes = ["albums", "artists"]
  ///     configuration.language = "es-ES"
  ///
  ///     let response = try await MLibrary.pins(configuration: configuration)
  ///
  static func pins(configuration: MusicLibraryPinsRequest) async throws -> MusicLibraryPinsResponse {
    return try await configuration.response()
  }
}
