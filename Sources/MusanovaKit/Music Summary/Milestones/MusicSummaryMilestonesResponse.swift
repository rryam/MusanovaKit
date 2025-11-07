//
//  MusicSummaryMilestonesResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation

/// A response object representing a list of music summary milestones.
struct MusicSummaryMilestonesResponse: Decodable, Sendable {
  /// An array of `MusicSummaryMilestone` objects.
  let milestones: [MusicSummaryMilestone]
}

extension MusicSummaryMilestonesResponse {
  enum CodingKeys: String, CodingKey {
    case milestones = "data"
  }
}
