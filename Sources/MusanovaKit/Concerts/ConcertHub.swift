//
//  ConcertHub.swift
//  MusanovaKit
//

import Foundation

/// A section supported by Apple Music's concerts hub.
public enum ConcertHubContainerKind: String, CaseIterable, Codable, Hashable, Sendable {
  case thisWeek = "concerts-this-week"
  case nextWeek = "concerts-next-week"
  case popular = "popular-concerts"
  case favoriteArtists = "favorite-artists-concerts"
  case allUpcoming = "all-upcoming-concerts"
  case moreUpcoming = "more-upcoming-concerts"
}

/// A calendar-date filter for the concerts hub.
public struct ConcertDateRange: Codable, Hashable, Sendable {
  /// The first date to include, formatted as `yyyy-MM-dd`.
  public let startDate: String

  /// The last date to include, formatted as `yyyy-MM-dd`.
  public let endDate: String

  public init(startDate: String, endDate: String) {
    self.startDate = startDate
    self.endDate = endDate
  }
}

/// Options for loading the concerts hub.
public struct ConcertHubOptions: Hashable, Sendable {
  public var containers: [ConcertHubContainerKind]
  public var geoHashLocation: String?
  public var dateRange: ConcertDateRange?
  public var genreIDs: [String]
  public var limits: [ConcertHubContainerKind: Int]

  public init(
    containers: [ConcertHubContainerKind] = ConcertHubContainerKind.allCases,
    geoHashLocation: String? = nil,
    dateRange: ConcertDateRange? = nil,
    genreIDs: [String] = [],
    limits: [ConcertHubContainerKind: Int] = [.thisWeek: 12, .nextWeek: 12]
  ) {
    self.containers = containers
    self.geoHashLocation = geoHashLocation
    self.dateRange = dateRange
    self.genreIDs = genreIDs
    self.limits = limits
  }
}

/// The ordered sections and concert resources in a concerts hub response.
public struct ConcertHub: Codable, Hashable, Sendable {
  public let containers: [String: ConcertHubContainer]
  public let meta: ConcertHubMeta

  /// Containers in the order supplied by Apple Music.
  public var orderedContainers: [ConcertHubContainer] {
    meta.containers.order.compactMap { containers[$0] }
  }
}

/// A named section in the concerts hub.
public struct ConcertHubContainer: Codable, Hashable, Sendable {
  public let href: String?
  public let title: String?
  public let data: [Concert]
}

/// Metadata for the concerts hub.
public struct ConcertHubMeta: Codable, Hashable, Sendable {
  public let containers: ConcertHubContainerOrder
}

/// The server-selected order of hub container identifiers.
public struct ConcertHubContainerOrder: Codable, Hashable, Sendable {
  public let order: [String]
}

struct ConcertHubResponse: Decodable {
  let results: ConcertHub
}
