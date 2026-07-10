//
//  LyricsView.swift
//  Musanova
//

import MusanovaKit
import MusicKit
import SwiftUI

struct LyricsView: View {
  @State private var viewModel = LyricsViewModel()
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    NavigationStack {
      ZStack {
        lyricBackdrop

        if viewModel.isLoading {
          ProgressView("Listening for the words…")
            .tint(.white)
            .foregroundStyle(.white)
        } else if let errorMessage = viewModel.errorMessage {
          unavailableState(errorMessage)
        } else if viewModel.lyrics.isEmpty {
          unavailableState("Apple Music did not return lyrics for this song.")
        } else {
          lyricExperience
        }
      }
      .navigationTitle("Lyrics")
      .toolbarBackground(.hidden, for: .windowToolbar)
    }
    .task { await viewModel.load() }
    .onDisappear(perform: viewModel.stop)
  }

  private var lyricBackdrop: some View {
    ZStack {
      Color.black
      if let artworkURL = viewModel.artworkURL {
        AsyncImage(url: artworkURL) { image in
          image
            .resizable()
            .scaledToFill()
        } placeholder: {
          Color.black
        }
        .blur(radius: 48)
        .scaleEffect(1.18)
        .opacity(0.55)
      }
      LinearGradient(
        colors: [.black.opacity(0.28), .black.opacity(0.78)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
    .ignoresSafeArea()
    .accessibilityHidden(true)
  }

  private var lyricExperience: some View {
    HStack(spacing: 44) {
      nowPlayingPanel

      lyricScroller
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  private var nowPlayingPanel: some View {
    VStack(alignment: .leading, spacing: 18) {
      Spacer(minLength: 16)

      Group {
        if let artwork = viewModel.song?.artwork {
          ArtworkImage(artwork, width: 260, height: 260)
        } else if let artworkURL = viewModel.artworkURL {
          AsyncImage(url: artworkURL) { image in
            image
              .resizable()
              .scaledToFill()
          } placeholder: {
            ProgressView()
              .tint(.white)
          }
        } else {
          RoundedRectangle(cornerRadius: 20)
            .fill(.white.opacity(0.1))
            .overlay {
              Image(systemName: "music.note")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            }
        }
      }
      .frame(width: 260, height: 260)
      .clipShape(.rect(cornerRadius: 20))
      .shadow(color: .black.opacity(0.35), radius: 26, y: 14)

      VStack(alignment: .leading, spacing: 5) {
        Text(viewModel.songTitle)
          .font(.title2.bold())
          .foregroundStyle(.white)
          .lineLimit(2)
        Text(viewModel.artistName)
          .font(.headline)
          .foregroundStyle(.white.opacity(0.7))
        if let albumTitle = viewModel.song?.albumTitle {
          Text(albumTitle)
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.5))
            .lineLimit(1)
        }
      }

      if viewModel.duration > 0 {
        VStack(spacing: 5) {
          ProgressView(value: viewModel.currentTime, total: viewModel.duration)
            .progressViewStyle(.linear)
            .tint(.white)
          HStack {
            Text(viewModel.formattedPlaybackTime)
            Spacer()
            Text(viewModel.formattedRemainingTime)
          }
          .font(.caption2.monospacedDigit())
          .foregroundStyle(.white.opacity(0.52))
        }
      }

      HStack(spacing: 34) {
        Button {
          viewModel.seek(by: -15)
        } label: {
          Label("Back 15 seconds", systemImage: "gobackward.15")
        }
        .help("Back 15 seconds")

        Button {
          Task { await viewModel.togglePlayback() }
        } label: {
          Label(viewModel.isPlaying ? "Pause" : "Play", systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill")
        }
        .font(.system(size: 34, weight: .semibold))
        .help(viewModel.isPlaying ? "Pause" : "Play")

        Button {
          viewModel.seek(by: 15)
        } label: {
          Label("Forward 15 seconds", systemImage: "goforward.15")
        }
        .help("Forward 15 seconds")
      }
      .font(.system(size: 26, weight: .semibold))
      .foregroundStyle(.white.opacity(0.9))
      .labelStyle(.iconOnly)
      .buttonStyle(.plain)
      .disabled(!viewModel.canPlay)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 4)

      if viewModel.duration == 0 {
        Text(viewModel.formattedPlaybackTime)
          .font(.caption.monospacedDigit())
          .foregroundStyle(.white.opacity(0.55))
      }

      if let playbackErrorMessage = viewModel.playbackErrorMessage {
        Text(playbackErrorMessage)
          .font(.caption)
          .foregroundStyle(.white.opacity(0.62))
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 16)
    }
    .padding(30)
    .frame(width: 340)
  }

  private var lyricScroller: some View {
    ScrollViewReader { proxy in
      GeometryReader { geometry in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 54) {
            ForEach(viewModel.lyrics) { paragraph in
              VStack(alignment: .leading, spacing: 46) {
                ForEach(paragraph.lines) { line in
                  Button {
                    viewModel.seek(to: line)
                  } label: {
                    LyricLineView(
                      line: line,
                      isCurrent: line.id == viewModel.currentLineID,
                      hasPlaybackStarted: viewModel.currentTime > 0
                    )
                  }
                  .buttonStyle(.plain)
                  .disabled(line.segments.first == nil)
                  .help("Move playback to this line")
                  .id(line.id)
                }
              }
            }
          }
          .padding(.horizontal, 44)
          .padding(.top, max(92, geometry.size.height * 0.42))
          .padding(.bottom, max(92, geometry.size.height * 0.42))
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .onChange(of: viewModel.currentLineID) { _, lineID in
          guard let lineID else { return }
          withAnimation(reduceMotion ? nil : .smooth(duration: 0.65)) {
            proxy.scrollTo(lineID, anchor: .center)
          }
        }
      }
    }
  }

  private func unavailableState(_ message: String) -> some View {
    VStack(spacing: 14) {
      Image(systemName: "quote.bubble")
        .font(.system(size: 42, weight: .medium))
        .foregroundStyle(.white.opacity(0.7))
      Text("Lyrics Unavailable")
        .font(.title2.bold())
        .foregroundStyle(.white)
      Text(message)
        .foregroundStyle(.white.opacity(0.65))
        .multilineTextAlignment(.center)
        .frame(maxWidth: 440)
      Button("Try Again", systemImage: "arrow.clockwise") {
        Task { await viewModel.load() }
      }
      .buttonStyle(.borderedProminent)
      .tint(.purple)
    }
    .padding(32)
  }
}

private struct LyricLineView: View {
  let line: LyricLine
  let isCurrent: Bool
  let hasPlaybackStarted: Bool
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    Text(line.text)
      .font(.system(size: isCurrent ? 46 : 41, weight: isCurrent ? .bold : .semibold))
      .foregroundStyle(foregroundStyle)
      .lineSpacing(7)
      .fixedSize(horizontal: false, vertical: true)
      .scaleEffect(isCurrent ? 1.015 : 1, anchor: .leading)
      .blur(radius: hasPlaybackStarted && !isCurrent ? 1.6 : 0)
      .animation(reduceMotion ? nil : .smooth(duration: 0.52), value: isCurrent)
      .accessibilityAddTraits(isCurrent ? .isSelected : [])
  }

  private var foregroundStyle: Color {
    if isCurrent { return .white }
    return .white.opacity(hasPlaybackStarted ? 0.38 : 0.68)
  }
}
