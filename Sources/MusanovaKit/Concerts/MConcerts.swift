//
//  MConcerts.swift
//  MusanovaKit
//

import Foundation

/// Access to Apple Music's private concerts API.
public enum MConcerts {
  /// Loads the concerts hub for a storefront.
  public static func hub(
    storefront: String,
    developerToken: String,
    options: ConcertHubOptions = ConcertHubOptions()
  ) async throws -> ConcertHub {
    let request = try ConcertHubRequest(
      storefront: storefront,
      developerToken: developerToken,
      options: options
    )
    return try await request.response()
  }

  /// Loads one concert, including venues, artists, playlists, and ticket information.
  public static func concert(
    id: String,
    storefront: String,
    developerToken: String
  ) async throws -> Concert {
    let request = try ConcertDetailRequest(
      concertID: id,
      storefront: storefront,
      developerToken: developerToken
    )
    return try await request.response()
  }

  /// Loads all upcoming concerts for an artist and, when supplied, a nearby view.
  public static func upcomingConcerts(
    forArtistID artistID: String,
    storefront: String,
    geoHashLocation: String? = nil,
    limit: Int? = nil,
    developerToken: String
  ) async throws -> ArtistUpcomingConcerts {
    let request = try ArtistConcertsRequest(
      artistID: artistID,
      storefront: storefront,
      geoHashLocation: geoHashLocation,
      limit: limit,
      developerToken: developerToken
    )
    return try await request.response()
  }
}
