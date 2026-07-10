//
//  MusicSocialProfileArtwork.swift
//  MusanovaKit
//

/// Artwork associated with an Apple Music social profile.
public struct MusicSocialProfileArtwork: Decodable, Hashable, Sendable {
  public let width: Int?
  public let height: Int?
  public let url: String?
  public let backgroundColor: String?
  public let textColor1: String?
  public let textColor2: String?
  public let textColor3: String?
  public let textColor4: String?

  enum CodingKeys: String, CodingKey {
    case width
    case height
    case url
    case backgroundColor = "bgColor"
    case textColor1
    case textColor2
    case textColor3
    case textColor4
  }
}
