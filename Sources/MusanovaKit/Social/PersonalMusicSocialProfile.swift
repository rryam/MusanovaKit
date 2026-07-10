//
//  PersonalMusicSocialProfile.swift
//  MusanovaKit
//

/// The current user's Apple Music social profile and included social relationships.
public struct PersonalMusicSocialProfile: Identifiable, Decodable, Sendable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: MusicSocialProfileAttributes?
  public let socialProfile: MusicSocialProfile?

  public init(from decoder: Decoder) throws {
    let response = try MusicSocialResponseBody(from: decoder)
    self = try response.personalProfile()
  }

  init(
    id: String,
    type: String,
    href: String?,
    attributes: MusicSocialProfileAttributes?,
    socialProfile: MusicSocialProfile?
  ) {
    self.id = id
    self.type = type
    self.href = href
    self.attributes = attributes
    self.socialProfile = socialProfile
  }
}
