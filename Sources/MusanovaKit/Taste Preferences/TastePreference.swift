//
//  TastePreference.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 10/07/26.
//

import Foundation

/// A taste-preference resource returned for the current Apple Music user.
public struct TastePreference: Codable, Hashable, Identifiable, Sendable {
  /// The resource identifier.
  public let id: String

  /// The server-provided resource type.
  public let type: String

  /// The relative API URL for the resource, when supplied.
  public let href: String?

  /// The preference's display name and value.
  public let attributes: Attributes

  public init(id: String, type: String, href: String? = nil, attributes: Attributes) {
    self.id = id
    self.type = type
    self.href = href
    self.attributes = attributes
  }
}

public extension TastePreference {
  /// Attributes for a taste-preference resource.
  struct Attributes: Codable, Hashable, Sendable {
    /// The display name of the genre or other preference.
    public let name: String

    /// The raw preference level returned by Apple Music.
    public let preference: Int

    public init(name: String, preference: Int) {
      self.name = name
      self.preference = preference
    }
  }
}

/// The response returned by the taste-preferences endpoint.
public struct TastePreferencesResponse: Codable, Hashable, Sendable {
  /// The current user's taste-preference resources.
  public let data: [TastePreference]

  public init(data: [TastePreference]) {
    self.data = data
  }
}
