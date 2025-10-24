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
///
public struct LibraryPin: Decodable, MusicItem {

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

  /// Coding keys for decoding the JSON response.
  enum CodingKeys: String, CodingKey {
    case id, type, attributes, relationships
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
