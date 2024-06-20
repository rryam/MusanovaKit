//
//  MusicLyricsResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 26/05/24.
//

import Foundation

/// Represents the response containing lyrics data.
public struct MusicLyricsResponse: Codable {

  /// An array of `LyricsData` objects containing the lyrics information.
  let data: [LyricsData]
}

/// Represents the data for a single lyrics item.
public struct LyricsData: Codable {

  /// The unique identifier for the lyrics item.
  let id: String

  /// The type of the lyrics item.
  let type: String

  /// The attributes containing the actual lyrics content and play parameters.
  let attributes: LyricsAttributes
}

/// Contains the lyrics content and play parameters.
public struct LyricsAttributes: Codable {

  /// The lyrics content in TTML (Timed Text Markup Language) format.
  let ttml: String

  /// Parameters related to playing the lyrics.
  let playParams: PlayParams
}

/// Represents parameters for playing the lyrics.
public struct PlayParams: Codable {

  /// The unique identifier for the play parameters.
  let id: String

  /// The kind of play parameters.
  let kind: String

  /// The catalog identifier associated with these play parameters.
  let catalogId: String

  /// An integer representing the display type for the lyrics.
  let displayType: Int
}
