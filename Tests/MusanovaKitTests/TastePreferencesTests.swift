//
//  TastePreferencesTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 10/07/26.
//

import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct TastePreferencesTests {
  @Test
  func endpointURL() throws {
    let request = try MusicTastePreferencesRequest(developerToken: "test_token")

    #expect(try request.tastePreferencesEndpointURL == URL(string: "https://amp-api.music.apple.com/v1/me/taste/taste-preferences"))
  }

  @Test
  func emptyDeveloperToken() {
    #expect(throws: MusanovaKitError.self) {
      _ = try MusicTastePreferencesRequest(developerToken: "")
    }
  }

  @Test
  func responseDecoding() throws {
    let path = try #require(Bundle.module.path(forResource: "tastePreferences", ofType: "json"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))

    let response = try JSONDecoder().decode(TastePreferencesResponse.self, from: data)

    #expect(response.data.count == 3)
    #expect(response.data.map(\.id) == ["ob.l-1", "ob.l-2", "ob.l-3"])
    #expect(response.preferences.count == 3)

    let preferredGenre = try #require(response.preferences.first)
    #expect(preferredGenre.id == "ob.l-1")
    #expect(preferredGenre.type == "taste-preferences")
    #expect(preferredGenre.href == "/v1/me/taste/taste-preferences/ob.l-1")
    #expect(preferredGenre.attributes.name == "Alternative")
    #expect(preferredGenre.attributes.preference == 1)

    let preferenceWithoutHref = try #require(response.preferences.last)
    #expect(preferenceWithoutHref.href == nil)
    #expect(preferenceWithoutHref.attributes.preference == 2)
  }

  @Test
  func responseWithoutExpandedResourcesResolvesToEmptyPreferences() throws {
    let data = Data(#"{"data":[{"id":"ob.l-1","type":"taste-preferences"}]}"#.utf8)

    let response = try JSONDecoder().decode(TastePreferencesResponse.self, from: data)

    #expect(response.preferences.isEmpty)
  }
}
