//
//  ConcertArtworkView.swift
//  Musanova
//

import MusanovaKit
import SwiftUI

struct ConcertArtworkView: View {
  let artwork: ConcertArtwork?
  var cornerRadius: CGFloat = 18
  var alignment: Alignment = .center
  var verticalOffset: CGFloat = 0

  var body: some View {
    GeometryReader { proxy in
      AsyncImage(url: artwork?.imageURL(width: 1200, height: 1200)) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment)
            .offset(y: verticalOffset)
        case .empty:
          placeholder
            .overlay { ProgressView().controlSize(.small) }
        case .failure:
          placeholder
        @unknown default:
          placeholder
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
      .clipped()
    }
    .clipShape(.rect(cornerRadius: cornerRadius))
    .accessibilityHidden(true)
  }

  private var placeholder: some View {
    LinearGradient(
      colors: [.purple.opacity(0.7), .indigo.opacity(0.9)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .overlay {
      Image(systemName: "music.mic")
        .font(.system(size: 42, weight: .medium))
        .foregroundStyle(.white.opacity(0.8))
    }
  }
}

extension ConcertArtwork {
  func imageURL(width: Int, height: Int) -> URL? {
    let resolved = url
      .replacingOccurrences(of: "{w}", with: String(width))
      .replacingOccurrences(of: "{h}", with: String(height))
      .replacingOccurrences(of: "{c}", with: "bb")
      .replacingOccurrences(of: "{f}", with: "jpg")
    return URL(string: resolved)
  }
}

extension Concert {
  var primaryArtist: ConcertArtist? {
    relationships?.artists?.data.first
  }

  var primaryVenue: ConcertVenue? {
    relationships?.venues?.data.first
  }

  var displayArtwork: ConcertArtwork? {
    primaryArtist?.attributes.artwork
      ?? relationships?.playlists?.data.first?.attributes.artwork
  }

  var artistNames: String {
    let names = relationships?.artists?.data.map(\.attributes.name) ?? []
    return names.isEmpty ? attributes.name : names.joined(separator: ", ")
  }

  var formattedDate: String {
    guard let date = startDate else { return attributes.startISODateTime }
    return date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
  }

  var compactDate: String {
    guard let date = startDate else { return attributes.startISODateTime }
    return date.formatted(.dateTime.month(.abbreviated).day())
  }

  private var startDate: Date? {
    ISO8601DateFormatter().date(from: attributes.startISODateTime)
  }
}
