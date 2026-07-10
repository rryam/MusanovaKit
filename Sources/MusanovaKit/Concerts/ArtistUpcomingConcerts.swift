//
//  ArtistUpcomingConcerts.swift
//  MusanovaKit
//

import Foundation

/// Upcoming concert views returned for an Apple Music artist.
public struct ArtistUpcomingConcerts: Codable, Hashable, Sendable {
  public let artistID: String
  public let artistName: String?
  public let all: ConcertView
  public let nearby: ConcertView?
}

struct ConcertArtistPageResponse: Decodable {
  let data: [ConcertArtistPage]
}

struct ConcertArtistPage: Decodable {
  let id: String
  let attributes: ConcertArtistAttributes?
  let views: ConcertArtistViews
}

struct ConcertArtistViews: Decodable {
  let allUpcomingConcerts: ConcertView
  let nearbyUpcomingConcerts: ConcertView?

  enum CodingKeys: String, CodingKey {
    case allUpcomingConcerts = "all-upcoming-concerts"
    case nearbyUpcomingConcerts = "nearby-upcoming-concerts"
  }
}
