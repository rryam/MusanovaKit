//
//  Concert.swift
//  MusanovaKit
//

import Foundation

/// A concert returned by Apple Music's private concerts API.
public struct Concert: Codable, Hashable, Sendable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: ConcertAttributes
  public let relationships: ConcertRelationships?
  public let views: ConcertViews?
}

/// Descriptive and ticketing information for a concert.
public struct ConcertAttributes: Codable, Hashable, Sendable {
  public let name: String
  public let startISODateTime: String
  public let endISODateTime: String?
  public let timezone: String?
  public let url: URL?
  public let tickets: [ConcertTicket]?
  public let eventDataProviders: [ConcertProvider]?
}

/// A source that supplies concert or ticket information.
public struct ConcertProvider: Codable, Hashable, Sendable {
  public let name: String
  public let url: URL?
}

/// A link to buy a ticket from a named vendor.
public struct ConcertTicket: Codable, Hashable, Sendable {
  public let vendor: String?
  public let url: URL
  public let provider: ConcertProvider?
}

/// The resources related to a concert.
public struct ConcertRelationships: Codable, Hashable, Sendable {
  public let artists: ConcertRelationship<ConcertArtist>?
  public let venues: ConcertRelationship<ConcertVenue>?
  public let playlists: ConcertRelationship<ConcertPlaylist>?
}

/// A relationship in an Apple Music resource response.
public struct ConcertRelationship<Resource: Codable & Hashable & Sendable>: Codable, Hashable, Sendable {
  public let href: String?
  public let data: [Resource]
}

/// An artist attached to a concert.
public struct ConcertArtist: Codable, Hashable, Sendable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: ConcertArtistAttributes
}

/// Artist fields returned with a concert.
public struct ConcertArtistAttributes: Codable, Hashable, Sendable {
  public let name: String
  public let url: URL?
  public let genreNames: [String]?
  public let artwork: ConcertArtwork?
}

/// Artwork fields returned with concert artists and playlists.
public struct ConcertArtwork: Codable, Hashable, Sendable {
  public let url: String
  public let width: Int?
  public let height: Int?
  public let bgColor: String?
  public let textColor1: String?
  public let textColor2: String?
  public let textColor3: String?
  public let textColor4: String?
  public let hasP3: Bool?
}

/// A venue attached to a concert.
public struct ConcertVenue: Codable, Hashable, Sendable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: ConcertVenueAttributes
}

/// A venue's name, coordinates, and postal address.
public struct ConcertVenueAttributes: Codable, Hashable, Sendable {
  public let name: String
  public let geoLocation: ConcertGeoLocation?
  public let structuredAddress: ConcertAddress?
}

/// Geographic coordinates for a venue.
public struct ConcertGeoLocation: Codable, Hashable, Sendable {
  public let latitude: Double
  public let longitude: Double
}

/// A postal address for a concert venue.
public struct ConcertAddress: Codable, Hashable, Sendable {
  public let address: String?
  public let city: String?
  public let region: String?
  public let postCode: String?
  public let country: String?
  public let countryIsoCode: String?
}

/// A playlist attached to a concert, such as an artist's tour set list.
public struct ConcertPlaylist: Codable, Hashable, Sendable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: ConcertPlaylistAttributes
}

/// Playlist fields returned with a concert.
public struct ConcertPlaylistAttributes: Codable, Hashable, Sendable {
  public let name: String
  public let curatorName: String?
  public let url: URL?
  public let artwork: ConcertArtwork?
}

/// Additional concert collections returned beside a concert detail response.
public struct ConcertViews: Codable, Hashable, Sendable {
  public let moreUpcomingConcerts: ConcertView?

  enum CodingKeys: String, CodingKey {
    case moreUpcomingConcerts = "more-upcoming-concerts"
  }
}

/// A named view containing concerts.
public struct ConcertView: Codable, Hashable, Sendable {
  public let href: String?
  public let attributes: ConcertViewAttributes?
  public let data: [Concert]
  public let meta: ConcertViewMeta?
}

/// Display fields for a concert view.
public struct ConcertViewAttributes: Codable, Hashable, Sendable {
  public let title: String?
}

/// Count metadata returned with some concert views.
public struct ConcertViewMeta: Codable, Hashable, Sendable {
  public let count: Int?
}
