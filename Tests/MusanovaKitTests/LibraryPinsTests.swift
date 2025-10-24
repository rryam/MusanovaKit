//
//  LibraryPinsTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation
import MusicKit
import Testing

@testable import MusanovaKit

@Suite
struct LibraryPinsTests {
  @Test
  func testMusicLibraryPinsEndpointURL() throws {
    let request = MusicLibraryPinsRequest(developerToken: "test_token")
    let endpointURL = try request.pinsEndpointURL

    // Verify the base URL and path
    let urlString = try #require(endpointURL.absoluteString)
    #expect(urlString.hasPrefix("https://amp-api.music.apple.com/v1/me/library/pins"))

    // Verify query parameters are present
    let components = try #require(URLComponents(url: endpointURL, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)

    // Check for expected default parameters
    let paramNames = queryItems.map { $0.name }
    #expect(paramNames.contains("art[url]"))
    #expect(paramNames.contains("fields[artists]"))
    #expect(paramNames.contains("format[resources]"))
    #expect(paramNames.contains("include[library-artists]"))
    #expect(paramNames.contains("include[library-music-videos]"))
    #expect(paramNames.contains("include[library-songs]"))
    #expect(paramNames.contains("l"))
    #expect(paramNames.contains("limit"))
    #expect(paramNames.contains("meta"))
  }

  @Test
  func testMusicLibraryPinsEndpointURLWithCustomParameters() throws {
    var request = MusicLibraryPinsRequest(developerToken: "test_token")
    request.limit = 10
    request.language = "es-ES"
    request.librarySongIncludes = ["albums"]

    let endpointURL = try request.pinsEndpointURL
    let components = try #require(URLComponents(url: endpointURL, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)

    // Convert to dictionary for easier testing
    let queryDict = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })

    #expect(queryDict["limit"] == "10")
    #expect(queryDict["l"] == "es-ES")
    #expect(queryDict["include[library-songs]"] == "albums")
    #expect(queryDict["art[url]"] == "f") // Should always be present now
  }

  @Test
  func testMusicLibraryPinsEndpointURLWithAllIncludesDisabled() throws {
    var request = MusicLibraryPinsRequest(developerToken: "test_token")
    request.libraryArtistIncludes = []
    request.libraryMusicVideoIncludes = []
    request.librarySongIncludes = []

    let endpointURL = try request.pinsEndpointURL
    let components = try #require(URLComponents(url: endpointURL, resolvingAgainstBaseURL: false))
    let queryItems = try #require(components.queryItems)
    let queryDict = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value) })

    // These should not be present when arrays are empty
    #expect(queryDict["include[library-artists]"] == nil)
    #expect(queryDict["include[library-music-videos]"] == nil)
    #expect(queryDict["include[library-songs]"] == nil)
  }

  @Test
  func testLibraryPinAttributesDecoding() throws {
    let jsonString = """
    {
      "name": "Test Song",
      "meta": {
        "pinnedDate": "2024-01-01"
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let attributes = try JSONDecoder().decode(LibraryPinAttributes.self, from: data)

    #expect(attributes.name == "Test Song")
    #expect(attributes.meta?["pinnedDate"] == "2024-01-01")
  }

  @Test
  func testLibraryPinRelationshipsDecoding() throws {
    let jsonString = """
    {
      "albums": {
        "data": [
          {
            "id": "album-123",
            "type": "albums",
            "attributes": {
              "name": "Test Album"
            }
          }
        ]
      },
      "artists": {
        "data": [
          {
            "id": "artist-456",
            "type": "artists",
            "attributes": {
              "name": "Test Artist"
            }
          }
        ]
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let relationships = try JSONDecoder().decode(LibraryPinRelationships.self, from: data)

    #expect(relationships.albums?.count == 1)
    #expect(relationships.artists?.count == 1)
    #expect(relationships.playlists == nil)
  }

  @Test
  func testLibraryPinDecoding() throws {
    let jsonString = """
    {
      "id": "song-123",
      "type": "songs",
      "attributes": {
        "name": "Test Song",
        "artwork": {
          "width": 300,
          "height": 300,
          "url": "https://example.com/artwork.jpg"
        }
      },
      "relationships": {
        "artists": {
          "data": [
            {
              "id": "artist-456",
              "type": "artists",
              "attributes": {
                "name": "Test Artist"
              }
            }
          ]
        }
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let pin = try JSONDecoder().decode(LibraryPin.self, from: data)

    #expect(pin.id.rawValue == "song-123")
    #expect(pin.type == "songs")
    #expect(pin.attributes.name == "Test Song")
    #expect(pin.relationships?.artists?.count == 1)
  }

  @Test
  func testMusicLibraryPinsResponseDecoding() throws {
    let jsonString = """
    {
      "data": [
        {
          "id": "l.Vkvyybh",
          "type": "library-albums",
          "href": "/v1/me/library/albums/l.Vkvyybh?l=en-GB"
        }
      ],
      "resources": {
        "library-albums": {
          "l.Vkvyybh": {
            "id": "l.Vkvyybh",
            "type": "library-albums",
            "href": "/v1/me/library/albums/l.Vkvyybh?l=en-GB",
            "attributes": {
              "artistName": "ABBA",
              "name": "ABBA Gold: Greatest Hits",
              "artwork": {
                "height": 1200,
                "width": 1200,
                "url": "https://example.com/artwork.jpg"
              }
            }
          }
        }
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let response = try JSONDecoder().decode(MusicLibraryPinsResponse.self, from: data)

    #expect(response.data.count == 1)
    #expect(response.data[0].id == "l.Vkvyybh")
    #expect(response.data[0].type == "library-albums")
    #expect(response.resources?.libraryAlbums?["l.Vkvyybh"] != nil) // Album exists in resources
  }
}
