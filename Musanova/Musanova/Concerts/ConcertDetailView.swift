//
//  ConcertDetailView.swift
//  Musanova
//

import MusanovaKit
import SwiftUI

struct ConcertDetailView: View {
  let concert: Concert
  let storefront: String

  @State private var detail: Concert?
  @State private var isLoading = false
  @State private var errorMessage: String?

  private var displayedConcert: Concert { detail ?? concert }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        hero
        venueSection
        ticketSection
      }
      .padding(28)
      .frame(maxWidth: 960, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
    .navigationTitle(displayedConcert.artistNames)
    .task { await loadDetail() }
  }

  private var hero: some View {
    HStack(alignment: .bottom, spacing: 28) {
      ConcertArtworkView(artwork: displayedConcert.displayArtwork, cornerRadius: 22)
        .frame(width: 280, height: 280)
        .shadow(color: .black.opacity(0.2), radius: 24, y: 12)

      VStack(alignment: .leading, spacing: 12) {
        Text("LIVE")
          .font(.caption.bold())
          .tracking(1.6)
          .foregroundStyle(.purple)
        Text(displayedConcert.artistNames)
          .font(.system(.largeTitle, design: .rounded, weight: .bold))
        Text(displayedConcert.attributes.name)
          .font(.title3)
          .foregroundStyle(.secondary)
        Label(displayedConcert.formattedDate, systemImage: "calendar")
          .font(.headline)

        if isLoading {
          ProgressView("Loading event details…")
            .controlSize(.small)
        } else if let errorMessage {
          Text(errorMessage)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.bottom, 8)
    }
  }

  @ViewBuilder
  private var venueSection: some View {
    if let venue = displayedConcert.primaryVenue {
      VStack(alignment: .leading, spacing: 10) {
        Text("Venue")
          .font(.title2.bold())
        Label(venue.attributes.name, systemImage: "mappin.and.ellipse")
          .font(.headline)
        if let address = venue.attributes.structuredAddress?.displayText {
          Text(address)
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  @ViewBuilder
  private var ticketSection: some View {
    let tickets = displayedConcert.attributes.tickets ?? []
    if !tickets.isEmpty {
      VStack(alignment: .leading, spacing: 12) {
        Text("Tickets")
          .font(.title2.bold())
        ForEach(Array(tickets.enumerated()), id: \.offset) { _, ticket in
          Link(destination: ticket.url) {
            Label("View tickets on \(ticket.vendor ?? ticket.provider?.name ?? "ticket provider")", systemImage: "ticket")
              .frame(maxWidth: 360, alignment: .leading)
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
  }

  private func loadDetail() async {
    guard let developerToken = UserDefaults.standard.string(forKey: "developerToken"),
          !developerToken.isEmpty else {
      errorMessage = "Add your AMP developer token in Settings to load full event details."
      return
    }
    isLoading = true
    defer { isLoading = false }
    do {
      detail = try await MConcerts.concert(
        id: concert.id,
        storefront: storefront,
        developerToken: developerToken
      )
    } catch is CancellationError {
      return
    } catch {
      errorMessage = "Full event details are temporarily unavailable."
    }
  }
}

private extension ConcertAddress {
  var displayText: String? {
    let components = [address, city, region, postCode, country]
      .compactMap { $0 }
      .filter { !$0.isEmpty }
    return components.isEmpty ? nil : components.joined(separator: ", ")
  }
}
