//
//  MusicSummarySearches.swift
//  MusanoveKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

/// A collection of MusicSummarySearch objects.
///
/// The MusicSummarySearches typealias is a convenient way to represent a collection
/// of MusicSummarySearch objects. It uses MusicKit's MusicItemCollection to store
/// and manage the collection.
///
/// Example usage:
///
///     let summaries: MusicSummarySearches = ...
///     for summary in summaries {
///         print("Year: \(summary.year), Playlist: \(summary.playlist)")
///     }
///
public typealias MusicSummarySearches = MusicItemCollection<MusicSummarySearch>
