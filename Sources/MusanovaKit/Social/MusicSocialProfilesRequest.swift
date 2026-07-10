//
//  MusicSocialProfilesRequest.swift
//  MusanovaKit
//

import Foundation

/// A request that fetches one relationship from the current user's Apple Music social profile.
public struct MusicSocialProfilesRequest: Sendable {
  public let relationship: MusicSocialProfileRelationship

  private let developerToken: String

  public var limit = 20
  public var offset = 0
  public var includeArtworkURLs = true

  /// Creates a social relationship request.
  public init(
    relationship: MusicSocialProfileRelationship,
    developerToken: String
  ) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.relationship = relationship
    self.developerToken = developerToken
  }

  /// Fetches and decodes a page of Apple Music social profiles.
  public func response() async throws -> MusicSocialProfilesPage {
    do {
      let request = MusicPrivilegedDataRequest(
        url: try socialProfilesEndpointURL,
        developerToken: developerToken
      )
      let response = try await request.response()

      do {
        return try JSONDecoder().decode(MusicSocialProfilesPage.self, from: response.data)
      } catch let error as DecodingError {
        throw MusanovaKitError.decodingError(error.localizedDescription)
      } catch {
        throw MusanovaKitError.decodingError(error.localizedDescription)
      }
    } catch let error as MusanovaKitError {
      throw error
    } catch let error as URLError {
      throw MusanovaKitError.networkError(error.localizedDescription)
    } catch {
      throw MusanovaKitError.networkError(error.localizedDescription)
    }
  }
}

extension MusicSocialProfilesRequest {
  var socialProfilesEndpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/social/profile/\(relationship.rawValue)"

      var queryItems = [
        URLQueryItem(name: "limit", value: String(limit)),
        URLQueryItem(name: "offset", value: String(offset)),
        URLQueryItem(name: "extend", value: "followState"),
        URLQueryItem(name: "format[resources]", value: "map")
      ]
      if includeArtworkURLs {
        queryItems.append(URLQueryItem(name: "art[url]", value: "f"))
      }
      components.queryItems = queryItems

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(
          description: "Failed to construct social relationship endpoint URL with path: \(components.path)"
        )
      }
      return url
    }
  }
}
