//
//  AppleMusicAMPURLComponents.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import MusadoraKit
import Foundation

/// A structure that implements the `MURLComponents` protocol, specifically for Apple Music API requests.
public struct AppleMusicAMPURLComponents: MURLComponents {

  /// The underlying `URLComponents` instance.
  private var components: URLComponents

  /// Initializes a new `AppleMusicAMPURLComponents` instance with default values for the scheme and host.
  public init() {
    self.components = URLComponents()
    components.scheme = "https"
    components.host = "amp-api.music.apple.com"
  }

  /// The query items to include in the URL.
  public var queryItems: [URLQueryItem]? {
    get {
      components.queryItems
    } set {
      components.queryItems = newValue
    }
  }

  /// The path for the URL, excluding the base path.
  public var path: String {
    get {
      return components.path
    } set {
      components.path = "/v1/" + newValue
    }
  }

  /// The constructed URL, if valid.
  public var url: URL? {
    components.url
  }
}
