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

  var sections: [ConcertHubContainer] {
    hub?.orderedContainers.filter { !$0.data.isEmpty } ?? []
  }

  func load() async {
    guard !isLoading else { return }
    guard MusicAuthorization.currentStatus == .authorized else {
      hub = nil
      errorMessage = "Allow Apple Music access to discover live shows."
      return
    }
    guard let developerToken, !developerToken.isEmpty else {
      hub = nil
      errorMessage = "Add your AMP developer token in Settings to load concerts."
      return
    }

    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      storefront = (try? await MusicDataRequest.currentCountryCode.lowercased()) ?? "in"
      let options = ConcertHubOptions(
        containers: [.popular],
        geoHashLocation: selectedLocation.geoHash,
        limits: [.popular: 12]
      )
      hub = try await MConcerts.hub(
        storefront: storefront,
        developerToken: developerToken,
        options: options
      )
    } catch is CancellationError {
      return
    } catch {
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
