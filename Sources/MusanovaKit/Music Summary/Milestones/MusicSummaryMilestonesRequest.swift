//
//  MusicSummaryMilestonesRequest.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 06/04/23.
//

import Foundation

public extension MSummaries {
  /// Fetches music summary milestones for a specified year and list of music item types.
  ///
  /// Use this method to fetch music summary milestones for a specific year and types of music items.
  /// The music summary milestones include counts for items such as songs, albums, and playlists that a user has played during a specified year.
  ///
  /// Example usage:
  ///
  ///     do {
  ///       let milestones = try await MSummaries.milestones(forYear: 2023, developerToken: "your_developer_token")
  ///
  ///       for milestone in milestones {
  ///         print("ID: \(milestone.id), Listen Time: \(milestone.listenTimeInMinutes)")
  ///         print("Date Reached: \(milestone.dateReached), Value: \(milestone.value)")
  ///         print("Kind: \(milestone.kind)")
  ///       }
  ///     } catch {
  ///       print(error)
  ///     }
  ///
  /// - Parameters:
  ///   - year: The year to fetch music summary milestones for.
  ///   - musicItemTypes: The types of music items to include in the music summary milestones.
  ///   - developerToken: The developer token used to authorize the request.
  ///
  /// - Returns: An array of `MusicSummaryMilestone` objects containing the fetched music summary milestones.
  ///
  /// - Throws: `MusanovaKitError` if the request fails or the response cannot be decoded.
  static func milestones(forYear year: MusicYearID, musicItemTypes: [MusicSummaryMilestonesMusicItemsType] = [], developerToken: String) async throws -> MusicSummaryMilestones {
    let request = MusicSummaryMilestonesRequest(year: year, types: musicItemTypes, developerToken: developerToken)
    let response = try await request.response()
    return response
  }
}

/// A request object used to fetch music summary milestones for a specified year and list of music item types.
struct MusicSummaryMilestonesRequest {
  /// The privileged developer token used to authorize the request.
  private var developerToken: String

  /// The year to fetch music summary milestones for.
  var year: MusicYearID

  /// The types of music items to include in the music summary milestones.
  var types: [MusicSummaryMilestonesMusicItemsType]

  /// Initializes a new `MusicSummaryMilestonesRequest`.
  ///
  /// - Parameters:
  ///   - year: The year to fetch music summary milestones for.
  ///   - types: The types of music items to include in the music summary milestones.
  ///   - developerToken: The privileged developer token used to authorize the request.
  init(year: MusicYearID, types: [MusicSummaryMilestonesMusicItemsType], developerToken: String) {
    self.year = year
    self.types = types
    self.developerToken = developerToken
  }

  /// Sends the request and returns a response object containing the fetched music summary milestones.
  ///
  /// - Returns: A `MusicSummaryMilestones` object.
  func response() async throws -> MusicSummaryMilestones {
    do {
      let url = try musicSummariesMilestonesEndpointURL
      let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
      let response = try await request.response()
      
      do {
        let milestonesResponse = try JSONDecoder().decode(MusicSummaryMilestonesResponse.self, from: response.data)
        return milestonesResponse.milestones
      } catch let decodingError as DecodingError {
        throw MusanovaKitError.decodingError(decodingError.localizedDescription)
      } catch {
        throw MusanovaKitError.decodingError(error.localizedDescription)
      }
    } catch let error as MusanovaKitError {
      throw error
    } catch let error as URLError {
      throw MusanovaKitError.networkError(error.localizedDescription)
    } catch {
      throw MusanovaKitError.networkError(error.localizedDescription)
    }
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
        throw MusanovaKitError.invalidURL(description: "Failed to construct milestones endpoint URL with path: \(components.path)")
      }
      return url
    }
  }
}
