//
//  SocialFollowState.swift
//  MusanovaKit
//

/// The relationship between the current user and an Apple Music social profile.
///
/// This type preserves unknown raw values so that newly added server states do not
/// cause an otherwise valid profile response to fail decoding.
public struct SocialFollowState: RawRepresentable, Codable, Hashable, Sendable {
  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public static let following = SocialFollowState(rawValue: "following")
  public static let notFollowing = SocialFollowState(rawValue: "notFollowing")
  public static let requested = SocialFollowState(rawValue: "requested")
  public static let blocked = SocialFollowState(rawValue: "blocked")
  public static let blockedBy = SocialFollowState(rawValue: "blockedBy")
  public static let currentUser = SocialFollowState(rawValue: "self")
}
