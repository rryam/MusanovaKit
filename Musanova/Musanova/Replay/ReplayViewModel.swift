//
//  ReplayViewModel.swift
//  Musanova
//
//  Created by AI Assistant on 10/24/25.
//

import Foundation
import MusanovaKit
import MusicKit
import Observation

@MainActor
@Observable
class ReplayViewModel {
  var selectedYear: Int?
  var availableYears: [Int] = []
  var title: String = ""
  var subtitle: String?
  var isEligible: Bool = false
  var isLoading: Bool = false
  var errorMessage: String?
  var summaries: [MusicSummarySearch] = []
  var milestones: [MusicSummaryMilestone] = []
  
  private var developerToken: String? {
    UserDefaults.standard.string(forKey: "developerToken")
  }

  func checkEligibilityAndLoad() async {
    errorMessage = nil
    isEligible = false

    let status = MusicAuthorization.currentStatus
    guard status == .authorized else {
      errorMessage = "Not authorized for Apple Music. Tap Continue on the welcome screen."
      return
    }

    let subscription: MusicSubscription? = try? await MusicSubscription.current
    guard subscription?.canPlayCatalogContent == true else {
      errorMessage = "Requires an active Apple Music subscription to load Replay."
      return
    }

    await loadSummaries()
  }

  func loadSummaries() async {
    guard !isLoading else { return }

    errorMessage = nil
    isLoading = true
    defer { isLoading = false }

    do {
      guard let token = developerToken, !token.isEmpty else {
        errorMessage = "Developer token is required. Please set it in Settings."
        return
      }
      
      let fetchedSummaries = try await MSummaries.search(developerToken: token)
      
      self.summaries = Array(fetchedSummaries)
      self.availableYears = self.summaries.map { $0.year }.sorted(by: >)
      
      if !self.summaries.isEmpty {
        self.selectedYear = self.summaries.first?.year
        await loadPlaylistSongs()
      }
      
      isEligible = true
      
    } catch is CancellationError {
      // Task cancelled
    } catch {
      errorMessage = "Could not load Replay (\(error.localizedDescription))."
      isEligible = false
    }
  }
  
  func loadPlaylistSongs() async {
    guard let year = selectedYear else { return }
    guard let summary = summaries.first(where: { $0.year == year }) else { return }
    guard let token = developerToken, !token.isEmpty else { return }
    
    title = "Year: \(year)"
    subtitle = summary.playlist.name
    
    do {
      let fetchedMilestones = try await MSummaries.milestones(forYear: MusicYearID(year), developerToken: token)
      self.milestones = Array(fetchedMilestones)
    } catch {
      self.milestones = []
    }
  }
}
