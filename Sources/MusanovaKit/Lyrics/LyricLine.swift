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
public struct LyricLine: Identifiable {

  /// A unique identifier for the lyric line.
  public let id = UUID()

  /// The text content of the lyric line.
  public var text: String
}
