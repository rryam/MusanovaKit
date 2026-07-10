//
//  ReplayPlaylistResponseNormalizer.swift
//  MusanovaKit
//

import Foundation

enum ReplayPlaylistResponseNormalizer {
  static func normalize(_ data: Data) throws -> Data {
    let object = try JSONSerialization.jsonObject(with: data)
    let normalizedObject = normalize(object)
    return try JSONSerialization.data(withJSONObject: normalizedObject)
  }

  private static func normalize(_ value: Any) -> Any {
    if let values = value as? [Any] {
      return values.map(normalize)
    }

    guard var dictionary = value as? [String: Any] else {
      return value
    }

    for (key, nestedValue) in dictionary {
      dictionary[key] = normalize(nestedValue)
    }

    if dictionary["type"] as? String == "playlists",
       var attributes = dictionary["attributes"] as? [String: Any],
       attributes["curatorSocialHandle"] == nil {
      attributes["curatorSocialHandle"] = ""
      dictionary["attributes"] = attributes
    }

    return dictionary
  }
}
