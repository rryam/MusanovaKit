//
//  LibraryPin.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation
import MusadoraKit

/// Represents a pinned item in the user's Apple Music library.
///
/// A pin represents content that a user has pinned to their library, such as favorite songs,
/// artists, or playlists that appear prominently in the Apple Music interface.
///
/// Example usage:
///
///     let pin: LibraryPin = ...
///     print("Pinned item ID: \(pin.id), Type: \(pin.type)")
///     if let action = pin.libraryPin?.action {
///         print("Pin action: \(action)")
///     }
///
public struct LibraryPin: Decodable, MusicItem, Sendable {
  /// The unique identifier of the pinned item.
  ///
  /// This corresponds to the music item ID of the pinned content.
  public let id: MusicItemID

  /// The type of the pinned music item (song, artist, album, playlist, etc.).
  public let type: String

  /// The attributes specific to the pinned item.
  ///
  /// This contains additional metadata about the pinned item, such as artwork,
  /// title, and other relevant information.
  public let attributes: LibraryPinAttributes

  /// Relationships to related music items.
  ///
  /// Depending on the type of pinned item, this may include related albums,
  /// playlists, artists, or other associated content.
  public let relationships: LibraryPinRelationships?

  /// Pin-specific metadata containing interaction details.
  ///
  /// This includes information about how to interact with the pinned item,
  /// such as the action to perform when tapped (e.g., "play", "drillIn", "shuffle")
  /// and positioning information.
  public let libraryPin: LibraryPinAction?

  /// Coding keys for decoding the JSON response.
  enum CodingKeys: String, CodingKey {
    case id, type, attributes, relationships, meta
  }
}

/// Metadata specific to a library pin item.
///
/// This contains information about the pin itself, such as the action
/// to perform when interacting with the pinned item.
public struct LibraryPinAction: Decodable, Sendable {
  /// The action to perform when interacting with the pinned item.
  ///
  /// Possible values include:
  /// - "play": Play the item (songs, albums)
  /// - "drillIn": Navigate to the item (playlists, artists)
  /// - "shuffle": Shuffle play the item (playlists)
  public let action: String

  /// A unique identifier for the position of this pin.
  public let positionUUID: String

  enum CodingKeys: String, CodingKey {
    case action
    case positionUUID
  }
}

/// Extension to handle the nested meta.libraryPin structure.
extension LibraryPin {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(MusicItemID.self, forKey: .id)
    type = try container.decode(String.self, forKey: .type)
    attributes = try container.decode(LibraryPinAttributes.self, forKey: .attributes)
    relationships = try container.decodeIfPresent(LibraryPinRelationships.self, forKey: .relationships)

    // Decode the nested meta.libraryPin structure
    let metaContainer = try? container.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .meta)
    libraryPin = try metaContainer?.decodeIfPresent(LibraryPinAction.self, forKey: .libraryPin)
  }

  enum MetaCodingKeys: String, CodingKey {
    case libraryPin
  }
}

/// Attributes for a library pin item.
public struct LibraryPinAttributes: Decodable, Sendable {
  /// The name or title of the pinned item.
  public let name: String?

  /// Artwork information for the pinned item.
  public let artwork: Artwork?

  /// Additional metadata about the pin.
  ///
  /// This may include information like the date the item was pinned
  /// or other platform-specific metadata.
  public let meta: [String: String]?

  enum CodingKeys: String, CodingKey {
    case name, artwork, meta
  }
}

/// Relationships for a library pin item.
///
/// This structure contains references to related music content
/// that may be associated with the pinned item.
public struct LibraryPinRelationships: Decodable, Sendable {
  /// Related albums (if applicable).
  public let albums: Albums?

  /// Related playlists (if applicable).
  public let playlists: Playlists?

  /// Related artists (if applicable).
  public let artists: Artists?

  /// Related songs (if applicable).
  public let songs: Songs?

  /// Coding keys for decoding relationships.
  enum CodingKeys: String, CodingKey {
    case albums, playlists, artists, songs
  }
}
