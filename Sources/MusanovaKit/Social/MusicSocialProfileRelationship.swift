//
//  MusicSocialProfileRelationship.swift
//  MusanovaKit
//

/// A signed relationship on the current user's Apple Music social profile.
public enum MusicSocialProfileRelationship: String, CaseIterable, Sendable {
  case followers
  case followees
  case pendingFollowers = "pending-followers"
}
