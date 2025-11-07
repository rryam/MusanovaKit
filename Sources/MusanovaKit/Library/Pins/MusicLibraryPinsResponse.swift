//
//  MusicLibraryPinsResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation

/// A reference to a pinned item in the library.
///
/// This represents a minimal reference to a pinned item, containing only
/// the essential identification information.
public struct PinReference: Decodable, Sendable {
  /// The unique identifier of the pinned item.
  public let id: String

  /// The type of the pinned item (e.g., "library-albums", "library-songs").
  public let type: String

  /// The href for accessing the full item details.
  public let href: String
}

/// Resources containing detailed information about pinned items and their relationships.
public struct PinResources: Decodable, Sendable {
  /// Catalog artists referenced by pinned items.
  public let artists: [String: Artist]?

  /// Library albums referenced by pinned items.
  public let libraryAlbums: [String: Album]?

  /// Library artists referenced by pinned items.
  public let libraryArtists: [String: Artist]?

  /// Library songs referenced by pinned items.
  public let librarySongs: [String: Song]?

  enum CodingKeys: String, CodingKey {
    case artists
    case libraryAlbums = "library-albums"
    case libraryArtists = "library-artists"
    case librarySongs = "library-songs"
  }
}

/// The response containing pinned items from the user's Apple Music library.
///
/// This response contains pinned items with their references and full resource details.
/// The API separates pin references from detailed resource data for efficiency.
///
/// Example usage:
///
///     let response = try await request.response()
///     for pin in response.data {
///         print("Pinned: \(pin.id) of type \(pin.type)")
///     }
///     if let album = response.resources?.libraryAlbums?[pinId] {
///         print("Album: \(album.attributes?.name ?? "Unknown")")
///     }
///
public struct MusicLibraryPinsResponse: Decodable, Sendable {
  /// Array of pin references containing basic identification information.
  public let data: [PinReference]

  /// Detailed resource information for all pinned items and their relationships.
  public let resources: PinResources?
}

/// A collection of library pins.
///
/// This type alias provides a convenient way to work with collections of pinned items.
///
/// Example usage:
///
///     let pins: LibraryPins = try await MLibrary.pins(developerToken: token)
///     for pin in pins {
///         print("Pin: \(pin.attributes.name ?? "Unknown")")
///     }
///
public typealias LibraryPins = MusicItemCollection<LibraryPin>
