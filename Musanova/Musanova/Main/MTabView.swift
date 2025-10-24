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
      CatalogView()
        .tabItem {
          Label("Catalog", systemImage: "music.note.list")
        }

      LibraryView()
        .tabItem {
          Label("Library", systemImage: "music.quarternote.3")
        }

      RecommendationsView()
        .tabItem {
          Label("Recommendations", systemImage: "recordingtape")
        }

      ChartsView()
        .tabItem {
          Label("Charts", systemImage: "chart.bar")
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
