//
//  LyricsViewModel.swift
//  Musanova
//

import Foundation
import MusadoraKit
import MusanovaKit
import MusicKit
import Observation

@MainActor
@Observable
final class LyricsViewModel {
  private(set) var lyrics: LyricParagraphs = []
  private(set) var song: Song?
  private(set) var isLoading = false
  private(set) var currentTime: TimeInterval = 0
  private(set) var isPlaying = false
  private(set) var currentLineID: LyricLine.ID?
  var errorMessage: String?
  var playbackErrorMessage: String?

  private let player = ApplicationMusicPlayer.shared
  private let songID = MusicItemID("1710156085")
  private var playbackObservation: Task<Void, Never>?
  private var playbackItem: LyricsPlaybackItem?
  private var hasPreparedQueue = false

  var songTitle: String { song?.title ?? "Meri Baaton Mein Tu" }
  var artistName: String { song?.artistName ?? "Anuv Jain" }

  var artworkURL: URL? {
    song?.artwork?.url(width: 1200, height: 1200) ?? fallbackArtworkURL
  }

  var duration: TimeInterval {
    song?.duration ?? lyrics.flatMap(\.lines).flatMap(\.segments).map(\.endTime).max() ?? 0
  }

  var canPlay: Bool { song != nil || playbackItem != nil }

  var formattedRemainingTime: String {
    guard duration > 0 else { return "" }
    return "−\(formatTime(max(0, duration - currentTime)))"
  }

  var formattedPlaybackTime: String {
    formatTime(currentTime)
  }

  func load() async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      guard let developerToken = UserDefaults.standard.string(forKey: "developerToken"),
            !developerToken.isEmpty else {
        errorMessage = "Add your AMP developer token in Settings to load lyrics."
        return
      }

      let storefront = (try? await MusicDataRequest.currentCountryCode.lowercased()) ?? "in"
      let request = try MusicLyricsRequest(songID: songID, developerToken: developerToken)
      let response = try await request.response(countryCode: storefront)
      guard let rawTTML = response.rawTTML else {
        lyrics = []
        return
      }
      lyrics = LyricsParser().parse(rawTTML)
      if let playParams = response.data.first?.attributes.playParams,
         let encodedPlayParams = try? JSONEncoder().encode(playParams),
         let musicPlayParams = try? JSONDecoder().decode(PlayParameters.self, from: encodedPlayParams) {
        playbackItem = LyricsPlaybackItem(id: songID, playParameters: musicPlayParams)
      }
      song = try? await loadSong(storefront: storefront, developerToken: developerToken)
    } catch is CancellationError {
      return
    } catch {
      errorMessage = lyricErrorMessage(error)
    }
  }

  func togglePlayback() async {
    if isPlaying {
      stopPlaybackObservation()
      player.pause()
      isPlaying = false
      return
    }

    guard canPlay else { return }
    playbackErrorMessage = nil
    do {
      if !hasPreparedQueue {
        if let song {
          player.queue = [song]
        } else if let playbackItem {
          player.queue = ApplicationMusicPlayer.Queue(for: [playbackItem])
        }
        hasPreparedQueue = true
      }
      try await player.play()
      isPlaying = true
      startPlaybackObservation()
    } catch {
      playbackErrorMessage = "Playback could not start. \(error.localizedDescription)"
      isPlaying = false
    }
  }

  func resetPlayback() {
    player.stop()
    player.playbackTime = 0
    currentTime = 0
    currentLineID = nil
    isPlaying = false
    stopPlaybackObservation()
  }

  func stop() {
    player.stop()
    isPlaying = false
    hasPreparedQueue = false
    stopPlaybackObservation()
  }

  private func startPlaybackObservation() {
    stopPlaybackObservation()
    playbackObservation = Task { [weak self] in
      while !Task.isCancelled {
        guard let self else { return }
        self.currentTime = self.player.playbackTime
        self.currentLineID = self.currentLine(at: self.currentTime)?.id
        self.isPlaying = self.player.state.playbackStatus == .playing
        try? await Task.sleep(for: .milliseconds(150))
      }
    }
  }

  private func stopPlaybackObservation() {
    playbackObservation?.cancel()
    playbackObservation = nil
  }

  private func currentLine(at time: TimeInterval) -> LyricLine? {
    let lines = lyrics.flatMap(\.lines).filter { $0.segments.first != nil }
    guard !lines.isEmpty else { return nil }

    var lowerBound = 0
    var upperBound = lines.count - 1
    var latestStartedLine: LyricLine?
    while lowerBound <= upperBound {
      let midpoint = (lowerBound + upperBound) / 2
      let line = lines[midpoint]
      guard let startTime = line.segments.first?.startTime else { return latestStartedLine }
      if time < startTime {
        upperBound = midpoint - 1
      } else {
        latestStartedLine = line
        lowerBound = midpoint + 1
      }
    }
    return latestStartedLine
  }

  private func lyricErrorMessage(_ error: any Error) -> String {
    guard let error = error as? MusanovaKitError else {
      return "Lyrics could not be loaded. \(error.localizedDescription)"
    }
    switch error {
    case .missingDeveloperToken:
      return "Add your AMP developer token in Settings to load lyrics."
    case .apiError(let message, _, _):
      return message
    default:
      return error.localizedDescription
    }
  }

  private func loadSong(storefront: String, developerToken: String) async throws -> Song {
    var components = AppleMusicAMPURLComponents()
    components.path = "catalog/\(storefront)/songs/\(songID.rawValue)"
    guard let url = components.url else {
      throw MusanovaKitError.invalidURL(description: "Could not build the catalog song URL.")
    }
    let response = try await MusicPrivilegedDataRequest(
      url: url,
      developerToken: developerToken
    ).response()
    let catalogResponse = try JSONDecoder().decode(CatalogSongResponse.self, from: response.data)
    guard let song = catalogResponse.data.first else {
      throw MusanovaKitError.emptyResponse
    }
    return song
  }

  private var fallbackArtworkURL: URL? {
    URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/c5/e2/ae/c5e2ae66-e4fe-02b6-d54c-c05fb36a2936/23UM1IM18503.rgb.jpg/1200x1200bb.jpg")
  }

  private func formatTime(_ time: TimeInterval) -> String {
    let seconds = max(0, Int(time))
    return String(format: "%d:%02d", seconds / 60, seconds % 60)
  }

}

private struct LyricsPlaybackItem: PlayableMusicItem {
  let id: MusicItemID
  let playParameters: PlayParameters?
}

private struct CatalogSongResponse: Decodable {
  let data: [Song]
}
