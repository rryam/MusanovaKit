import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct EditorialTests {
  @Test
  func roomURLUsesAMPEditorialEndpoint() throws {
    let request = try MusicEditorialRoomRequest(
      id: "room-id",
      storefront: "gb",
      developerToken: "token"
    )

    #expect(
      try request.endpointURL.absoluteString
        == "https://amp-api.music.apple.com/v1/editorial/gb/rooms/room-id"
    )
  }

  @Test
  func multiroomURLUsesAMPEditorialEndpoint() throws {
    let request = try MusicEditorialMultiroomRequest(
      id: "multiroom-id",
      storefront: "us",
      developerToken: "token"
    )

    #expect(
      try request.endpointURL.absoluteString
        == "https://amp-api.music.apple.com/v1/editorial/us/multirooms/multiroom-id"
    )
  }

  @Test
  func requestsRejectEmptyDeveloperToken() {
    #expect(throws: MusanovaKitError.self) {
      try MusicEditorialRoomRequest(id: "room-id", storefront: "us", developerToken: "")
    }
    #expect(throws: MusanovaKitError.self) {
      try MusicEditorialMultiroomRequest(id: "multiroom-id", storefront: "us", developerToken: "")
    }
  }

  @Test
  func decodesRoomWithMixedCatalogResources() throws {
    let response: TestResponse<EditorialRoom> = try decodeFixture(named: "editorialRoom")
    let room = try #require(response.data.first)

    #expect(room.id == "room-example")
    #expect(room.attributes.title == "Featured Picks")
    #expect(room.attributes.defaultSort == "featured")
    #expect(room.contents.map(\.type) == ["artists", "albums", "future-resource"])
    #expect(room.contents[0].attributes?.name == "Example Artist")
    #expect(room.contents[1].attributes?.artistName == "Example Artist")
    #expect(room.contents[2].attributes?.title == "Future content")
  }

  @Test
  func decodesMultiroomHeroChildrenAndNestedContent() throws {
    let response: TestResponse<EditorialMultiroom> = try decodeFixture(named: "editorialMultiroom")
    let multiroom = try #require(response.data.first)

    #expect(multiroom.attributes.uber?.backgroundColor == "101010")
    #expect(multiroom.attributes.uber?.heroArtwork?.width == 2400)
    #expect(multiroom.children.count == 2)
    #expect(multiroom.children[0].attributes?.title == "Start here")
    #expect(multiroom.children[1].relationships?.contents?.data.first?.type == "playlists")
    #expect(
      multiroom.children[1].relationships?.contents?.data.first?.attributes?.description?.short
        == "A short description."
    )
    #expect(multiroom.children[1].relationships?.room?.data.first?.id == "child-room")
  }
}

private struct TestResponse<Resource: Decodable>: Decodable {
  let data: [Resource]
}

private func decodeFixture<Resource: Decodable>(named name: String) throws -> TestResponse<Resource> {
  let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
  return try JSONDecoder().decode(TestResponse<Resource>.self, from: Data(contentsOf: url))
}
