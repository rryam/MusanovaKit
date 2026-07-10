/// Entry points for Apple Music editorial rooms and multirooms.
public enum MEditorial {
  /// Fetches a room containing a collection of mixed catalog resources.
  public static func room(
    id: String,
    storefront: String,
    developerToken: String
  ) async throws -> EditorialRoom {
    let request = try MusicEditorialRoomRequest(
      id: id,
      storefront: storefront,
      developerToken: developerToken
    )
    return try await request.response()
  }

  /// Fetches a multiroom containing editorial text, catalog content, and room references.
  public static func multiroom(
    id: String,
    storefront: String,
    developerToken: String
  ) async throws -> EditorialMultiroom {
    let request = try MusicEditorialMultiroomRequest(
      id: id,
      storefront: storefront,
      developerToken: developerToken
    )
    return try await request.response()
  }
}
