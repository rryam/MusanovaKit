//
//  MusicLibraryPinMutationRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 10/07/26.
//

import Foundation

/// The playback behavior used when a library pin is selected.
public enum LibraryPinPlaybackAction: String, Codable, Sendable {
  /// Plays the pinned item in its natural order.
  case play

  /// Shuffles the contents of the pinned item.
  case shuffle
}

enum MusicLibraryPinMutation: Sendable {
  case move(afterPinID: String?)
  case setPlaybackAction(LibraryPinPlaybackAction)

  var method: HTTPMethod {
    switch self {
    case .move:
      .post
    case .setPlaybackAction:
      .patch
    }
  }

  var queryItem: URLQueryItem {
    switch self {
    case let .move(afterPinID):
      URLQueryItem(name: "after", value: afterPinID ?? "top")
    case let .setPlaybackAction(action):
      URLQueryItem(name: "action", value: action.rawValue)
    }
  }
}

struct MusicLibraryPinMutationRequest {
  let developerToken: String
  let pinID: String
  let mutation: MusicLibraryPinMutation

  init(pinID: String, developerToken: String, mutation: MusicLibraryPinMutation) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }

    self.pinID = pinID
    self.developerToken = developerToken
    self.mutation = mutation
  }

  var endpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/library/pins/\(pinID)"
      components.queryItems = [mutation.queryItem]

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(
          description: "Failed to construct library pin mutation URL for pin: \(pinID)"
        )
      }

      return url
    }
  }

  func response() async throws {
    let request = MusicPrivilegedDataRequest(
      url: try endpointURL,
      developerToken: developerToken,
      method: mutation.method
    )
    _ = try await request.response()
  }
}
