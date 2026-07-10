//
//  TastePreference.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 10/07/26.
//

import Foundation

/// A resource identifier from the taste-preferences response.
public struct TastePreferenceReference: Decodable, Hashable, Identifiable, Sendable {
  /// The resource identifier.
  public let id: String

  /// The server-provided resource type.
  public let type: String

  /// The relative API URL for the resource, when supplied.
  public let href: String?

  /// Expanded attributes when the endpoint returns resources inline.
  public let attributes: TastePreference.Attributes?
}

/// A taste-preference resource returned for the current Apple Music user.
public struct TastePreference: Decodable, Hashable, Identifiable, Sendable {
  /// The resource identifier.
  public let id: String

  /// The server-provided resource type.
  public let type: String

  /// The relative API URL for the resource, when supplied.
  public let href: String?

  /// The preference's display name and value.
  public let attributes: Attributes
}

public extension TastePreference {
  /// Attributes for a taste-preference resource.
  struct Attributes: Decodable, Hashable, Sendable {
    /// The display name of the genre or other preference.
    public let name: String

    /// The raw preference level returned by Apple Music.
    public let preference: Int
  }
}

/// Expanded resources returned alongside taste-preference references.
public struct TastePreferenceResources: Decodable, Hashable, Sendable {
  /// Taste preferences keyed by their resource-map identifier.
  public let tastePreferences: [String: TastePreference]?

  enum CodingKeys: String, CodingKey {
    case tastePreferences = "taste-preferences"
  }
}

/// The response returned by the taste-preferences endpoint.
public struct TastePreferencesResponse: Decodable, Hashable, Sendable {
  /// References that define the current user's preference order.
  public let data: [TastePreferenceReference]

  /// Expanded taste-preference resources.
  public let resources: TastePreferenceResources?

  /// Expanded preferences in the order supplied by `data`.
  public var preferences: [TastePreference] {
    return data.compactMap { reference in
      if let attributes = reference.attributes {
        return TastePreference(
          id: reference.id,
          type: reference.type,
          href: reference.href,
          attributes: attributes
        )
      }

      guard let tastePreferences = resources?.tastePreferences else {
        return nil
      }
      return tastePreferences[reference.id]
        ?? tastePreferences.values.first { $0.id == reference.id }
    }
  }
}
