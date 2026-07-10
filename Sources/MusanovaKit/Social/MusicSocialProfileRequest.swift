//
//  MusicSocialProfileRequest.swift
//  MusanovaKit
//

import Foundation

/// A request that fetches the current user's Apple Music social profile.
public struct MusicSocialProfileRequest: Sendable {
  private let developerToken: String

  public var allowNonOnboarded = true
  public var includeArtworkURLs = true

  /// Creates a social profile request.
  ///
  /// - Parameter developerToken: The privileged developer token used to authorize the request.
  public init(developerToken: String) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.developerToken = developerToken
  }

  /// Fetches and decodes the current user's Apple Music social profile.
  public func response() async throws -> PersonalMusicSocialProfile {
    do {
      let request = MusicPrivilegedDataRequest(
        url: try socialProfileEndpointURL,
        developerToken: developerToken
      )
      let response = try await request.response()

      do {
        return try JSONDecoder().decode(PersonalMusicSocialProfile.self, from: response.data)
      } catch let error as MusanovaKitError {
        throw error
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

extension MusicSocialProfileRequest {
  var socialProfileEndpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/social/profile"

      var queryItems = [
        URLQueryItem(name: "include", value: "social-profile"),
        URLQueryItem(name: "extend", value: "followState"),
        URLQueryItem(name: "format[resources]", value: "map")
      ]
      if allowNonOnboarded {
        queryItems.append(URLQueryItem(name: "with", value: "nonOnboarded"))
      }
      if includeArtworkURLs {
        queryItems.append(URLQueryItem(name: "art[url]", value: "f"))
      }
      components.queryItems = queryItems

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(
          description: "Failed to construct social profile endpoint URL with path: \(components.path)"
        )
      }
      return url
    }
  }
}
