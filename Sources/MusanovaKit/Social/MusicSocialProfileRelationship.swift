//
//  MusicSocialProfileRelationship.swift
//  MusanovaKit
//

/// A read-only relationship on the current user's Apple Music social profile.
public enum MusicSocialProfileRelationship: String, CaseIterable, Sendable {
  case followers
  case followees
  case pendingFollowers = "pending-followers"
}
