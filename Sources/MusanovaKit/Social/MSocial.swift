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

  /// Fetches people who follow the current user's Apple Music profile.
  static func followers(
    developerToken: String,
    limit: Int = 20,
    offset: Int = 0
  ) async throws -> MusicSocialProfilesPage {
    try await profiles(in: .followers, developerToken: developerToken, limit: limit, offset: offset)
  }

  /// Fetches people whom the current user follows on Apple Music.
  static func followees(
    developerToken: String,
    limit: Int = 20,
    offset: Int = 0
  ) async throws -> MusicSocialProfilesPage {
    try await profiles(in: .followees, developerToken: developerToken, limit: limit, offset: offset)
  }

  /// Fetches follow requests awaiting the current user's approval.
  static func pendingFollowers(
    developerToken: String,
    limit: Int = 20,
    offset: Int = 0
  ) async throws -> MusicSocialProfilesPage {
    try await profiles(in: .pendingFollowers, developerToken: developerToken, limit: limit, offset: offset)
  }

  private static func profiles(
    in relationship: MusicSocialProfileRelationship,
    developerToken: String,
    limit: Int,
    offset: Int
  ) async throws -> MusicSocialProfilesPage {
    var request = try MusicSocialProfilesRequest(
      relationship: relationship,
      developerToken: developerToken
    )
    request.limit = limit
    request.offset = offset
    return try await request.response()
  }
}
