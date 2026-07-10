//
//  PinsView.swift
//  Musanova
//

import MusicKit
import MusanovaKit
import SwiftUI

struct PinsView: View {
  @State private var viewModel = PinsViewModel()

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading && viewModel.pins.isEmpty {
          ProgressView("Opening your pinned shelf…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.pins.isEmpty {
          ContentUnavailableView {
            Label("Pins Unavailable", systemImage: "pin.slash")
          } description: {
            Text(errorMessage)
          } actions: {
            Button("Try Again", systemImage: "arrow.clockwise") {
              Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
          }
        } else if viewModel.pins.isEmpty {
          ContentUnavailableView(
            "Nothing Pinned Yet",
            systemImage: "pin",
            description: Text("Albums, songs, artists, and playlists you pin in Apple Music will appear here.")
          )
        } else {
          pinShelf
        }
      }
      .navigationTitle("Pins")
      .toolbar {
        Button("Refresh", systemImage: "arrow.clockwise") {
          Task { await viewModel.load() }
        }
        .disabled(viewModel.isLoading)
      }
    }
    .task { await viewModel.load() }
  }

  private var pinShelf: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Your music, close at hand")
            .font(.title2.bold())
          Text("\(viewModel.pins.count) pinned \(viewModel.pins.count == 1 ? "item" : "items") from your Apple Music library")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 180, maximum: 210), spacing: 24)],
          alignment: .leading,
          spacing: 28
        ) {
          ForEach(viewModel.pins, id: \.id) { pin in
            PinTile(pin: pin, resources: viewModel.resources)
          }
        }
      }
      .padding(28)
      .frame(maxWidth: 1100, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
  }
}

private struct PinTile: View {
  let pin: PinReference
  let resources: PinResources?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Group {
        if let artwork {
          ArtworkImage(artwork, width: 190, height: 190)
        } else {
          LinearGradient(
            colors: [.purple.opacity(0.65), .indigo.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .overlay {
            Image(systemName: iconName)
              .font(.system(size: 38, weight: .medium))
              .foregroundStyle(.white.opacity(0.82))
          }
        }
      }
      .frame(width: 190, height: 190)
      .clipShape(pin.type == "library-artists" ? AnyShape(.circle) : AnyShape(.rect(cornerRadius: 16)))
      .overlay(alignment: .topTrailing) {
        Image(systemName: "pin.fill")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.white)
          .padding(8)
          .background(.purple.gradient, in: .circle)
          .shadow(color: .black.opacity(0.25), radius: 6, y: 2)
          .padding(9)
      }

      Text(title)
        .font(.headline)
        .lineLimit(1)
      Text(subtitle)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .frame(width: 190, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Pinned \(typeLabel): \(title), \(subtitle)")
  }

  private var album: Album? { resources?.libraryAlbums?[pin.id] }
  private var song: Song? { resources?.librarySongs?[pin.id] }
  private var artist: Artist? { resources?.libraryArtists?[pin.id] }
  private var playlist: Playlist? { resources?.libraryPlaylists?[pin.id] }

  private var artwork: Artwork? {
    album?.artwork ?? song?.artwork ?? artist?.artwork ?? playlist?.artwork
  }

  private var title: String {
    album?.title ?? song?.title ?? artist?.name ?? playlist?.name ?? "Pinned Music"
  }

  private var subtitle: String {
    if let album { return album.artistName }
    if let song { return song.artistName }
    if let artist { return artist.genreNames?.first ?? "Artist" }
    if let playlist { return playlist.curatorName ?? "Playlist" }
    return typeLabel
  }

  private var typeLabel: String {
    pin.type
      .replacingOccurrences(of: "library-", with: "")
      .dropLast(pin.type.hasSuffix("s") ? 1 : 0)
      .capitalized
  }

  private var iconName: String {
    switch pin.type {
    case "library-albums": "square.stack"
    case "library-songs": "music.note"
    case "library-artists": "person.fill"
    case "library-playlists": "music.note.list"
    default: "music.note"
    }
  }
}
