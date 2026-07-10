//
//  MusicSocialProfilesPage.swift
//  MusanovaKit
//

/// A page of Apple Music social profiles.
public struct MusicSocialProfilesPage: Decodable, Sendable {
  public let profiles: [MusicSocialProfile]
  public let href: String?
  public let next: String?

  public init(from decoder: Decoder) throws {
    let response = try MusicSocialResponseBody(from: decoder)
    self = response.profilePage()
  }

  init(profiles: [MusicSocialProfile], href: String? = nil, next: String? = nil) {
    self.profiles = profiles
    self.href = href
    self.next = next
  }
}
