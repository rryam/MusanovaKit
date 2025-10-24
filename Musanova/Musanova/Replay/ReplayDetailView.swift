//
//  ReplayDetailView.swift
//  Musanova
//
//  Created by AI Assistant on 10/24/25.
//

import MusicKit
import SwiftUI

struct ReplayDetailView: View {
  let items: [any MusicItem]
  let title: String
  let type: ContentType

  enum ContentType {
    case songs
    case albums
    case artists
  }

  var body: some View {
    List {
      Section {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
          ReplayListItem(item: item, type: itemType)
        }
      }
    }
    .navigationTitle(title)
  }
}

private extension ReplayDetailView {
  var itemType: ReplayListItem.ItemType {
    switch type {
    case .songs:
      return .song
    case .albums:
      return .album
    case .artists:
      return .artist
    }
  }
}


