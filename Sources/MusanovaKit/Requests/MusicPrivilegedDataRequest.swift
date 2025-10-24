//
//  MusicPrivilegedDataRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation

/// A custom request for loading data from an arbitrary Apple Music private API endpoint.
public struct MusicPrivilegedDataRequest {

  /// The privileged developer token for Apple Music API.
  private let developerToken: String

  /// The URL for the data request.
  private let url: URL

  /// The HTTP method for the request.
  private let method: String

  /// Creates a data request with a URL request.
  public init(url: URL, developerToken: String, method: String = "GET") {
    self.url = url
    self.developerToken = developerToken
    self.method = method
  }

  /// Fetches data from the Apple Music private API endpoint that the URL request defines.
  public func response() async throws -> MusicDataResponse {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method
    urlRequest.setValue("https://music.apple.com", forHTTPHeaderField: "Origin")
    let request = MDataRequest(urlRequest: urlRequest, developerToken: developerToken)
    let response = try await request.response()
    return response
  }
}
