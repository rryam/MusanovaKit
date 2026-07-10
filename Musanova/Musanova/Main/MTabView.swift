//
//  MTabView.swift
//  Musanova
//
//  Created by Rudrank Riyam on 09/03/23.
//

import SwiftUI

struct MTabView: View {
  var body: some View {
    TabView {
      Tab("Concerts", systemImage: "music.mic") {
        ConcertHubView()
      }

      Tab("Replay", systemImage: "clock.arrow.circlepath") {
        ReplayView()
      }

      Tab("Lyrics", systemImage: "music.note") {
        LyricsView()
      }

      Tab("Pins", systemImage: "pin") {
        PinsView()
      }

      Tab("Settings", systemImage: "gear") {
        SettingsView()
      }
    }
    .welcomeSheet()
    .tint(.purple)
  }
}
