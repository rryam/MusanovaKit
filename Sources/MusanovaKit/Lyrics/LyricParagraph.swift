//
//  LyricParagraph.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 21/06/24.
//

import Foundation

/// A collection of `LyricParagraph` objects representing the entire lyrics of a song.
public typealias LyricParagraphs = [LyricParagraph]

/// Represents a paragraph or section of lyrics.
public struct LyricParagraph: Identifiable {
    /// A unique identifier for the lyric paragraph.
    public let id = UUID()

    /// An array of `LyricLine` objects that make up this paragraph.
    public let lines: LyricLines

    /// An optional string indicating the part of the song this paragraph represents (e.g., "Verse", "Chorus").
    public let songPart: String?
}
