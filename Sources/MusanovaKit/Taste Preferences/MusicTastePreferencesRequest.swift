//
//  MusicTastePreferencesRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 10/07/26.
//

import Foundation

public extension MTaste {
  /// Fetches the taste preferences Apple Music uses to personalize recommendations.
  ///
  /// - Parameter developerToken: A privileged Apple Music developer token.
  /// - Returns: The taste-preference resources for the current Apple Music user.
  /// - Throws: An error if the request fails or its response cannot be decoded.
  ///
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  static func preferences(developerToken: String) async throws -> TastePreferencesResponse {
    let request = try MusicTastePreferencesRequest(developerToken: developerToken)
    return try await request.response()
  }
}

/// A request that fetches the current Apple Music user's taste preferences.
public struct MusicTastePreferencesRequest {
  private let developerToken: String

  /// Creates a taste-preferences request.
  ///
  /// - Parameter developerToken: A privileged Apple Music developer token. Must not be empty.
  /// - Throws: `MusanovaKitError.missingDeveloperToken` when the token is empty.
  public init(developerToken: String) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }

    self.developerToken = developerToken
  }

  /// Fetches and decodes the current user's taste preferences.
  public func response() async throws -> TastePreferencesResponse {
    do {
      let request = MusicPrivilegedDataRequest(url: try tastePreferencesEndpointURL, developerToken: developerToken)
      let response = try await request.response()

      do {
        return try JSONDecoder().decode(TastePreferencesResponse.self, from: response.data)
      } catch let decodingError as DecodingError {
        throw MusanovaKitError.decodingError(decodingError.localizedDescription)
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

extension MusicTastePreferencesRequest {
  var tastePreferencesEndpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/taste/taste-preferences"

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(
          description: "Failed to construct taste preferences URL with path: \(components.path)"
        )
      }

      return url
    }
  }
}
