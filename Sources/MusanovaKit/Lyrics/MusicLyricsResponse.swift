//
//  MusicLyricsResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 26/05/24.
//

import Foundation

/// Represents the response containing lyrics data.
public struct MusicLyricsResponse: Codable, Sendable {
  /// An array of `LyricsData` objects containing the lyrics information.
  public let data: [LyricsData]

  /// Creates a lyrics response.
  public init(data: [LyricsData]) {
    self.data = data
  }

  /// The first lyrics resource's raw TTML, when available.
  public var rawTTML: String? {
    data.first?.attributes.ttml
  }
}

/// Represents the data for a single lyrics item.
public struct LyricsData: Codable, Sendable {
  /// The unique identifier for the lyrics item.
  public let id: String

  /// The type of the lyrics item.
  public let type: String

  /// The attributes containing the actual lyrics content and play parameters.
  public let attributes: LyricsAttributes

  /// Creates a lyrics data resource.
  public init(id: String, type: String, attributes: LyricsAttributes) {
    self.id = id
    self.type = type
    self.attributes = attributes
  }
}

/// Contains the lyrics content and play parameters.
public struct LyricsAttributes: Codable, Sendable {
  /// The lyrics content in TTML (Timed Text Markup Language) format.
  public let ttml: String

  /// Parameters related to playing the lyrics.
  public let playParams: PlayParams

  /// Creates lyrics attributes.
  public init(ttml: String, playParams: PlayParams) {
    self.ttml = ttml
    self.playParams = playParams
  }
}

/// Represents parameters for playing the lyrics.
public struct PlayParams: Codable, Sendable {
  /// The unique identifier for the play parameters.
  public let id: String

  /// The kind of play parameters.
  public let kind: String

  /// The catalog identifier associated with these play parameters.
  public let catalogId: String

  /// An integer representing the display type for the lyrics.
  public let displayType: Int

  /// Creates lyrics playback parameters.
  public init(id: String, kind: String, catalogId: String, displayType: Int) {
    self.id = id
    self.kind = kind
    self.catalogId = catalogId
    self.displayType = displayType
  }
}
