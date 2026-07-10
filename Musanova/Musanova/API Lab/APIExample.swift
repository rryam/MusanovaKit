//
//  APIExample.swift
//  Musanova
//

import Foundation

enum APIExample: String, CaseIterable, Identifiable, Sendable {
  case tastePreferences
  case libraryPins
  case lyrics
  case replay
  case concertHub
  case concertDetail
  case artistConcerts
  case editorialRoom
  case editorialMultiroom
  case socialProfile
  case followers
  case followees
  case pendingFollowers

  var id: Self { self }

  var title: String {
    switch self {
    case .tastePreferences: "Taste Preferences"
    case .libraryPins: "Library Pins"
    case .lyrics: "Syllable Lyrics"
    case .replay: "Replay and Milestones"
    case .concertHub: "Concert Hub"
    case .concertDetail: "Concert Detail"
    case .artistConcerts: "Artist Concerts"
    case .editorialRoom: "Editorial Room"
    case .editorialMultiroom: "Editorial Multiroom"
    case .socialProfile: "Social Profile"
    case .followers: "Followers"
    case .followees: "Followees"
    case .pendingFollowers: "Pending Followers"
    }
  }

  var subtitle: String {
    switch self {
    case .tastePreferences: "Personalization signals"
    case .libraryPins: "Pinned library resources"
    case .lyrics: "Raw TTML and timed lines"
    case .replay: "Available years and listening milestones"
    case .concertHub: "Live concert sections"
    case .concertDetail: "Dates, venues, artists, and tickets"
    case .artistConcerts: "Upcoming concerts for one artist"
    case .editorialRoom: "Mixed catalog content"
    case .editorialMultiroom: "Editorial page sections"
    case .socialProfile: "The signed-in profile"
    case .followers: "Signed relationship read"
    case .followees: "Signed relationship read"
    case .pendingFollowers: "Signed relationship read"
    }
  }

  var systemImage: String {
    switch self {
    case .tastePreferences: "slider.horizontal.3"
    case .libraryPins: "pin.fill"
    case .lyrics: "quote.bubble.fill"
    case .replay: "clock.arrow.circlepath"
    case .concertHub, .concertDetail, .artistConcerts: "music.mic"
    case .editorialRoom, .editorialMultiroom: "rectangle.3.group.fill"
    case .socialProfile: "person.crop.circle"
    case .followers, .followees, .pendingFollowers: "person.2.fill"
    }
  }

  static let personal: [APIExample] = [
    .tastePreferences,
    .libraryPins,
    .lyrics,
    .replay
  ]

  static let discovery: [APIExample] = [
    .concertHub,
    .concertDetail,
    .artistConcerts,
    .editorialRoom,
    .editorialMultiroom
  ]

  static let social: [APIExample] = [
    .socialProfile,
    .followers,
    .followees,
    .pendingFollowers
  ]
}
