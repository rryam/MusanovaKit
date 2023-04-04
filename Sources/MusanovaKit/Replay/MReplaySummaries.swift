//
//  MReplaySummaries.swift
//  MusanoveKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

/// A collection of MReplaySummary objects.
///
/// The MReplaySummaries typealias is a convenient way to represent a collection
/// of MReplaySummary objects. It uses MusicKit's MusicItemCollection to store
/// and manage the collection.
///
/// Example usage:
///
///     let summaries: MReplaySummaries = ...
///     for summary in summaries {
///         print("Year: \(summary.year), Playlist: \(summary.playlist)")
///     }
///
typealias MReplaySummaries = MusicItemCollection<MReplaySummary>
