//
//  MusicSummaryMilestones.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

/// A collection of `MusicSummaryMilestone` objects.
///
/// The `MusicSummaryMilestones` typealias is a convenient way to represent a collection
/// of `MusicSummaryMilestone` objects. It is an alias for an array of `MusicSummaryMilestone`.
///
/// Example usage:
///
///     let milestones: MusicSummaryMilestones = ...
///
///     for milestone in milestones {
///       print("ID: \(milestone.id), Listen Time: \(milestone.listenTimeInMinutes)")
///       print("Date Reached: \(milestone.dateReached), Value: \(milestone.value)")
///       print("Kind: \(milestone.kind)")
///     }
///
public typealias MusicSummaryMilestones = [MusicSummaryMilestone]
