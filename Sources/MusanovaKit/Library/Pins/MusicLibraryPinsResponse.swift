//
//  MusicLibraryPinsResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation

/// The response containing pinned items from the user's Apple Music library.
///
/// This response contains a map of pinned music items, organized by their types
/// and identifiers. The response format is designed to efficiently represent
/// pinned content with all necessary relationships and metadata.
///
/// Example usage:
///
///     let response = try await request.response()
///     for (key, pin) in response.pins {
///         print("Pinned: \(pin.attributes.name ?? "Unknown")")
///     }
///
public struct MusicLibraryPinsResponse: Decodable {

  /// A dictionary mapping pin identifiers to their corresponding LibraryPin objects.
  ///
  /// The keys are typically in the format "type-id" (e.g., "song-12345"),
  /// and the values contain the full pin data including attributes and relationships.
  public let pins: [String: LibraryPin]

  /// Coding keys for decoding the response.
  enum CodingKeys: String, CodingKey {
    case pins = "data"
  }

  /// Initializes a new pins response from a decoder.
  ///
  /// This custom initializer handles the map-based response format
  /// where pins are returned as a dictionary rather than an array.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // The API returns pins in a map format
    let pinsDictionary = try container.decode([String: LibraryPin].self, forKey: .pins)
    self.pins = pinsDictionary
  }
}

/// A collection of library pins.
///
/// This type alias provides a convenient way to work with collections of pinned items.
/// It uses MusicKit's MusicItemCollection for consistency with other collection types.
///
/// Example usage:
///
///     let pins: LibraryPins = ...
///     for pin in pins {
///         print("Pin: \(pin.attributes.name ?? "Unknown")")
///     }
///
public typealias LibraryPins = [LibraryPin]
