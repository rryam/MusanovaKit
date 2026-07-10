//
//  PinsViewModel.swift
//  Musanova
//

import Foundation
import MusanovaKit
import Observation

@MainActor
@Observable
final class PinsViewModel {
  private(set) var pins: [PinReference] = []
  private(set) var resources: PinResources?
  private(set) var isLoading = false
  var errorMessage: String?

  func load() async {
    guard !isLoading else { return }
    guard let developerToken = UserDefaults.standard.string(forKey: "developerToken"),
          !developerToken.isEmpty else {
      pins = []
      resources = nil
      errorMessage = "Add your AMP developer token in Settings to load pins."
      return
    }

    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      let response = try await MLibrary.pins(developerToken: developerToken, limit: 50)
      pins = response.data
      resources = response.resources
    } catch is CancellationError {
      return
    } catch {
      pins = []
      resources = nil
      errorMessage = "Your pins could not be loaded. \(error.localizedDescription)"
    }
  }
}
