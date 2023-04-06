//
//  MusicSummaryMilestonesRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 06/04/23.
//

import Foundation

/// A request object used to fetch music summary milestones for a specified year and list of music item types.
struct MusicSummaryMilestonesRequest {

  /// The privileged developer token used to authorize the request.
  private var developerToken: String

  /// The year to fetch music summary milestones for.
  public var year: MusicYearID

  /// The types of music items to include in the music summary milestones.
  public var types: [MusicSummaryMilestonesMusicItemsType]

  /// Initializes a new `MusicSummaryMilestonesRequest`.
  ///
  /// - Parameters:
  ///   - year: The year to fetch music summary milestones for.
  ///   - types: The types of music items to include in the music summary milestones.
  ///   - developerToken: The privileged developer token used to authorize the request.
  public init(year: MusicYearID, types: [MusicSummaryMilestonesMusicItemsType], developerToken: String) {
    self.year = year
    self.types = types
    self.developerToken = developerToken
  }

  /// Sends the request and returns a response object containing the fetched music summary milestones.
  ///
  /// - Returns: A `MusicSummaryMilestonesResponse` object.
  public func response() async throws -> MusicSummaryMilestonesResponse {
    let url = try musicSummariesMilestonesEndpointURL
    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
    let response = try await request.response()
    let milestonesResponse = try JSONDecoder().decode(MusicSummaryMilestonesResponse.self, from: response.data)
    print(milestonesResponse)
    return milestonesResponse
  }
}

extension MusicSummaryMilestonesRequest {
  internal var musicSummariesMilestonesEndpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "me/music-summaries/milestones"

      let types = self.types.map { $0.rawValue }.joined(separator: ",")

      if types.isEmpty {
        components.queryItems = [URLQueryItem(name: "ids", value: "year-\(year.rawValue)")]
      } else {
        components.queryItems = [
          URLQueryItem(name: "ids", value: "year-\(year.rawValue)"),
          URLQueryItem(name: "include[music-summaries-milestones]", value: types)
        ]
      }

      guard let url = components.url else {
        throw URLError(.badURL)
      }
      return url
    }
  }
}
