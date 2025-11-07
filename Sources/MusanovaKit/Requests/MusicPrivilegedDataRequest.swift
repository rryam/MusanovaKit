//
//  MusicPrivilegedDataRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation
import MusadoraKit

/// HTTP methods supported for privileged data requests.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// A custom request for loading data from an arbitrary Apple Music private API endpoint.
public struct MusicPrivilegedDataRequest {
    /// The privileged developer token for Apple Music API.
    private let developerToken: String

    /// The URL for the data request.
    private let url: URL

    /// The HTTP method for the request.
    private let method: HTTPMethod

    /// Creates a data request with a URL request.
    ///
    /// - Parameters:
    ///   - url: The URL for the data request.
    ///   - developerToken: The privileged developer token for Apple Music API. Must not be empty.
    ///   - method: The HTTP method for the request. Defaults to `.get`.
    public init(url: URL, developerToken: String, method: HTTPMethod = .get) {
        self.url = url
        self.developerToken = developerToken
        self.method = method
    }

    /// Fetches data from the Apple Music private API endpoint that the URL request defines.
    public func response() async throws -> MusicDataResponse {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        // Set Origin header
        urlRequest.setValue("https://music.apple.com", forHTTPHeaderField: "Origin")

        // Set Host header - important for Apple Music API
        if let host = url.host {
            urlRequest.setValue(host, forHTTPHeaderField: "Host")
        }

        let request = MusicDeveloperRequest(urlRequest: urlRequest, developerToken: developerToken)

        let response = try await request.response()
        return response
    }
}
