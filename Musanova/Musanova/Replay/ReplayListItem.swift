//
//  ReplayListItem.swift
//  Musanova
//
//  Created by AI Assistant on 10/24/25.
//

import MusicKit
import SwiftUI

struct ReplayListItem: View {
  let item: any MusicItem
  let type: ItemType

  enum ItemType {
    case song
    case album
    case artist
  }

  var body: some View {
    HStack {
      artwork
      
      VStack(alignment: .leading, spacing: 2) {
        title
        subtitle
      }
      
      Spacer()
      
      if let icon = ItemIcon.icon(for: type) {
        Image(systemName: icon)
          .foregroundColor(.secondary)
          .font(.caption)
      }
    }
    .contentShape(Rectangle())
  }
}

private extension ReplayListItem {
  var artwork: some View {
    Group {
      switch type {
      case .song:
        if let song = item as? Song {
        if let artwork = song.artwork {
          ArtworkImage(artwork, width: 40, height: 40)
            .cornerRadius(6)
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 40, height: 40)
            .cornerRadius(6)
        }
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 40, height: 40)
            .cornerRadius(6)
        }
      case .album:
        if let album = item as? Album {
        if let artwork = album.artwork {
          ArtworkImage(artwork, width: 40, height: 40)
            .cornerRadius(6)
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 40, height: 40)
            .cornerRadius(6)
        }
        } else {
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 40, height: 40)
            .cornerRadius(6)
        }
      case .artist:
        Circle()
          .fill(Color.purple.opacity(0.1))
          .frame(width: 40, height: 40)
          .overlay(
            Image(systemName: "person.fill")
              .font(.system(size: 16))
              .foregroundColor(.purple)
          )
      }
    }
  }

  @ViewBuilder
  var title: some View {
    switch type {
    case .song:
      if let song = item as? Song {
        Text(song.title)
          .font(.body)
          .lineLimit(1)
      }
    case .album:
      if let album = item as? Album {
        Text(album.title)
          .font(.body)
          .lineLimit(1)
      }
    case .artist:
      if let artist = item as? Artist {
        Text(artist.name)
          .font(.body)
          .lineLimit(1)
      }
    }
  }

  @ViewBuilder
  var subtitle: some View {
    switch type {
    case .song:
      if let song = item as? Song {
        Text(song.artistName)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    case .album:
      if let album = item as? Album {
        Text(album.artistName)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    case .artist:
      if let artist = item as? Artist {
        Text(artist.name)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }
}

private enum ItemIcon {
  static func icon(for type: ReplayListItem.ItemType) -> String? {
    switch type {
    case .song:
      return "music.note"
    case .album:
      return "square.stack"
    case .artist:
      return "person.fill"
    }
  }
}


