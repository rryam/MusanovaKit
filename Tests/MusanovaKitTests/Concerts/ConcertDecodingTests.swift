import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct ConcertDecodingTests {
  @Test
  func decodesConcertDetail() throws {
    let response = try decodeFixture(ConcertFixtureResponse.self, named: "concertDetail")
    let concert = try #require(response.data.first)

    #expect(concert.id == "ce.example")
    #expect(concert.attributes.name == "Example Festival")
    #expect(concert.attributes.tickets?.first?.vendor == "Example Tickets")
    #expect(concert.attributes.eventDataProviders?.first?.name == "Example Provider")
    #expect(concert.relationships?.venues?.data.first?.attributes.structuredAddress?.city == "London")
    #expect(concert.relationships?.artists?.data.first?.attributes.name == "Example Artist")
    #expect(concert.relationships?.playlists?.data.first?.attributes.name == "Example Set List")
    #expect(concert.views?.moreUpcomingConcerts?.data.first?.id == "ce.next")
  }

  @Test
  func decodesHubAndPreservesContainerOrder() throws {
    let response = try decodeFixture(ConcertHubResponse.self, named: "concertHub")

    #expect(response.results.meta.containers.order == ["popular-concerts", "concerts-this-week"])
    #expect(response.results.orderedContainers.map(\.title) == ["Popular", "This Week"])
    #expect(response.results.orderedContainers.first?.data.first?.id == "ce.popular")
  }

  @Test
  func decodesArtistConcertViews() throws {
    let response = try decodeFixture(ConcertArtistPageResponse.self, named: "artistConcerts")
    let artist = try #require(response.data.first)

    #expect(artist.attributes?.name == "Example Artist")
    #expect(artist.views.allUpcomingConcerts.data.first?.id == "ce.anywhere")
    #expect(artist.views.nearbyUpcomingConcerts?.data.first?.id == "ce.nearby")
    #expect(artist.views.nearbyUpcomingConcerts?.meta?.count == 1)
  }
}

private struct ConcertFixtureResponse: Decodable {
  let data: [Concert]
}

private func decodeFixture<Value: Decodable>(_ type: Value.Type, named name: String) throws -> Value {
  let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
  return try JSONDecoder().decode(type, from: Data(contentsOf: url))
}
