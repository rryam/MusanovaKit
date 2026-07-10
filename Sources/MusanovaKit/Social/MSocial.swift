//
//  MSocial.swift
//  MusanovaKit
//

/// A namespace for private Apple Music social APIs.
public enum MSocial {}

public extension MSocial {
  /// Fetches the current user's Apple Music social profile.
  ///
  /// - Parameter developerToken: The privileged developer token used to authorize the request.
  /// - Returns: The current user's social profile and its included relationships.
  /// - Note: This endpoint requires a privileged developer token and access to private Apple Music APIs.
  static func profile(developerToken: String) async throws -> PersonalMusicSocialProfile {
    let request = try MusicSocialProfileRequest(developerToken: developerToken)
    return try await request.response()
  }
}
