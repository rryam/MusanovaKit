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
  var errorMessage: String?

  var sections: [ConcertHubContainer] {
    hub?.orderedContainers.filter { !$0.data.isEmpty } ?? []
  }

  func load() async {
    guard !isLoading else { return }
    guard MusicAuthorization.currentStatus == .authorized else {
      errorMessage = "Allow Apple Music access to discover live shows."
      return
    }
    guard let developerToken, !developerToken.isEmpty else {
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
        geoHashLocation: "dr5r",
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
      errorMessage = "Concerts could not be loaded. \(error.localizedDescription)"
    }
  }

  private var developerToken: String? {
    UserDefaults.standard.string(forKey: "developerToken")
  }
}
