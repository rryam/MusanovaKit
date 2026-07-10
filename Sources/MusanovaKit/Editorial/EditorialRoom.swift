import Foundation

/// A lightweight representation of artwork returned by editorial endpoints.
public struct EditorialArtwork: Codable, Sendable, Equatable {
  public let url: String
  public let width: Int?
  public let height: Int?
  public let backgroundColor: String?
  public let textColor1: String?
  public let textColor2: String?
  public let textColor3: String?
  public let textColor4: String?
  public let hasP3: Bool?

  private enum CodingKeys: String, CodingKey {
    case url, width, height, hasP3
    case backgroundColor = "bgColor"
    case textColor1, textColor2, textColor3, textColor4
  }
}

/// A catalog resource embedded in an editorial room.
///
/// Editorial endpoints may mix artists, albums, playlists, songs, and other
/// resource types. This model preserves their identity and common display
/// attributes while ignoring type-specific fields that can change over time.
public struct EditorialContentResource: Codable, Sendable, Equatable, Identifiable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: Attributes?

  public struct Attributes: Codable, Sendable, Equatable {
    public let name: String?
    public let title: String?
    public let artistName: String?
    public let url: String?
    public let artwork: EditorialArtwork?
    public let genreNames: [String]?
    public let description: String?
  }
}

/// A reference to another editorial room.
public struct EditorialRoomReference: Codable, Sendable, Equatable, Identifiable {
  public let id: String
  public let type: String
  public let href: String?
}

/// A text or content section embedded in an editorial multiroom.
public struct EditorialElement: Codable, Sendable, Equatable, Identifiable {
  public let id: String
  public let type: String
  public let attributes: Attributes?
  public let relationships: Relationships?

  public struct Attributes: Codable, Sendable, Equatable {
    public let title: String?
    public let description: String?
    public let displayStyle: String?
    public let lockupStyle: String?
    public let editorialElementKind: String?
    public let lastModifiedDate: String?
  }

  public struct Relationships: Codable, Sendable, Equatable {
    public let contents: EditorialContentRelationship?
    public let room: EditorialRoomRelationship?
  }
}

/// A relationship containing mixed catalog resources.
public struct EditorialContentRelationship: Codable, Sendable, Equatable {
  public let href: String?
  public let next: String?
  public let data: [EditorialContentResource]
}

/// A relationship containing editorial room references.
public struct EditorialRoomRelationship: Codable, Sendable, Equatable {
  public let href: String?
  public let data: [EditorialRoomReference]
}

/// A single editorial room and its content.
public struct EditorialRoom: Codable, Sendable, Equatable, Identifiable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: Attributes
  public let relationships: Relationships?

  public struct Attributes: Codable, Sendable, Equatable {
    public let title: String?
    public let defaultSort: String?
    public let sorts: [String]?
    public let resourceTypes: [String]?
    public let editorialElementKind: String?
    public let lastModifiedDate: String?
    public let doNotFilter: Bool?
  }

  public struct Relationships: Codable, Sendable, Equatable {
    public let contents: EditorialContentRelationship?
  }

  /// Catalog resources embedded directly in the room.
  public var contents: [EditorialContentResource] {
    relationships?.contents?.data ?? []
  }
}

/// Hero presentation metadata for an editorial multiroom.
public struct EditorialUber: Codable, Sendable, Equatable {
  public let name: String?
  public let description: String?
  public let backgroundColor: String?
  public let headerTextColor: String?
  public let primaryTextColor: String?
  public let titleTextColor: String?
  public let heroArtwork: EditorialArtwork?

  private enum CodingKeys: String, CodingKey {
    case name, description, backgroundColor, headerTextColor, primaryTextColor, titleTextColor
    case heroArtwork = "masterArt"
  }
}

/// A multi-section editorial page.
public struct EditorialMultiroom: Codable, Sendable, Equatable, Identifiable {
  public let id: String
  public let type: String
  public let href: String?
  public let attributes: Attributes
  public let relationships: Relationships?

  public struct Attributes: Codable, Sendable, Equatable {
    public let lastModifiedDate: String?
    public let uber: EditorialUber?
  }

  public struct Relationships: Codable, Sendable, Equatable {
    public let children: EditorialChildrenRelationship?
  }

  /// Editorial sections embedded in the page.
  public var children: [EditorialElement] {
    relationships?.children?.data ?? []
  }
}

/// A relationship containing the sections of a multiroom.
public struct EditorialChildrenRelationship: Codable, Sendable, Equatable {
  public let href: String?
  public let next: String?
  public let data: [EditorialElement]
}
