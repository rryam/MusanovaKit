//
//  MusicSocialResponseBody.swift
//  MusanovaKit
//

import Foundation

struct MusicSocialResponseBody: Decodable, Sendable {
  let data: [MusicSocialResource]
  let resources: MusicSocialResourceMap?

  func personalProfile() throws -> PersonalMusicSocialProfile {
    guard let identifier = data.first else {
      throw MusanovaKitError.emptyResponse
    }

    let resource = resolvedResource(for: identifier)
    let relationships = resource.relationships

    return PersonalMusicSocialProfile(
      id: resource.id,
      type: resource.type,
      href: resource.href,
      attributes: resource.attributes,
      socialProfile: relationships?.socialProfile?.data.first.map { profile(for: $0) }
    )
  }

  private func profile(for identifier: MusicSocialResource) -> MusicSocialProfile {
    let resource = resolvedResource(for: identifier)
    return MusicSocialProfile(
      id: resource.id,
      type: resource.type,
      href: resource.href,
      attributes: resource.attributes
    )
  }

  private func resolvedResource(for identifier: MusicSocialResource) -> MusicSocialResource {
    switch identifier.type {
    case "personal-social-profiles":
      resources?.personalSocialProfiles?[identifier.id] ?? identifier
    case "social-profiles":
      resources?.socialProfiles?[identifier.id] ?? identifier
    default:
      identifier
    }
  }
}

struct MusicSocialResourceMap: Decodable, Sendable {
  let personalSocialProfiles: [String: MusicSocialResource]?
  let socialProfiles: [String: MusicSocialResource]?

  enum CodingKeys: String, CodingKey {
    case personalSocialProfiles = "personal-social-profiles"
    case socialProfiles = "social-profiles"
  }
}

struct MusicSocialResource: Decodable, Sendable {
  let id: String
  let type: String
  let href: String?
  let attributes: MusicSocialProfileAttributes?
  let relationships: MusicSocialRelationships?
}

struct MusicSocialRelationships: Decodable, Sendable {
  let socialProfile: MusicSocialRelationship?

  enum CodingKeys: String, CodingKey {
    case socialProfile = "social-profile"
  }
}

struct MusicSocialRelationship: Decodable, Sendable {
  let href: String?
  let next: String?
  let data: [MusicSocialResource]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    href = try container.decodeIfPresent(String.self, forKey: .href)
    next = try container.decodeIfPresent(String.self, forKey: .next)
    data = try container.decodeIfPresent([MusicSocialResource].self, forKey: .data) ?? []
  }

  enum CodingKeys: String, CodingKey {
    case href
    case next
    case data
  }
}
