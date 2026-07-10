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

    let preferredGenre = try #require(response.data.first)
    #expect(preferredGenre.id == "ob.l-1")
    #expect(preferredGenre.type == "taste-preferences")
    #expect(preferredGenre.href == "/v1/me/taste/taste-preferences/ob.l-1")
    #expect(preferredGenre.attributes.name == "Alternative")
    #expect(preferredGenre.attributes.preference == 1)

    let preferenceWithoutHref = try #require(response.data.last)
    #expect(preferenceWithoutHref.href == nil)
    #expect(preferenceWithoutHref.attributes.preference == 2)
  }
}
