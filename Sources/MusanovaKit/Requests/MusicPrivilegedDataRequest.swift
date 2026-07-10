//
//  MusicPrivilegedDataRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation
import MusadoraKit
import MusanovaKitPrivateSupport

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

    /// Whether Apple Music's Mescal action signature is required.
    private let requiresActionSignature: Bool

    /// Creates a data request with a URL request.
    ///
    /// - Parameters:
    ///   - url: The URL for the data request.
    ///   - developerToken: The privileged developer token for Apple Music API. Must not be empty.
    ///   - method: The HTTP method for the request. Defaults to `.get`.
    ///   - headers: Additional HTTP headers for the request.
    ///   - body: An optional HTTP body, such as encoded JSON.
    ///   - requiresActionSignature: Whether to add Apple's action signature before sending.
    public init(
        url: URL,
        developerToken: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil,
        requiresActionSignature: Bool = false
    ) {
        self.url = url
        self.developerToken = developerToken
        self.method = method
        self.headers = headers
        self.body = body
        self.requiresActionSignature = requiresActionSignature
    }

    /// Fetches data from the Apple Music private API endpoint that the URL request defines.
    public func response() async throws -> MusicDataResponse {
        var urlRequest = makeURLRequest()
        if requiresActionSignature {
            urlRequest = try signedActionRequest(urlRequest)
        }
        let request = MusicDeveloperRequest(urlRequest: urlRequest, developerToken: developerToken)

        return try await request.response()
    }

    private func signedActionRequest(_ request: URLRequest) throws -> URLRequest {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            throw MusanovaKitError.requestSigningFailed("The URL request could not be copied for signing.")
        }
        var signingError: NSError?
        guard MNKAddAppleMusicActionSignature(mutableRequest, &signingError) else {
            throw MusanovaKitError.requestSigningFailed(
                signingError?.localizedDescription ?? "Apple Music did not produce an action signature."
            )
        }
        return mutableRequest as URLRequest
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
