//
//  MusicSummariesMilestonesTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation
import MusicKit
import Testing

@testable import MusanovaKit

@Suite
struct MusicSummariesMilestonesTests {
  @Test
  func testMusicSummariesMilestonesEndpointURL() throws {
    let request = try MusicSummaryMilestonesRequest(year: 2022, types: [], developerToken: "test_token")
    let endpointURL = try request.musicSummariesMilestonesEndpointURL
    let url = try #require(URL(string: "https://amp-api.music.apple.com/v1/me/music-summaries/milestones?ids=year-2022"))
    #expect(endpointURL == url)
  }

  // MARK: - URL Construction Edge Cases

  @Test
  func testMusicSummariesMilestonesEndpointURLWithTypes() throws {
    let request = try MusicSummaryMilestonesRequest(
      year: 2023,
      types: [.topArtists, .topSongs],
      developerToken: "test_token"
    )
    let endpointURL = try request.musicSummariesMilestonesEndpointURL
    let urlString = endpointURL.absoluteString

    #expect(urlString.contains("ids=year-2023"))
    // URL encoding: [ becomes %5B and ] becomes %5D
    #expect(urlString.contains("include") && urlString.contains("music-summaries-milestones"))
    #expect(urlString.contains("top-artists"))
    #expect(urlString.contains("top-songs"))
  }

  @Test
  func testMusicSummariesMilestonesEndpointURLWithAllTypes() throws {
    let request = try MusicSummaryMilestonesRequest(
      year: 2024,
      types: [.topArtists, .topSongs, .topAlbums],
      developerToken: "test_token"
    )
    let endpointURL = try request.musicSummariesMilestonesEndpointURL
    let urlString = endpointURL.absoluteString

    #expect(urlString.contains("ids=year-2024"))
    #expect(urlString.contains("top-artists"))
    #expect(urlString.contains("top-songs"))
    #expect(urlString.contains("top-albums"))
  }

  @Test
  func testMusicSummariesMilestonesEndpointURLWithDifferentYears() throws {
    let years = [2020, 2021, 2022, 2023, 2024]
    for year in years {
      let request = try MusicSummaryMilestonesRequest(year: MusicYearID(year), types: [], developerToken: "test_token")
      let endpointURL = try request.musicSummariesMilestonesEndpointURL
      let urlString = endpointURL.absoluteString
      #expect(urlString.contains("year-\(year)"))
    }
  }
  @Test
  func testMusicSummaryMilestonesDecoding() throws {
    let path = try #require(Bundle.module.path(forResource: "musicSummariesMilestones", ofType: "json"))
    let dataURL = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: dataURL)
    let response = try JSONDecoder().decode(MusicSummaryMilestonesResponse.self, from: data)

    #expect(response.milestones.count == 1)

    let milestone = try #require(response.milestones.first)
    #expect(milestone.id == "year-2023-listen-time-minutes-5000")
    #expect(milestone.listenTimeInMinutes == 5955)
    #expect(milestone.dateReached == "2023-02-03")
    #expect(milestone.value == "5000")
    #expect(milestone.kind == .listenTime)

    let topSongs = milestone.topSongs
    #expect(topSongs.count == 3)
    let firstSong = try #require(topSongs.first)
    #expect(firstSong.id == "1625328892")

    let topArtists = milestone.topArtists
    #expect(topArtists.count == 3)
    let firstArtist = try #require(topArtists.first)
    #expect(firstArtist.id == "1258279972")

    let topAlbums = milestone.topAlbums
    #expect(topAlbums.count == 3)
    let firstAlbum = try #require(topAlbums.first)
    #expect(firstAlbum.id == "1649039960")
  }
}
