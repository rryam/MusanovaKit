//
//  MusicSummaryMilestoneKind.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation

/// An enumeration of the different types of music items that can be included in a music summary milestone.
///
/// Use this enumeration to specify the type of music items to include in a music summary milestone, such as the user's top artists, songs, or albums.
public enum MusicSummaryMilestoneKind: String, Codable {
  case listenTime = "listen-time"
  case artist
  case song
}
