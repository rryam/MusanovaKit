//
//  ReplayViewModel.swift
//  Musanova
//
//  Created by AI Assistant on 10/24/25.
//

import Foundation
import MusanovaKit
import MusadoraKit
import MusicKit
import Observation

@MainActor
@Observable
class ReplayViewModel {
  var selectedYear: Int?
  var availableYears: [Int] = []
  var topArtists: Artists = []
  var topAlbums: Albums = []
  var topSongs: Songs = []
  var title: String = ""
  var subtitle: String?
  var isEligible: Bool = false
  var isLoading: Bool = false
  var errorMessage: String?
  var summaries: [MusicSummarySearch] = []
  
  private var developerToken: String? {
    UserDefaults.standard.string(forKey: "developerToken")
  }

  func checkEligibilityAndLoad() async {
    errorMessage = nil
    isEligible = false

    let status = MusicAuthorization.currentStatus
    print("[Replay] MusicAuthorization status: \(status)")
    guard status == .authorized else {
      errorMessage = "Not authorized for Apple Music. Tap Continue on the welcome screen."
      print("[Replay] Not authorized: \(status)")
      return
    }

    print("[Replay] Checking subscription...")
    let subscription: MusicSubscription? = try? await MusicSubscription.current
    print("[Replay] Subscription: \(subscription?.canPlayCatalogContent ?? false)")
    guard subscription?.canPlayCatalogContent == true else {
      errorMessage = "Requires an active Apple Music subscription to load Replay."
      print("[Replay] No active subscription")
      return
    }

    print("[Replay] All checks passed, loading summaries...")
    await loadSummaries()
  }

  func loadSummaries() async {
    guard !isLoading else { return }

    errorMessage = nil
    isLoading = true
    defer { isLoading = false }

    do {
      print("[Replay] Starting to fetch music summaries")
      
      guard let token = developerToken, !token.isEmpty else {
        errorMessage = "Developer token is required. Please set it in Settings."
        print("[Replay] ERROR: Developer token is missing or empty")
        return
      }
      
      print("[Replay] Fetching music summaries with developer token")
      let fetchedSummaries = try await MSummaries.search(developerToken: token)
      
      print("[Replay] Summaries fetched successfully")
      print("[Replay] Number of summaries: \(fetchedSummaries.count)")
      
      self.summaries = Array(fetchedSummaries)
      self.availableYears = self.summaries.map { $0.year }.sorted(by: >)
      
      if !self.summaries.isEmpty {
        self.selectedYear = self.summaries.first?.year
        await loadPlaylistSongs()
      }
      
      isEligible = true
      print("[Replay] Successfully loaded music summaries")
      
    } catch is CancellationError {
      print("[Replay] Task cancelled")
    } catch {
      print("[Replay] Unexpected error: \(error)")
      print("[Replay] Error type: \(type(of: error))")
      print("[Replay] Error description: \(error.localizedDescription)")
      errorMessage = "Could not load Replay (\(error.localizedDescription))."
      topArtists = []
      topAlbums = []
      topSongs = []
      isEligible = false
    }
  }
  
  func loadPlaylistSongs() async {
    guard let year = selectedYear else { return }
    guard let summary = summaries.first(where: { $0.year == year }) else { return }
    
    do {
      print("[Replay] Fetching songs for year \(year)")
      
      let playlist = try await MCatalog.playlist(id: summary.playlist.id, fetch: .tracks)
      
      let tracks = Array(playlist.tracks ?? [])
      print("[Replay] Fetched \(tracks.count) tracks from playlist")
      
      // Extract songs from tracks
      let songs: [Song] = tracks.compactMap { track -> Song? in
        switch track {
        case .song(let song):
          return song
        default:
          return nil
        }
      }
      
      topSongs = MusicItemCollection(songs)
      print("[Replay] Extracted \(songs.count) songs from tracks")
      
      // Extract unique artists and albums
      var artistDict: [String: Artist] = [:]
      var albumDict: [String: Album] = [:]
      
      for song in songs {
        // Fetch full song details to get artist and album info
        var songRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: song.id)
        songRequest.properties = [.artists, .albums]
        do {
          let response = try await songRequest.response()
          if let fullSong = response.items.first {
            if let artist = fullSong.artists?.first {
              artistDict[artist.id.rawValue] = artist
            }
            if let album = fullSong.albums?.first {
              albumDict[album.id.rawValue] = album
            }
          }
        } catch {
          print("[Replay] Error fetching song details: \(error)")
        }
      }
      
      topArtists = MusicItemCollection(Array(artistDict.values))
      topAlbums = MusicItemCollection(Array(albumDict.values))
      
      print("[Replay] Extracted \(topArtists.count) artists and \(topAlbums.count) albums")
      
      title = "Year: \(year)"
      subtitle = summary.playlist.name
      
    } catch {
      print("[Replay] Error loading playlist songs: \(error)")
    }
  }
}
