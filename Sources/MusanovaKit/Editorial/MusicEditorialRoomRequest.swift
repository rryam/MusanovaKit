import Foundation

struct MusicEditorialRoomRequest {
  private let id: String
  private let storefront: String
  private let developerToken: String

  init(id: String, storefront: String, developerToken: String) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.id = id
    self.storefront = storefront
    self.developerToken = developerToken
  }

  var endpointURL: URL {
    get throws {
      try editorialEndpointURL(storefront: storefront, resource: "rooms", id: id)
    }
  }

  func response() async throws -> EditorialRoom {
    try await fetchEditorialResource(
      at: endpointURL,
      developerToken: developerToken,
      as: EditorialRoom.self
    )
  }
}

struct MusicEditorialMultiroomRequest {
  private let id: String
  private let storefront: String
  private let developerToken: String

  init(id: String, storefront: String, developerToken: String) throws {
    guard !developerToken.isEmpty else {
      throw MusanovaKitError.missingDeveloperToken
    }
    self.id = id
    self.storefront = storefront
    self.developerToken = developerToken
  }

  var endpointURL: URL {
    get throws {
      try editorialEndpointURL(storefront: storefront, resource: "multirooms", id: id)
    }
  }

  func response() async throws -> EditorialMultiroom {
    try await fetchEditorialResource(
      at: endpointURL,
      developerToken: developerToken,
      as: EditorialMultiroom.self
    )
  }
}

private struct EditorialResourceResponse<Resource: Decodable>: Decodable {
  let data: [Resource]
}

private func editorialEndpointURL(storefront: String, resource: String, id: String) throws -> URL {
  var components = AppleMusicAMPURLComponents()
  components.path = "editorial/\(storefront)/\(resource)/\(id)"

  guard let url = components.url else {
    throw MusanovaKitError.invalidURL(
      description: "Failed to construct the \(resource) endpoint URL."
    )
  }
  return url
}

private func fetchEditorialResource<Resource: Decodable>(
  at url: URL,
  developerToken: String,
  as type: Resource.Type
) async throws -> Resource {
  do {
    let request = MusicPrivilegedDataRequest(url: url, developerToken: developerToken)
    let response = try await request.response()
    guard !response.data.isEmpty else {
      throw MusanovaKitError.emptyResponse
    }

    let decoded = try JSONDecoder().decode(
      EditorialResourceResponse<Resource>.self,
      from: response.data
    )
    guard let resource = decoded.data.first else {
      throw MusanovaKitError.emptyResponse
    }
    return resource
  } catch let error as MusanovaKitError {
    throw error
  } catch let error as DecodingError {
    throw MusanovaKitError.decodingError(error.localizedDescription)
  } catch let error as URLError {
    throw MusanovaKitError.networkError(error.localizedDescription)
  } catch {
    throw MusanovaKitError.networkError(error.localizedDescription)
  }
}
