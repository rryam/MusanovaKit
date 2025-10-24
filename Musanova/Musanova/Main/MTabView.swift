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
      PinsView()
        .tabItem {
          Label("Pins", systemImage: "pin")
        }

      LyricsView()
        .tabItem {
          Label("Lyrics", systemImage: "music.note")
        }

      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
    .welcomeSheet()
    .tint(.purple)
  }
}
