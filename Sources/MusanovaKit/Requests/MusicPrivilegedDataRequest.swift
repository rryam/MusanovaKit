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
public struct MusicPrivilegedDataRequest: Sendable {
    /// The privileged developer token for Apple Music API.
    private let developerToken: String

    /// The URL for the data request.
    private let url: URL

    /// The HTTP method for the request.
    private let method: HTTPMethod

    /// Headers to add after the standard Apple Music headers.
    private let headers: [String: String]

    /// The optional HTTP request body.
    private let body: Data?

    /// Creates a data request with a URL request.
    ///
    /// - Parameters:
    ///   - url: The URL for the data request.
    ///   - developerToken: The privileged developer token for Apple Music API. Must not be empty.
    ///   - method: The HTTP method for the request. Defaults to `.get`.
    ///   - headers: Additional HTTP headers for the request.
    ///   - body: An optional HTTP body, such as encoded JSON.
    public init(
        url: URL,
        developerToken: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.url = url
        self.developerToken = developerToken
        self.method = method
        self.headers = headers
        self.body = body
    }

    /// Fetches data from the Apple Music private API endpoint that the URL request defines.
    public func response() async throws -> MusicDataResponse {
        let urlRequest = makeURLRequest()
        let request = MusicDeveloperRequest(urlRequest: urlRequest, developerToken: developerToken)

        return try await request.response()
    }

    func makeURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body

        urlRequest.setValue("https://music.apple.com", forHTTPHeaderField: "Origin")

        if let host = url.host {
            urlRequest.setValue(host, forHTTPHeaderField: "Host")
        }

        for (name, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }

        return urlRequest
    }
}
