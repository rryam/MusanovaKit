//
//  ConcertHubView.swift
//  Musanova
//

import MusanovaKit
import SwiftUI

struct ConcertHubView: View {
  @State private var viewModel = ConcertHubViewModel()

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading && viewModel.sections.isEmpty {
          ProgressView("Finding live music…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.sections.isEmpty {
          ContentUnavailableView {
            Label("Concerts Unavailable", systemImage: "music.mic")
          } description: {
            Text(errorMessage)
          } actions: {
            Button("Try Again", systemImage: "arrow.clockwise") {
              Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
          }
        } else if viewModel.sections.isEmpty {
          ContentUnavailableView(
            "No Upcoming Concerts",
            systemImage: "calendar.badge.clock",
            description: Text("Apple Music did not return any live shows for this hub.")
          )
        } else {
          concertContent
        }
      }
      .navigationTitle("Concerts")
      .toolbar {
        Picker("Concert location", selection: $viewModel.selectedLocation) {
          ForEach(ConcertHubLocation.all) { location in
            Text(location.name).tag(location)
          }
        }
        .pickerStyle(.menu)
        .onChange(of: viewModel.selectedLocation) { _, _ in
          Task { await viewModel.load() }
        }

        Button("Refresh", systemImage: "arrow.clockwise") {
          Task { await viewModel.load() }
        }
        .disabled(viewModel.isLoading)
      }
      .navigationDestination(for: Concert.self) { concert in
        ConcertDetailView(concert: concert, storefront: viewModel.storefront)
      }
    }
    .task(id: MusicAuthorization.currentStatus) {
      await viewModel.load()
    }
  }

  private var concertContent: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 34) {
        if let featured = viewModel.sections.first?.data.first {
          featuredConcert(featured)
        }

        ForEach(Array(viewModel.sections.enumerated()), id: \.offset) { _, section in
          concertSection(section)
        }
      }
      .padding(.horizontal, 28)
      .padding(.vertical, 24)
      .frame(maxWidth: 1120, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
  }

  private func featuredConcert(_ concert: Concert) -> some View {
    NavigationLink(value: concert) {
      ZStack(alignment: .bottomLeading) {
        ConcertArtworkView(artwork: concert.displayArtwork, cornerRadius: 24, verticalOffset: 44)
          .frame(maxWidth: .infinity)
          .frame(height: 420)
          .overlay {
            LinearGradient(
              colors: [.clear, .black.opacity(0.2), .black.opacity(0.88)],
              startPoint: .top,
              endPoint: .bottom
            )
            .clipShape(.rect(cornerRadius: 24))
          }

        VStack(alignment: .leading, spacing: 8) {
          Text("FEATURED LIVE")
            .font(.caption.weight(.semibold))
            .tracking(1.4)
            .foregroundStyle(.white.opacity(0.72))
          Text(concert.artistNames)
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .lineLimit(2)
          HStack(spacing: 14) {
            Label(concert.formattedDate, systemImage: "calendar")
            if let venue = concert.primaryVenue?.attributes.name {
              Label(venue, systemImage: "mappin.and.ellipse")
                .lineLimit(1)
            }
          }
          .font(.subheadline.weight(.medium))
          .foregroundStyle(.white.opacity(0.82))
        }
        .padding(26)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 420)
      .clipShape(.rect(cornerRadius: 24))
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Featured concert: \(concert.artistNames), \(concert.formattedDate)")
  }

  private func concertSection(_ section: ConcertHubContainer) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("\(section.title ?? "Popular Concerts") in \(viewModel.selectedLocation.name)")
        .font(.title2.bold())

      ScrollView(.horizontal) {
        LazyHStack(spacing: 18) {
          ForEach(section.data, id: \.id) { concert in
            NavigationLink(value: concert) {
              ConcertCard(concert: concert)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.bottom, 8)
      }
    }
  }
}

private struct ConcertCard: View {
  let concert: Concert

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      ConcertArtworkView(artwork: concert.displayArtwork, cornerRadius: 16)
        .frame(width: 210, height: 210)
        .overlay(alignment: .topLeading) {
          Text(concert.compactDate.uppercased())
            .font(.caption2.bold())
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: .capsule)
            .padding(10)
        }

      Text(concert.artistNames)
        .font(.headline)
        .lineLimit(1)
      Text(concert.primaryVenue?.attributes.name ?? concert.attributes.name)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .frame(width: 210, alignment: .leading)
  }
}
