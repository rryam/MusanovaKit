//
//  ConcertHubViewModel.swift
//  Musanova
//

import Foundation
import MusanovaKit
import MusicKit
import Observation

@MainActor
@Observable
final class ConcertHubViewModel {
  private(set) var hub: ConcertHub?
  private(set) var isLoading = false
  private(set) var storefront = "in"
  var selectedLocation = ConcertHubLocation.newYork
  var errorMessage: String?

  private var activeRequestID = UUID()

  var sections: [ConcertHubContainer] {
    hub?.orderedContainers.filter { !$0.data.isEmpty } ?? []
  }

  func load() async {
    let requestID = UUID()
    activeRequestID = requestID
    guard MusicAuthorization.currentStatus == .authorized else {
      isLoading = false
      hub = nil
      errorMessage = "Allow Apple Music access to discover live shows."
      return
    }
    guard let developerToken, !developerToken.isEmpty else {
      isLoading = false
      hub = nil
      errorMessage = "Add your AMP developer token in Settings to load concerts."
      return
    }

    hub = nil
    isLoading = true
    errorMessage = nil
    defer {
      if activeRequestID == requestID {
        isLoading = false
      }
    }

    do {
      storefront = (try? await MusicDataRequest.currentCountryCode.lowercased()) ?? "in"
      let requestedLocation = selectedLocation
      let options = ConcertHubOptions(
        containers: [.popular],
        geoHashLocation: requestedLocation.geoHash,
        limits: [.popular: 12]
      )
      let fetchedHub = try await MConcerts.hub(
        storefront: storefront,
        developerToken: developerToken,
        options: options
      )
      guard activeRequestID == requestID else { return }
      hub = fetchedHub
    } catch is CancellationError {
      return
    } catch {
      guard activeRequestID == requestID else { return }
      hub = nil
      errorMessage = "Concerts could not be loaded. \(error.localizedDescription)"
    }
  }

  private var developerToken: String? {
    UserDefaults.standard.string(forKey: "developerToken")
  }
}

struct ConcertHubLocation: Identifiable, Hashable {
  let name: String
  let geoHash: String

  var id: String { geoHash }

  static let newYork = ConcertHubLocation(name: "New York", geoHash: "dr5r")
  static let london = ConcertHubLocation(name: "London", geoHash: "gcpv")
  static let mumbai = ConcertHubLocation(name: "Mumbai", geoHash: "te7u")
  static let delhi = ConcertHubLocation(name: "Delhi", geoHash: "ttnf")
  static let bengaluru = ConcertHubLocation(name: "Bengaluru", geoHash: "tdr1")

  static let all: [ConcertHubLocation] = [newYork, london, mumbai, delhi, bengaluru]
}
