//
//  LibraryPinMetaTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation
import MusicKit
import Testing

@testable import MusanovaKit

@Suite
struct LibraryPinMetaTests {
  @Test
  func testLibraryPinDecodingWithMeta() throws {
    let jsonString = """
    {
      "id": "i.NJv0a0zSPkNPdW6",
      "type": "library-songs",
      "href": "/v1/me/library/songs/i.NJv0a0zSPkNPdW6?l=en-GB",
      "attributes": {
        "albumName": "Hurry Up Tomorrow",
        "artistName": "The Weeknd & Lana Del Rey",
        "name": "The Abyss"
      },
      "meta": {
        "libraryPin": {
          "action": "play",
          "positionUUID": "321069fb-bf1b-41ed-a239-0ae56fa7b35d"
        }
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let pin = try JSONDecoder().decode(LibraryPin.self, from: data)

    #expect(pin.id.rawValue == "i.NJv0a0zSPkNPdW6")
    #expect(pin.type == "library-songs")
    #expect(pin.libraryPin != nil)

    let libraryPin = try #require(pin.libraryPin)
    #expect(libraryPin.action == "play")
    #expect(libraryPin.positionUUID == "321069fb-bf1b-41ed-a239-0ae56fa7b35d")
  }

  @Test
  func testLibraryPinDecodingWithDrillInAction() throws {
    let jsonString = """
    {
      "id": "p.YJXV7pVIRA1R7XD",
      "type": "library-playlists",
      "href": "/v1/me/library/playlists/p.YJXV7pVIRA1R7XD?l=en-GB",
      "attributes": {
        "name": "Replay 2025"
      },
      "meta": {
        "libraryPin": {
          "action": "drillIn",
          "positionUUID": "DC6E1538-7515-4FF7-86D7-2CBF28790BDF"
        }
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let pin = try JSONDecoder().decode(LibraryPin.self, from: data)

    #expect(pin.id.rawValue == "p.YJXV7pVIRA1R7XD")
    #expect(pin.type == "library-playlists")
    #expect(pin.libraryPin != nil)

    let libraryPin = try #require(pin.libraryPin)
    #expect(libraryPin.action == "drillIn")
    #expect(libraryPin.positionUUID == "DC6E1538-7515-4FF7-86D7-2CBF28790BDF")
  }

  @Test
  func testLibraryPinDecodingWithoutMeta() throws {
    let jsonString = """
    {
      "id": "l.b8GkeFs",
      "type": "library-albums",
      "href": "/v1/me/library/albums/l.b8GkeFs?l=en-GB",
      "attributes": {
        "name": "Hurry Up Tomorrow"
      }
    }
    """

    let data = try #require(jsonString.data(using: .utf8))
    let pin = try JSONDecoder().decode(LibraryPin.self, from: data)

    #expect(pin.id.rawValue == "l.b8GkeFs")
    #expect(pin.type == "library-albums")
    #expect(pin.libraryPin == nil)
  }

  @Test
  func testLibraryPinDecodingWithMultipleActions() throws {
    let songJson = """
    {
      "id": "i.NJv0a0zSPkNPdW6",
      "type": "library-songs",
      "href": "/v1/me/library/songs/i.NJv0a0zSPkNPdW6?l=en-GB",
      "attributes": {
        "name": "The Abyss"
      },
      "meta": {
        "libraryPin": {
          "action": "play",
          "positionUUID": "321069fb-bf1b-41ed-a239-0ae56fa7b35d"
        }
      }
    }
    """

    let playlistJson = """
    {
      "id": "p.YJXV7pVIRA1R7XD",
      "type": "library-playlists",
      "href": "/v1/me/library/playlists/p.YJXV7pVIRA1R7XD?l=en-GB",
      "attributes": {
        "name": "Replay 2025"
      },
      "meta": {
        "libraryPin": {
          "action": "drillIn",
          "positionUUID": "DC6E1538-7515-4FF7-86D7-2CBF28790BDF"
        }
      }
    }
    """

    let songData = try #require(songJson.data(using: .utf8))
    let song = try JSONDecoder().decode(LibraryPin.self, from: songData)
    #expect(song.libraryPin?.action == "play")

    let playlistData = try #require(playlistJson.data(using: .utf8))
    let playlist = try JSONDecoder().decode(LibraryPin.self, from: playlistData)
    #expect(playlist.libraryPin?.action == "drillIn")
  }
}
