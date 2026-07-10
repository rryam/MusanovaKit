//
//  APIExplorerViewModel.swift
//  Musanova
//

import Foundation
import MusanovaKit
import MusicKit
import Observation

@MainActor
@Observable
final class APIExplorerViewModel {
  private(set) var results: [APIExample: APIExampleResult]
  private(set) var isRunningAll = false
  private(set) var hasDeveloperToken = false
  private(set) var isMusicAuthorized = false

  private let storefront = "in"
  private let artistID = "1462541757"
  private let concertID = "ce.4f0d41eb-cedb-4f7b-bc2b-b9d7eab39a9e"
  private let editorialRoomID = "1591131176"
  private let editorialMultiroomID = "1591131185"
  private let songID = MusicItemID("1837754303")

  init() {
    results = Dictionary(
      uniqueKeysWithValues: APIExample.allCases.map { ($0, APIExampleResult()) }
    )
    refreshCredentials()
  }

  func refreshCredentials() {
    hasDeveloperToken = developerToken?.isEmpty == false
    isMusicAuthorized = MusicAuthorization.currentStatus == .authorized
  }

  func result(for example: APIExample) -> APIExampleResult {
    results[example] ?? APIExampleResult()
  }

  func runAll() async {
    guard !isRunningAll else { return }
    isRunningAll = true
    defer { isRunningAll = false }

    for example in APIExample.allCases {
      guard !Task.isCancelled else { return }
      await run(example)
    }
  }

  func run(_ example: APIExample) async {
    refreshCredentials()
    guard result(for: example).phase != .running else { return }
    guard isMusicAuthorized else {
      results[example] = APIExampleResult(
        phase: .failed,
        detail: "Apple Music access is not authorized."
      )
      return
    }
    guard let developerToken, !developerToken.isEmpty else {
      results[example] = APIExampleResult(
        phase: .failed,
        detail: "Add the AMP token in Settings first."
      )
      return
    }

    results[example] = APIExampleResult(phase: .running, detail: "Contacting Apple Music…")

    do {
      results[example] = APIExampleResult(
        phase: .succeeded,
        detail: try await load(example, developerToken: developerToken)
      )
    } catch is CancellationError {
      results[example] = APIExampleResult()
    } catch {
      results[example] = APIExampleResult(
        phase: .failed,
        detail: errorDetail(error)
      )
    }
  }

  private var developerToken: String? {
    UserDefaults.standard.string(forKey: "developerToken")
  }

  private func errorDetail(_ error: any Error) -> String {
    guard let musicError = error as? MusicDataRequest.Error else {
      return error.localizedDescription
    }
    return "HTTP \(musicError.status) · \(musicError.code) \(musicError.title) · \(musicError.detailText)"
  }

  private func load(_ example: APIExample, developerToken: String) async throws -> String {
    if APIExample.personal.contains(example) {
      return try await loadPersonal(example, developerToken: developerToken)
    }
    if APIExample.discovery.contains(example) {
      return try await loadDiscovery(example, developerToken: developerToken)
    }
    return try await loadSocial(example, developerToken: developerToken)
  }

  private func loadPersonal(_ example: APIExample, developerToken: String) async throws -> String {
    switch example {
    case .tastePreferences:
      let preferences = try await MTaste.preferences(developerToken: developerToken)
      let names = preferences.prefix(3).map(\.attributes.name).joined(separator: ", ")
      return names.isEmpty
        ? "200 OK · no expanded preferences"
        : "200 OK · \(preferences.count) preferences · \(names)"

    case .libraryPins:
      let pins = try await MLibrary.pins(developerToken: developerToken, limit: 50)
      let types = Set(pins.data.map(\.type)).sorted().joined(separator: ", ")
      return "200 OK · \(pins.data.count) pins · \(types)"

    case .lyrics:
      let request = try MusicLyricsRequest(songID: songID, developerToken: developerToken)
      let response = try await request.response(countryCode: storefront)
      let characters = response.rawTTML?.count ?? 0
      return "200 OK · \(response.data.count) resource · \(characters) TTML characters"

    case .replay:
      let summaries = Array(try await MSummaries.search(developerToken: developerToken))
      guard let year = summaries.map(\.year).max() else {
        return "200 OK · no Replay years"
      }
      let milestones = try await MSummaries.milestones(
        forYear: MusicYearID(year),
        developerToken: developerToken
      )
      return "200 OK · \(summaries.count) Replay years · \(milestones.count) milestones for \(year)"

    default:
      preconditionFailure("A non-personal example reached the personal loader.")
    }
  }

  private func loadDiscovery(_ example: APIExample, developerToken: String) async throws -> String {
    switch example {
    case .concertHub:
      let options = ConcertHubOptions(
        containers: [.popular],
        geoHashLocation: "dr5r",
        limits: [.popular: 6]
      )
      let hub = try await MConcerts.hub(
        storefront: storefront,
        developerToken: developerToken,
        options: options
      )
      let concertCount = hub.orderedContainers.reduce(0) { $0 + $1.data.count }
      return "200 OK · \(hub.orderedContainers.count) sections · \(concertCount) concerts"

    case .concertDetail:
      let concert = try await MConcerts.concert(
        id: concertID,
        storefront: storefront,
        developerToken: developerToken
      )
      let venues = concert.relationships?.venues?.data.count ?? 0
      let tickets = concert.attributes.tickets?.count ?? 0
      return "200 OK · \(concert.attributes.name) · \(venues) venue · \(tickets) tickets"

    case .artistConcerts:
      let concerts = try await MConcerts.upcomingConcerts(
        forArtistID: artistID,
        storefront: storefront,
        limit: 10,
        developerToken: developerToken
      )
      return "200 OK · \(concerts.artistName ?? artistID) · \(concerts.all.data.count) upcoming"

    case .editorialRoom:
      let room = try await MEditorial.room(
        id: editorialRoomID,
        storefront: storefront,
        developerToken: developerToken
      )
      return "200 OK · \(room.attributes.title ?? room.id) · \(room.contents.count) resources"

    case .editorialMultiroom:
      let multiroom = try await MEditorial.multiroom(
        id: editorialMultiroomID,
        storefront: storefront,
        developerToken: developerToken
      )
      let title = multiroom.attributes.uber?.name ?? multiroom.id
      return "200 OK · \(title) · \(multiroom.children.count) sections"

    default:
      preconditionFailure("A non-discovery example reached the discovery loader.")
    }
  }

  private func loadSocial(_ example: APIExample, developerToken: String) async throws -> String {
    switch example {
    case .socialProfile:
      let profile = try await MSocial.profile(developerToken: developerToken)
      let name = profile.socialProfile?.attributes?.name
        ?? profile.attributes?.name
        ?? profile.id
      return "200 OK · \(name)"

    case .followers:
      let page = try await MSocial.followers(developerToken: developerToken)
      return "Signed request accepted · \(page.profiles.count) followers"

    case .followees:
      let page = try await MSocial.followees(developerToken: developerToken)
      return "Signed request accepted · \(page.profiles.count) followees"

    case .pendingFollowers:
      let page = try await MSocial.pendingFollowers(developerToken: developerToken)
      return "Signed request accepted · \(page.profiles.count) pending"

    default:
      preconditionFailure("A non-social example reached the social loader.")
    }
  }
}
