//
//  MusicLyricsResponse.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 26/05/24.
//

import Foundation

public struct MusicLyricsResponse: Decodable {
  let data: [MusicLyrics]
}

public struct MusicLyrics: Decodable {
  let id: String
  let type: String
  let attributes: MusicLyricsAttributes
}

public struct MusicLyricsAttributes: Decodable {
  let ttml: String
}
