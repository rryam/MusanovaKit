//
//  LyricLine.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 21/06/24.
//

import Foundation

/// A collection of `LyricLine` objects representing a sequence of lyric lines.
public typealias LyricLines = [LyricLine]

/// Represents a single line of lyrics.
public struct LyricLine: Identifiable, Sendable {
  /// A unique identifier for the lyric line.
  public let id = UUID()

  /// The text content of the lyric line.
  public var text: String

  /// The timed segments that make up the lyric line.
  public var segments: [LyricSegment]

  /// Creates a new lyric line.
  ///
  /// - Parameters:
  ///   - text: The complete text content for the line.
  ///   - segments: The timed segments that compose the line. Defaults to an empty collection.
  public init(text: String, segments: [LyricSegment] = []) {
    self.text = text
    self.segments = segments
  }
}
