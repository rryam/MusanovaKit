//
//  MusicSocialProfilesRequestTests.swift
//  MusanovaKitTests
//

import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct MusicSocialProfilesRequestTests {
  @Test(arguments: MusicSocialProfileRelationship.allCases)
  func constructsRelationshipEndpoint(_ relationship: MusicSocialProfileRelationship) throws {
    var request = try MusicSocialProfilesRequest(
      relationship: relationship,
      developerToken: "test_token"
    )
    request.limit = 40
    request.offset = 20

    let endpointURL = try request.socialProfilesEndpointURL
    let components = try #require(URLComponents(url: endpointURL, resolvingAgainstBaseURL: false))
    let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })

    #expect(endpointURL.path == "/v1/me/social/profile/\(relationship.rawValue)")
    #expect(query["limit"] == "40")
    #expect(query["offset"] == "20")
    #expect(query["extend"] == "followState")
    #expect(query["format[resources]"] == "map")
    #expect(query["art[url]"] == "f")
  }

  @Test
  func decodesPaginatedProfilesFromResourceMap() throws {
    let url = try #require(Bundle.module.url(forResource: "socialProfiles", withExtension: "json"))
    let data = try Data(contentsOf: url)
    let page = try JSONDecoder().decode(MusicSocialProfilesPage.self, from: data)

    #expect(page.profiles.count == 2)
    #expect(page.profiles[0].id == "social.one")
    #expect(page.profiles[0].attributes?.name == "Morgan")
    #expect(page.profiles[0].attributes?.followState == .following)
    #expect(page.profiles[1].attributes?.followState == .requested)
    #expect(page.next == "/v1/me/social/profile/followees?offset=2&limit=2")
  }

  @Test
  func rejectsMissingDeveloperToken() {
    #expect(throws: MusanovaKitError.self) {
      try MusicSocialProfilesRequest(relationship: .followers, developerToken: "")
    }
  }
}
