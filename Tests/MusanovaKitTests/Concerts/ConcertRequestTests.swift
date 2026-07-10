import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct ConcertRequestTests {
  @Test
  func hubURLIncludesFiltersAndLimits() throws {
    let options = ConcertHubOptions(
      containers: [.popular, .favoriteArtists],
      geoHashLocation: "gcpvj",
      dateRange: ConcertDateRange(startDate: "2026-07-10", endDate: "2026-07-31"),
      genreIDs: ["14", "21"],
      limits: [.popular: 6]
    )
    let request = try ConcertHubRequest(
      storefront: "gb",
      developerToken: "test-token",
      options: options
    )
    let url = try request.endpointURL
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)
    let query = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })

    #expect(url.path == "/v1/concerts/gb/hub")
    #expect(query["containers"] == "popular-concerts,favorite-artists-concerts")
    #expect(query["include[concerts]"] == "venues,artists")
    #expect(query["limit[popular-concerts]"] == "6")
    #expect(query["geoHashLocation"] == "gcpvj")
    #expect(query["filter[date]"] == "2026-07-10..2026-07-31")
    #expect(query["filter[genre]"] == "14,21")
  }

  @Test
  func detailURLRequestsTicketsAndRelationships() throws {
    let request = try ConcertDetailRequest(
      concertID: "ce.example",
      storefront: "in",
      developerToken: "test-token"
    )
    let url = try request.endpointURL
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)
    let query = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })

    #expect(url.path == "/v1/catalog/in/concerts/ce.example")
    #expect(query["include[concerts]"] == "venues,artists,playlists")
    #expect(query["extend[concerts]"] == "tickets,eventDataProviders,ticketDataProvider")
    #expect(query["views"] == "more-upcoming-concerts")
  }

  @Test
  func artistURLAddsNearbyViewOnlyWithLocation() throws {
    let request = try ArtistConcertsRequest(
      artistID: "1462541757",
      storefront: "in",
      geoHashLocation: "ttnfv",
      limit: 8,
      developerToken: "test-token"
    )
    let url = try request.endpointURL
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)
    let query = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })

    #expect(url.path == "/v1/catalog/in/artists/1462541757")
    #expect(query["views"] == "all-upcoming-concerts,nearby-upcoming-concerts")
    #expect(query["geoHashLocation"] == "ttnfv")
    #expect(query["limit[all-upcoming-concerts]"] == "8")
    #expect(query["limit[nearby-upcoming-concerts]"] == "8")
  }

  @Test
  func missingTokenIsRejected() {
    #expect(throws: MusanovaKitError.self) {
      try ConcertDetailRequest(concertID: "ce.example", storefront: "us", developerToken: "")
    }
  }
}
