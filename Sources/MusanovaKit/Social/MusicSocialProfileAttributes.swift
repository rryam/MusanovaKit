//
//  MusicSocialProfileAttributes.swift
//  MusanovaKit
//

/// Attributes describing an Apple Music social profile.
public struct MusicSocialProfileAttributes: Decodable, Hashable, Sendable {
  public let name: String?
  public let handle: String?
  public let url: String?
  public let artwork: MusicSocialProfileArtwork?
  public let isPrivate: Bool?
  public let isVerified: Bool?
  public let isOnboarded: Bool?
  public let hideListeningTo: Bool?
  public let collaborationAllowed: Bool?
  public let pendingFollowersCount: Int?
  public let followState: SocialFollowState?
}
