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

  /// Pins an album to the user's Apple Music library.
  ///
  /// This method sends a POST request to pin the specified album, making it appear
  /// prominently in the user's Apple Music interface.
  ///
  /// - Parameters:
  ///   - album: The album to pin to the library.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     let album: Album = // ... fetched album
  ///     try await MLibrary.createPin(for: album, developerToken: token)
  ///     print("Album pinned successfully!")
  ///
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  static func createPin(for album: Album, developerToken: String) async throws {
    try await createPin(for: album.id.rawValue, developerToken: developerToken)
  }

  /// Pins a song to the user's Apple Music library.
  ///
  /// This method sends a POST request to pin the specified song, making it appear
  /// prominently in the user's Apple Music interface.
  ///
  /// - Parameters:
  ///   - song: The song to pin to the library.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     let song: Song = // ... fetched song
  ///     try await MLibrary.createPin(for: song, developerToken: token)
  ///     print("Song pinned successfully!")
  ///
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  static func createPin(for song: Song, developerToken: String) async throws {
    try await createPin(for: song.id.rawValue, developerToken: developerToken)
  }

  /// Pins a playlist to the user's Apple Music library.
  ///
  /// This method sends a POST request to pin the specified playlist, making it appear
  /// prominently in the user's Apple Music interface.
  ///
  /// - Parameters:
  ///   - playlist: The playlist to pin to the library.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     let playlist: Playlist = // ... fetched playlist
  ///     try await MLibrary.createPin(for: playlist, developerToken: token)
  ///     print("Playlist pinned successfully!")
  ///
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  static func createPin(for playlist: Playlist, developerToken: String) async throws {
    try await createPin(for: playlist.id.rawValue, developerToken: developerToken)
  }

  /// Pins an artist to the user's Apple Music library.
  ///
  /// This method sends a POST request to pin the specified artist, making it appear
  /// prominently in the user's Apple Music interface.
  ///
  /// - Parameters:
  ///   - artist: The artist to pin to the library.
  ///   - developerToken: The privileged developer token used to authorize the request.
  ///
  /// - Throws: An error if the request fails or the pin cannot be created.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  ///
  /// Example usage:
  ///
  ///     let artist: Artist = // ... fetched artist
  ///     try await MLibrary.createPin(for: artist, developerToken: token)
  ///     print("Artist pinned successfully!")
  ///
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  static func createPin(for artist: Artist, developerToken: String) async throws {
    try await createPin(for: artist.id.rawValue, developerToken: developerToken)
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
}