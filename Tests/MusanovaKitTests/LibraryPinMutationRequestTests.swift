//
//  LibraryPinMutationRequestTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 10/07/26.
//

import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct LibraryPinMutationRequestTests {
  @Test
  func movePinAfterAnotherPinUsesPostAndAfterQuery() throws {
    let request = try MusicLibraryPinMutationRequest(
      pinID: "p.moved",
      developerToken: "test_token",
      mutation: .move(afterPinID: "p.preceding")
    )

    #expect(request.mutation.method == .post)
    try expectEndpoint(request.endpointURL, pinID: "p.moved", queryName: "after", value: "p.preceding")
  }

  @Test
  func movePinToTopUsesTopSentinel() throws {
    let request = try MusicLibraryPinMutationRequest(
      pinID: "p.moved",
      developerToken: "test_token",
      mutation: .move(afterPinID: nil)
    )

    #expect(request.mutation.method == .post)
    try expectEndpoint(request.endpointURL, pinID: "p.moved", queryName: "after", value: "top")
  }

  @Test(arguments: [LibraryPinPlaybackAction.play, .shuffle])
  func setPlaybackActionUsesPatch(action: LibraryPinPlaybackAction) throws {
    let request = try MusicLibraryPinMutationRequest(
      pinID: "p.example",
      developerToken: "test_token",
      mutation: .setPlaybackAction(action)
    )

    #expect(request.mutation.method == .patch)
    try expectEndpoint(request.endpointURL, pinID: "p.example", queryName: "action", value: action.rawValue)
  }

  @Test
  func mutationRequiresDeveloperToken() {
    #expect(throws: MusanovaKitError.self) {
      try MusicLibraryPinMutationRequest(
        pinID: "p.example",
        developerToken: "",
        mutation: .move(afterPinID: nil)
      )
    }
  }

  private func expectEndpoint(
    _ url: URL,
    pinID: String,
    queryName: String,
    value: String
  ) throws {
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

    #expect(components.scheme == "https")
    #expect(components.host == "amp-api.music.apple.com")
    #expect(components.path == "/v1/me/library/pins/\(pinID)")
    #expect(components.queryItems == [URLQueryItem(name: queryName, value: value)])
  }
}
