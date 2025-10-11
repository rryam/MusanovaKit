//
//  MusicSummariesMilestonesTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 07/04/23.
//

@testable import MusanovaKit
import Foundation
import MusicKit
import Testing

@Suite struct MusicSummariesMilestonesTests {
  @Test
  func testMusicSummariesMilestonesEndpointURL() throws {
    let request = MusicSummaryMilestonesRequest(year: 2022, types: [], developerToken: "")
    let endpointURL = try request.musicSummariesMilestonesEndpointURL
    let url = try #require(URL(string: "https://amp-api.music.apple.com/v1/me/music-summaries/milestones?ids=year-2022"))
    #expect(endpointURL == url)
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
    #expect(milestone.kind == MusicSummaryMilestoneKind.listenTime)

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
