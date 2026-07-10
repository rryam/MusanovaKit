//
//  ConcertHubRequest.swift
//  MusanovaKit
//

import Foundation

struct ConcertHubRequest {
  let storefront: String
  let developerToken: String
  var options: ConcertHubOptions

  init(storefront: String, developerToken: String, options: ConcertHubOptions = ConcertHubOptions()) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.storefront = storefront
    self.developerToken = developerToken
    self.options = options
  }

  var endpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "concerts/\(storefront)/hub"

      var queryItems = [
        URLQueryItem(name: "containers", value: options.containers.map(\.rawValue).joined(separator: ",")),
        URLQueryItem(name: "include[concerts]", value: "venues,artists"),
        URLQueryItem(name: "omit[resource]", value: "autos"),
        URLQueryItem(name: "art[artists:url]", value: "c"),
        URLQueryItem(name: "extend", value: "editorialArtwork,hero")
      ]

      for container in options.containers {
        if let limit = options.limits[container] {
          queryItems.append(URLQueryItem(name: "limit[\(container.rawValue)]", value: String(limit)))
        }
      }
      if let geoHashLocation = options.geoHashLocation, !geoHashLocation.isEmpty {
        queryItems.append(URLQueryItem(name: "geoHashLocation", value: geoHashLocation))
      }
      if let dateRange = options.dateRange {
        queryItems.append(URLQueryItem(
          name: "filter[date]",
          value: "\(dateRange.startDate)..\(dateRange.endDate)"
        ))
      }
      if !options.genreIDs.isEmpty {
        queryItems.append(URLQueryItem(name: "filter[genre]", value: options.genreIDs.joined(separator: ",")))
      }
      components.queryItems = queryItems

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(description: "Failed to construct concerts hub URL.")
      }
      return url
    }
  }

  func response() async throws -> ConcertHub {
    let data = try await concertData(from: endpointURL, developerToken: developerToken)
    return try decode(ConcertHubResponse.self, from: data).results
  }
}

struct ConcertDetailRequest {
  let concertID: String
  let storefront: String
  let developerToken: String

  init(concertID: String, storefront: String, developerToken: String) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.concertID = concertID
    self.storefront = storefront
    self.developerToken = developerToken
  }

  var endpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "catalog/\(storefront)/concerts/\(concertID)"
      components.queryItems = [
        URLQueryItem(name: "include[concerts]", value: "venues,artists,playlists"),
        URLQueryItem(name: "fields[artists]", value: "artwork,name"),
        URLQueryItem(name: "include[artists]", value: "default-playable-content"),
        URLQueryItem(name: "extend[concerts]", value: "tickets,eventDataProviders,ticketDataProvider"),
        URLQueryItem(name: "omit[resource]", value: "autos"),
        URLQueryItem(name: "limit[more-upcoming-concerts]", value: "5"),
        URLQueryItem(name: "views", value: "more-upcoming-concerts")
      ]
      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(description: "Failed to construct concert detail URL.")
      }
      return url
    }
  }

  func response() async throws -> Concert {
    let data = try await concertData(from: endpointURL, developerToken: developerToken)
    let decoded = try decode(ConcertResponse.self, from: data)
    guard let concert = decoded.data.first else {
      throw MusanovaKitError.emptyResponse
    }
    return concert
  }
}

struct ArtistConcertsRequest {
  let artistID: String
  let storefront: String
  let geoHashLocation: String?
  let limit: Int?
  let developerToken: String

  init(
    artistID: String,
    storefront: String,
    geoHashLocation: String? = nil,
    limit: Int? = nil,
    developerToken: String
  ) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.artistID = artistID
    self.storefront = storefront
    self.geoHashLocation = geoHashLocation
    self.limit = limit
    self.developerToken = developerToken
  }

  var endpointURL: URL {
    get throws {
      var components = AppleMusicAMPURLComponents()
      components.path = "catalog/\(storefront)/artists/\(artistID)"

      var views = ["all-upcoming-concerts"]
      var queryItems = [
        URLQueryItem(name: "fields[artists]", value: "artwork,name"),
        URLQueryItem(name: "include[concerts]", value: "venues")
      ]
      if let geoHashLocation, !geoHashLocation.isEmpty {
        views.append("nearby-upcoming-concerts")
        queryItems.append(URLQueryItem(name: "geoHashLocation", value: geoHashLocation))
      }
      if let limit {
        queryItems.append(URLQueryItem(name: "limit[all-upcoming-concerts]", value: String(limit)))
        if geoHashLocation?.isEmpty == false {
          queryItems.append(URLQueryItem(name: "limit[nearby-upcoming-concerts]", value: String(limit)))
        }
      }
      queryItems.append(URLQueryItem(name: "views", value: views.joined(separator: ",")))
      components.queryItems = queryItems

      guard let url = components.url else {
        throw MusanovaKitError.invalidURL(description: "Failed to construct artist concerts URL.")
      }
      return url
    }
  }

  func response() async throws -> ArtistUpcomingConcerts {
    let data = try await concertData(from: endpointURL, developerToken: developerToken)
    let decoded = try decode(ConcertArtistPageResponse.self, from: data)
    guard let artist = decoded.data.first else {
      throw MusanovaKitError.emptyResponse
    }
    return ArtistUpcomingConcerts(
      artistID: artist.id,
      artistName: artist.attributes?.name,
      all: artist.views.allUpcomingConcerts,
      nearby: artist.views.nearbyUpcomingConcerts
    )
  }
}

private struct ConcertResponse: Decodable {
  let data: [Concert]
}

private func concertData(from url: URL, developerToken: String) async throws -> Data {
  do {
    let response = try await MusicPrivilegedDataRequest(
      url: url,
      developerToken: developerToken
    ).response()
    guard !response.data.isEmpty else {
      throw MusanovaKitError.emptyResponse
    }
    return response.data
  } catch let error as MusanovaKitError {
    throw error
  } catch let error as URLError {
    throw MusanovaKitError.networkError(error.localizedDescription)
  } catch {
    throw MusanovaKitError.networkError(error.localizedDescription)
  }
}

private func decode<Value: Decodable>(_ type: Value.Type, from data: Data) throws -> Value {
  do {
    return try JSONDecoder().decode(type, from: data)
  } catch let error as DecodingError {
    throw MusanovaKitError.decodingError(error.localizedDescription)
  } catch {
    throw MusanovaKitError.decodingError(error.localizedDescription)
  }
}
