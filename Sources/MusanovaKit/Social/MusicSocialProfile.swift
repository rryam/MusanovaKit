//
//  MusicSocialProfile.swift
//  MusanovaKit
//

/// A person's public Apple Music social profile.
public struct MusicSocialProfile: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: MusicSocialProfileAttributes?
}
