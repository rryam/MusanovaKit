//
//  ReplayView.swift
//  Musanova
//
//  Created by AI Assistant on 10/24/25.
//

import MusadoraKit
import MusicKit
import SwiftUI

struct ReplayView: View {
  @State private var viewModel = ReplayViewModel()

  var body: some View {
    List {
      if !viewModel.availableYears.isEmpty {
        Section("Select Year") {
          Picker("Year", selection: $viewModel.selectedYear) {
            ForEach(viewModel.availableYears, id: \.self) { year in
              Text("\(year)").tag(Optional(year))
            }
          }
          .onChange(of: viewModel.selectedYear) { _, _ in
            Task {
              await viewModel.loadPlaylistSongs()
            }
          }
        }
      }

      if viewModel.isLoading {
        ProgressView("Loading Replay…")
          .frame(maxWidth: .infinity)
      }

      if let message = viewModel.errorMessage {
        Section {
          Text(message)
            .foregroundStyle(.secondary)
        }
      }

      if viewModel.isEligible && !viewModel.title.isEmpty {
        VStack(alignment: .leading, spacing: 4) {
          Text(viewModel.title)
            .font(.headline)
          if let subtitle = viewModel.subtitle {
            Text(subtitle)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
        .padding(.vertical, 8)

        if !viewModel.topSongs.isEmpty {
          Section("Top Songs (\(viewModel.topSongs.count))") {
            ForEach(viewModel.topSongs.prefix(10)) { song in
              ReplayListItem(item: song, type: .song)
            }
          }
        }

        if !viewModel.topAlbums.isEmpty {
          Section("Top Albums (\(viewModel.topAlbums.count))") {
            ForEach(viewModel.topAlbums.prefix(10)) { album in
              ReplayListItem(item: album, type: .album)
            }
          }
        }

        if !viewModel.topArtists.isEmpty {
          Section("Top Artists (\(viewModel.topArtists.count))") {
            ForEach(viewModel.topArtists.prefix(10)) { artist in
              ReplayListItem(item: artist, type: .artist)
            }
          }
        }
      }
    }
    .navigationTitle("Music Replay")
    .task(id: MusicAuthorization.currentStatus) {
      await viewModel.checkEligibilityAndLoad()
    }
  }
}


