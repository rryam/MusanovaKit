//
//  MusanovaKitError.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/11/25.
//

import Foundation

/// An enum representing all possible errors that can occur when using the MusanovaKit library.
public enum MusanovaKitError: Error, Sendable {
  /// The API returned an error response.
  case apiError(message: String, code: String? = nil, status: String? = nil)

  /// The response from the API was empty.
  case emptyResponse

  /// The response format is invalid or cannot be parsed.
  case invalidResponseFormat(description: String)

  /// Failed to construct a valid URL.
  case invalidURL(description: String)

  /// A decoding error occurred while parsing the response.
  case decodingError(String)

  /// A network error occurred during the request.
  case networkError(String)

  /// The developer token is missing or invalid.
  case missingDeveloperToken

  /// The country code could not be determined.
  case countryCodeUnavailable
}

extension MusanovaKitError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .apiError(message, code, status):
      var description = "API error: \(message)"
      if let code = code {
        description += " (code: \(code))"
      }
      if let status = status {
        description += " (status: \(status))"
      }
      return description
    case .emptyResponse:
      return "The API returned an empty response."
    case let .invalidResponseFormat(description):
      return "Invalid response format: \(description)"
    case let .invalidURL(description):
      return "Failed to construct URL: \(description)"
    case let .decodingError(description):
      return "Decoding error: \(description)"
    case let .networkError(description):
      return "Network error: \(description)"
    case .missingDeveloperToken:
      return "Developer token is missing or invalid. Please provide a valid developer token."
    case .countryCodeUnavailable:
      return "Unable to determine the current country code."
    }
  }
}

extension MusanovaKitError: LocalizedError {
  public var errorDescription: String? {
    description
  }

  public var failureReason: String? {
    switch self {
    case .apiError:
      return "The Apple Music API returned an error response."
    case .emptyResponse:
      return "The API response contained no data."
    case .invalidResponseFormat:
      return "The response data could not be parsed in the expected format."
    case .invalidURL:
      return "The request URL could not be constructed."
    case .decodingError:
      return "The response data could not be decoded."
    case .networkError:
      return "A network error occurred during the request."
    case .missingDeveloperToken:
      return "Authentication failed due to missing or invalid developer token."
    case .countryCodeUnavailable:
      return "The country code is required but could not be determined."
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .apiError:
      return "Check the error message and code for details. Verify your request parameters and developer token."
    case .emptyResponse:
      return "The requested resource may not exist or may not be available in your region."
    case .invalidResponseFormat:
      return "The API response format may have changed. Please check for library updates."
    case .invalidURL:
      return "Verify that all URL components are valid and properly formatted."
    case .decodingError:
      return "The response structure may have changed. Please check for library updates."
    case .networkError:
      return "Check your internet connection and try again."
    case .missingDeveloperToken:
      return "Provide a valid developer token via the developerToken parameter or DEVELOPER_TOKEN environment variable."
    case .countryCodeUnavailable:
      return "Ensure you have proper network connectivity and MusicKit authorization."
    }
  }
}
