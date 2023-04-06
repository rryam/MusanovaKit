//
//  MusicSummaryMilestone.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation

/// A milestone object representing a music summary milestone.
struct MusicSummaryMilestone: Codable {

  /// The unique identifier for the music summary milestone.
  let id: String

  /// The amount of time the user spent listening to music in minutes to reach the milestone.
  let listenTimeInMinutes: Int

  /// The date the milestone was reached.
  let dateReached: String

  /// The value associated with the milestone, such as the number of unique songs or artists listened to.
  let value: String

  /// The type of music item associated with the milestone, such as a song, artist, or listening time.
  let kind: MusicSummaryMilestoneKind
}

extension MusicSummaryMilestone {
  private enum CodingKeys: String, CodingKey {
    case id
    case attributes
  }

  private enum AttributesCodingKeys: String, CodingKey {
    case listenTimeInMinutes
    case dateReached
    case value
    case kind
  }
}

extension MusicSummaryMilestone {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)

    let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
    listenTimeInMinutes = try attributesContainer.decode(Int.self, forKey: .listenTimeInMinutes)
    dateReached = try attributesContainer.decode(String.self, forKey: .dateReached)
    value = try attributesContainer.decode(String.self, forKey: .value)
    kind = try attributesContainer.decode(MusicSummaryMilestoneKind.self, forKey: .kind)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)

    var attributesContainer = container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
    try attributesContainer.encode(listenTimeInMinutes, forKey: .listenTimeInMinutes)
    try attributesContainer.encode(dateReached, forKey: .dateReached)
    try attributesContainer.encode(value, forKey: .value)
    try attributesContainer.encode(kind, forKey: .kind)
  }
}
