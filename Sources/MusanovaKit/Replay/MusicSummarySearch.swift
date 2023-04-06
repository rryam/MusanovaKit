//
//  MusicSummarySearch.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation

/// A summary of a user's music listening history for a specific year.
///
/// The `MusicSummarySearch` struct represents a summary of a user's music listening
/// history for a specific year. It includes information such as the year,
/// and the associated playlist.
///
/// Example usage:
///
///     let summary: MusicSummarySearch = ...
///     print("Year: \(summary.year), Playlist: \(summary.playlist)")
///
public struct MusicSummarySearch: Decodable, MusicItem {

  /// The unique identifier of the `MReplaySummary`.
  ///
  /// This property returns the unique identifier of the associated playlist.
  /// It conforms to the `MusicItemID` type, as required by the `MusicItem` protocol.
  ///
  /// Example usage:
  ///
  ///     let summary: MReplaySummary = ...
  ///     print("Summary ID: \(summary.id)")
  ///
  public var id: MusicItemID {
    playlist.id
  }

  /// The year of the `MReplaySummary`.
  ///
  /// This property represents the year associated with the MReplaySummary.
  /// It is an integer value indicating the year of the music listening history.
  ///
  /// Example usage:
  ///
  ///     let summary: MReplaySummary = ...
  ///     print("Summary Year: \(summary.year)")
  ///
  public let year: Int

  /// The playlist associated with the `MReplaySummary`.
  ///
  /// This property represents the playlist associated with the user's
  /// music listening history for the specified year. It contains information
  /// such as the playlist's id, type, and href.
  ///
  /// Example usage:
  ///
  ///     let summary: MReplaySummary = ...
  ///     print("Summary Playlist: \(summary.playlist)")
  ///
  public let playlist: Playlist
}

extension MusicSummarySearch {
  enum CodingKeys: String, CodingKey {
    case id, attributes, relationships
  }

  enum AttributesKeys: String, CodingKey {
    case year
  }

  enum RelationshipsKeys: String, CodingKey {
    case playlist
  }
}

extension MusicSummarySearch {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
    year = try attributesContainer.decode(Int.self, forKey: .year)

    let relationshipsContainer = try container.nestedContainer(keyedBy: RelationshipsKeys.self, forKey: .relationships)
    let playlists = try relationshipsContainer.decode(MusicItemCollection<Playlist>.self, forKey: .playlist)
    if let firstPlaylist = playlists.first {
      playlist = firstPlaylist
    } else {
      throw DecodingError.dataCorrupted(.init(codingPath: relationshipsContainer.codingPath, debugDescription: "The replay year \(year) does not contain any playlist."))
    }
  }
}
