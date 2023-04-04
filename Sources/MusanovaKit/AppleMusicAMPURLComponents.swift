//
//  AppleMusicAMPURLComponents.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import MusadoraKit
import Foundation

/// A structure that implements the `MURLComponents` protocol, specifically for Apple Music API requests.
struct AppleMusicAMPURLComponents: MURLComponents {

  /// The underlying `URLComponents` instance.
  private var components: URLComponents

  /// Initializes a new `AppleMusicAMPURLComponents` instance with default values for the scheme and host.
  init() {
    self.components = URLComponents()
    components.scheme = "https"
    components.host = "amp-api.music.apple.com"
  }

  /// The query items to include in the URL.
  var queryItems: [URLQueryItem]? {
    get {
      components.queryItems
    } set {
      components.queryItems = newValue
    }
  }

  /// The path for the URL, excluding the base path.
  var path: String {
    get {
      return components.path
    } set {
      components.path = "/v1/" + newValue
    }
  }

  /// The constructed URL, if valid.
  var url: URL? {
    components.url
  }
}
