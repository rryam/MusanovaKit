//
//  MusicSocialProfileTests.swift
//  MusanovaKitTests
//

import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct MusicSocialProfileTests {
  @Test
  func profileEndpointIncludesRequestedRelationships() throws {
    let request = try MusicSocialProfileRequest(developerToken: "test_token")
    let endpointURL = try request.socialProfileEndpointURL
    let query = try queryItems(for: endpointURL)

    #expect(endpointURL.path == "/v1/me/social/profile")
    #expect(query["include"] == "social-profile,followers,followees,pending-followers")
    #expect(query["extend"] == "followState,pendingFollowersCount")
    #expect(query["with"] == "nonOnboarded")
    #expect(query["format[resources]"] == "map")
    #expect(query["art[url]"] == "f")
  }

  @Test
  func profileEndpointCanOmitOptionalRelationships() throws {
    var request = try MusicSocialProfileRequest(developerToken: "test_token")
    request.includeFollowers = false
    request.includeFollowees = false
    request.includePendingFollowers = false
    request.allowNonOnboarded = false
    request.includeArtworkURLs = false

    let query = try queryItems(for: request.socialProfileEndpointURL)

    #expect(query["include"] == "social-profile")
    #expect(query["with"] == nil)
    #expect(query["art[url]"] == nil)
  }

  @Test
  func decodesPersonalProfileAndIncludedRelationships() throws {
    let data = try fixture(named: "socialProfile")
    let profile = try JSONDecoder().decode(PersonalMusicSocialProfile.self, from: data)

    #expect(profile.id == "me")
    #expect(profile.type == "personal-social-profiles")
    #expect(profile.attributes?.name == "Avery Appleseed")
    #expect(profile.attributes?.isOnboarded == true)
    #expect(profile.attributes?.pendingFollowersCount == 1)
    #expect(profile.socialProfile?.id == "social.me")
    #expect(profile.socialProfile?.attributes?.followState == .currentUser)
    #expect(profile.followers?.profiles.map(\.id) == ["social.follower"])
    #expect(profile.followers?.next == "/v1/me/social/profile/followers?offset=1")
    #expect(profile.followees?.profiles.map(\.id) == ["social.followee"])
    #expect(profile.pendingFollowers?.profiles.map(\.id) == ["social.pending"])
  }

  @Test
  func decodesMinimalProfileWithoutResourceMap() throws {
    let data = Data(
      """
      {"data":[{"id":"me","type":"personal-social-profiles","href":"/v1/me/social/profile"}]}
      """.utf8
    )

    let profile = try JSONDecoder().decode(PersonalMusicSocialProfile.self, from: data)

    #expect(profile.id == "me")
    #expect(profile.attributes == nil)
    #expect(profile.followers == nil)
  }

  @Test
  func preservesUnknownFollowState() throws {
    let data = Data(#""mutual""#.utf8)
    let state = try JSONDecoder().decode(SocialFollowState.self, from: data)

    #expect(state.rawValue == "mutual")
  }

  private func queryItems(for url: URL) throws -> [String: String?] {
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    return Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })
  }

  private func fixture(named name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
    return try Data(contentsOf: url)
  }
}
