//
//  MusicSummaryMilestonesMusicItemsType.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 06/04/23.
//

import Foundation

/// An enumeration of the different types of music items that can be included in a music summary milestone.
///
/// Use this enumeration to specify the type of music items to include in a music summary milestone, such as the user's top artists, songs, or albums.
public enum MusicSummaryMilestonesMusicItemsType: String, Sendable {
  /// The user's top artists.
  case topArtists = "top-artists"

  /// The user's top songs.
  case topSongs = "top-songs"

  /// The user's top albums.
  case topAlbums = "top-albums"
}
