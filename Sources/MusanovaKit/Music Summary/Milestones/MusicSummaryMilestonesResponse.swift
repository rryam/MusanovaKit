//
//  MusicSummaryMilestonesResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation

/// A response object representing a list of music summary milestones.
struct MusicSummaryMilestonesResponse: Decodable {

  /// An array of `MusicSummaryMilestone` objects.
  public let milestones: [MusicSummaryMilestone]
}

extension MusicSummaryMilestonesResponse {
  enum CodingKeys: String, CodingKey {
    case milestones = "data"
  }
}
