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
  /// - Returns: The raw API response containing pinned items and their associated resources.
  ///
  /// - Throws: An error if the request fails or the response cannot be decoded.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     do {
  ///         let response = try await MLibrary.pins(developerToken: "your_token", limit: 10)
  ///         for pinRef in response.data {
  ///             print("Pinned: \(pinRef.id) - Type: \(pinRef.type)")
  ///         }
  ///         // Access detailed resources
  ///         if let albums = response.resources?.libraryAlbums {
  ///             // Process album details
  ///         }
  ///     } catch {
  ///         print("Failed to fetch pins: \(error)")
  ///     }
  ///
  static func pins(developerToken: String, limit: Int = 25) async throws -> MusicLibraryPinsResponse {
    var request = MusicLibraryPinsRequest(developerToken: developerToken)
    request.limit = limit
    request.includeArtworkURLs = true

    return try await request.response()
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

  /// Pins an item to the user's Apple Music library.
  ///
  /// This method sends a POST request to pin the specified item, making it appear
  /// prominently in the user's Apple Music interface. The item must conform to the `Pinnable` protocol.
  ///
  /// - Parameters:
  ///   - item: The music item to pin to the library (Album, Song, Playlist, or Artist).
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     let album: Album = // ... fetched album
  ///     try await MLibrary.pin(album, developerToken: token)
  ///     print("Album pinned successfully!")
  ///
  ///     let song: Song = // ... fetched song
  ///     try await MLibrary.pin(song, developerToken: token)
  ///     print("Song pinned successfully!")
  ///
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  static func pin(_ item: some Pinnable, developerToken: String) async throws {
    try await pin(itemId: item.id.rawValue, developerToken: developerToken)
  }

  /// Private helper method that performs the actual pinning operation using an item ID.
  ///
  /// - Parameters:
  ///   - itemId: The raw string ID of the item to pin.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  private static func createPin(for itemId: String, developerToken: String) async throws {
    var components = AppleMusicAMPURLComponents()
    components.path = "me/library/pins/\(itemId)"

    components.queryItems = [
      URLQueryItem(name: "art[url]", value: "f"),
      URLQueryItem(name: "format[resources]", value: "map"),
      URLQueryItem(name: "l", value: "en-GB")
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken, method: "POST")
    _ = try await request.response()
  }

  /// Unpins an item from the user's Apple Music library.
  ///
  /// This method sends a DELETE request to remove the specified item from the user's
  /// pinned items, removing it from the prominent display in the Apple Music interface.
  /// The item must conform to the `Pinnable` protocol.
  ///
  /// - Parameters:
  ///   - item: The music item to unpin from the library (Album, Song, Playlist, or Artist).
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be deleted.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     let album: Album = // ... fetched album
  ///     try await MLibrary.unpin(album, developerToken: token)
  ///     print("Album unpinned successfully!")
  ///
  ///     let song: Song = // ... fetched song
  ///     try await MLibrary.unpin(song, developerToken: token)
  ///     print("Song unpinned successfully!")
  ///
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  static func unpin(_ item: some Pinnable, developerToken: String) async throws {
    try await unpin(itemId: item.id.rawValue, developerToken: developerToken)
  }

  /// Private helper method that performs the actual pinning operation using an item ID.
  ///
  /// - Parameters:
  ///   - itemId: The raw string ID of the item to pin.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  private static func pin(itemId: String, developerToken: String) async throws {
    var components = AppleMusicAMPURLComponents()
    components.path = "me/library/pins/\(itemId)"

    components.queryItems = [
      URLQueryItem(name: "art[url]", value: "f"),
      URLQueryItem(name: "format[resources]", value: "map"),
      URLQueryItem(name: "l", value: "en-GB")
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken, method: "POST")
    _ = try await request.response()
  }

  /// Private helper method that performs the actual unpinning operation using an item ID.
  ///
  /// - Parameters:
  ///   - itemId: The raw string ID of the item to unpin.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be deleted.
  private static func unpin(itemId: String, developerToken: String) async throws {
    var components = AppleMusicAMPURLComponents()
    components.path = "me/library/pins/\(itemId)"

    components.queryItems = [
      URLQueryItem(name: "art[url]", value: "f"),
      URLQueryItem(name: "format[resources]", value: "map"),
      URLQueryItem(name: "l", value: "en-GB")
    ]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken, method: "DELETE")
    _ = try await request.response()
  }
}