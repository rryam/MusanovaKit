//
//  LyricsView.swift
//  Musanova
//
//  Created by Rudrank Riyam on 25/10/25.
//

import SwiftUI
import MusadoraKit
import MusanovaKit
import MusicKit

struct LyricsView: View {
    @State private var lyrics: LyricParagraphs = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var song: Song?
    @State private var currentTime: TimeInterval = 0
    @State private var isPlaying = false
    @State private var artworkURL: URL?

    private let player = ApplicationMusicPlayer.shared

    private let songID = MusicItemID("1837754303")

    var body: some View {
        NavigationStack {
            ZStack {
                if let artworkURL = artworkURL {
                    AsyncImage(url: artworkURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 20)
                            .opacity(0.3)
                            .overlay(
                                Color.black.opacity(0.7)
                            )
                    } placeholder: {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.9),
                                Color.purple.opacity(0.3),
                                Color.black.opacity(0.9)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .ignoresSafeArea()
                } else {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.9),
                            Color.purple.opacity(0.3),
                            Color.black.opacity(0.9)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Loading lyrics...")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.headline)
                        }
                        .frame(maxHeight: .infinity)
                    } else if let error = errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.6))
                            Text("Lyrics Unavailable")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text(error)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity)
                    } else if lyrics.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No Lyrics Available")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Lyrics for this song are not available")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        if let song = song {
                            VStack(spacing: 8) {
                                Text(song.title)
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                Text(song.artistName)
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))

                                if let albumTitle = song.albumTitle {
                                    Text(albumTitle)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        }

                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 24) {
                                    ForEach(lyrics) { paragraph in
                                        VStack(spacing: 16) {
                                            ForEach(paragraph.lines) { line in
                                                LyricLineView(
                                                    line: line,
                                                    currentTime: currentTime,
                                                    isPlaying: isPlaying
                                                )
                                                .id(line.id)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                            }
                            .onChange(of: currentTime) { oldValue, newValue in
                                if let currentLine = findCurrentLine(at: newValue) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(currentLine.id, anchor: .center)
                                    }
                                }
                            }
                        }

                        HStack(spacing: 40) {
                            Button(action: togglePlayback) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                            }

                            Button(action: resetPlayback) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Lyrics")
        }
        .onAppear {
            loadSongAndLyrics()
        }
        .onDisappear {
            player.stop()
        }
    }

    private func loadSongAndLyrics() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                print("Starting to load song with ID:", songID.rawValue)
                song = try await MCatalog.song(id: songID)
                print("Successfully fetched song:", song?.title ?? "Unknown title")

                if let song = song, let artworkURL = song.artwork?.url(width: 1000, height: 1000) {
                    self.artworkURL = artworkURL
                    print("Artwork URL:", artworkURL.absoluteString)
                }

                guard let developerToken = UserDefaults.standard.string(forKey: "developerToken"), !developerToken.isEmpty else {
                    print("No developer token found in UserDefaults")
                    errorMessage = "Developer token is required. Please set it in Settings."
                    isLoading = false
                    return
                }
                print("Found developer token, length:", developerToken.count)

                print("About to fetch lyrics for song:", song!.title)
                do {
                    lyrics = try await MCatalog.lyrics(for: song!, developerToken: developerToken)
                    print("Successfully fetched lyrics with", lyrics.count, "paragraphs")
                } catch {
                    print("Lyrics API failed:", error.localizedDescription)
                    throw error // Let it be handled by the outer catch blocks
                }

            } catch let lyricsError as LyricsError {
                switch lyricsError {
                case .apiError(let detail):
                    if detail.contains("No related resources found") {
                        errorMessage = "Lyrics are not available for this song. The Apple Music lyrics API may be temporarily unavailable or this song may not have lyrics."
                    } else if detail.contains("Empty response") {
                        errorMessage = "Unable to fetch lyrics. This may be due to authentication issues or the song not having lyrics available."
                    } else {
                        errorMessage = detail
                    }
                }
                print("Lyrics error:", lyricsError)
            } catch {
                errorMessage = error.localizedDescription
                print("Lyrics error:", error)
            }

            isLoading = false
        }
    }

    private func togglePlayback() {
        Task {
            do {
                if isPlaying {
                    player.stop()
                    isPlaying = false
                } else {
                    if let song = song {
                        player.queue = [song]
                        try await player.play()
                        isPlaying = true
                        startPlaybackObserver()
                    }
                }
            } catch {
                print("Playback error:", error.localizedDescription)
                errorMessage = "Failed to play song: \(error.localizedDescription)"
                isPlaying = false
            }
        }
    }

    private func resetPlayback() {
        player.stop()
        currentTime = 0
        isPlaying = false
        player.playbackTime = 0
    }

    private func startPlaybackObserver() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                currentTime = player.playbackTime
                isPlaying = player.state.playbackStatus == .playing
            }
        }
    }

    private func findCurrentLine(at time: TimeInterval) -> LyricLine? {
        for paragraph in lyrics {
            for line in paragraph.lines {
                if let lastSegment = line.segments.last {
                    if time >= line.segments.first?.startTime ?? 0 && time <= lastSegment.endTime {
                        return line
                    }
                }
            }
        }
        return nil
    }
}

struct LyricLineView: View {
    let line: LyricLine
    let currentTime: TimeInterval
    let isPlaying: Bool

    private var isCurrentLine: Bool {
        guard let firstSegment = line.segments.first,
              let lastSegment = line.segments.last else {
            return false
        }
        return currentTime >= firstSegment.startTime && currentTime <= lastSegment.endTime
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                ForEach(line.segments) { segment in
                    Text(segment.text)
                        .font(.system(size: 24, weight: isCurrentLine ? .semibold : .regular))
                        .foregroundColor(segmentColor(for: segment))
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .opacity(isCurrentLine ? 1.0 : 0.7)
    }

    private func segmentColor(for segment: LyricSegment) -> Color {
        if !isPlaying {
            return .white
        }

        if currentTime >= segment.startTime && currentTime <= segment.endTime {
            return .purple
        } else if currentTime > segment.endTime {
            return .white.opacity(0.8)
        } else {
            return .white.opacity(0.6)
        }
    }
}

#Preview {
    LyricsView()
}
