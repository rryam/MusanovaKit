//
//  MusicSummaryMilestone.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation

/// A milestone object representing a music summary milestone.
///
/// A MusicSummaryMilestone object represents a milestone that a user has achieved in their music listening history, such as the number of unique songs or artists listened to.
///
/// It includes the unique identifier for the milestone, the amount of time the user spent listening to music to reach the milestone, the date the milestone was reached, the value associated with the milestone, and the type of music item associated with the milestone.
///
/// Example usage:
///
///     let milestone: MusicSummaryMilestone = ...
///     print("ID: \(milestone.id), Listen Time: \(milestone.listenTimeInMinutes)")
///     print("Date Reached: \(milestone.dateReached), Value: \(milestone.value)")
///     print("Kind: \(milestone.kind)")
///
public struct MusicSummaryMilestone: Codable {
  
  /// The unique identifier for the music summary milestone.
  public let id: String

  /// The amount of time the user spent listening to music in minutes to reach the milestone.
  public let listenTimeInMinutes: Int

  /// The date the milestone was reached.
  public let dateReached: String

  /// The value associated with the milestone, such as the number of unique songs or artists listened to.
  public let value: String

  /// The type of music item associated with the milestone, such as a song, artist, or listening time.
  public let kind: MusicSummaryMilestoneKind

  /// An array of `Song` objects representing the user's top songs for the given time period.
  public let topSongs: Songs

  /// An array of `Artist` objects representing the user's top artists for the given time period.
  public let topArtists: Artists

  /// An array of `Album` objects representing the user's top albums for the given time period.
  public let topAlbums: Albums
}

extension MusicSummaryMilestone: Identifiable {
}

extension MusicSummaryMilestone: Hashable {
  
}

extension MusicSummaryMilestone {
  private enum CodingKeys: String, CodingKey {
    case id
    case attributes
    case relationships
  }

  private enum RelationshipsCodingKeys: String, CodingKey {
    case topSongs = "top-songs"
    case topArtists = "top-artists"
    case topAlbums = "top-albums"
  }

  private enum AttributesCodingKeys: String, CodingKey {
    case listenTimeInMinutes
    case dateReached
    case value
    case kind
  }
}

extension MusicSummaryMilestone {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)

    let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
    listenTimeInMinutes = try attributesContainer.decode(Int.self, forKey: .listenTimeInMinutes)
    dateReached = try attributesContainer.decode(String.self, forKey: .dateReached)
    value = try attributesContainer.decode(String.self, forKey: .value)
    kind = try attributesContainer.decode(MusicSummaryMilestoneKind.self, forKey: .kind)

    let relationshipsContainer = try container.nestedContainer(keyedBy: RelationshipsCodingKeys.self, forKey: .relationships)
    topSongs = try relationshipsContainer.decodeIfPresent(Songs.self, forKey: .topSongs) ?? []
    topAlbums = try relationshipsContainer.decodeIfPresent(Albums.self, forKey: .topAlbums) ?? []
    topArtists = try relationshipsContainer.decodeIfPresent(Artists.self, forKey: .topArtists) ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)

    var attributesContainer = container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
    try attributesContainer.encode(listenTimeInMinutes, forKey: .listenTimeInMinutes)
    try attributesContainer.encode(dateReached, forKey: .dateReached)
    try attributesContainer.encode(value, forKey: .value)
    try attributesContainer.encode(kind, forKey: .kind)

    var relationshipsContainer = container.nestedContainer(keyedBy: RelationshipsCodingKeys.self, forKey: .relationships)
    try relationshipsContainer.encode(topArtists, forKey: .topArtists)
    try relationshipsContainer.encode(topSongs, forKey: .topSongs)
    try relationshipsContainer.encode(topAlbums, forKey: .topAlbums)
  }
}
