//
//  ReplayView.swift
//  Musanova
//
//  Created by AI Assistant on 10/24/25.
//

import MusadoraKit
import MusicKit
import SwiftUI

struct ReplayView: View {
  @State private var viewModel = ReplayViewModel()

  var body: some View {
    List {
      if !viewModel.availableYears.isEmpty {
        Section("Select Year") {
          Picker("Year", selection: $viewModel.selectedYear) {
            ForEach(viewModel.availableYears, id: \.self) { year in
              Text("\(year)").tag(Optional(year))
            }
          }
          .onChange(of: viewModel.selectedYear) { _, _ in
            Task {
              await viewModel.loadPlaylistSongs()
            }
          }
        }
      }

      if viewModel.isLoading {
        ProgressView("Loading Replay…")
          .frame(maxWidth: .infinity)
      }

      if let message = viewModel.errorMessage {
        Section {
          Text(message)
            .foregroundStyle(.secondary)
        }
      }

      if viewModel.isEligible && !viewModel.title.isEmpty {
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
              .font(.headline)
            if let subtitle = viewModel.subtitle {
              Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Text("Open in Apple Music to view your personalized replay playlist")
              .font(.caption)
              .foregroundStyle(.secondary)
              .padding(.top, 4)
          }
          .padding(.vertical, 4)
        }
        
        if !viewModel.milestones.isEmpty {
          Section("Your Milestones") {
            ForEach(viewModel.milestones) { milestone in
              VStack(alignment: .leading, spacing: 4) {
                HStack {
                  VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.value)
                      .font(.headline)
                    Text(milestone.kind.rawValue.capitalized)
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                  Spacer()
                  VStack(alignment: .trailing, spacing: 2) {
                    Text("\(milestone.listenTimeInMinutes) min")
                      .font(.caption2)
                      .foregroundStyle(.secondary)
                    Text(milestone.dateReached)
                      .font(.caption2)
                      .foregroundStyle(.secondary)
                  }
                }
              }
              .padding(.vertical, 4)
            }
          }
        }
      }
    }
    .navigationTitle("Music Replay")
    .task(id: MusicAuthorization.currentStatus) {
      await viewModel.checkEligibilityAndLoad()
    }
  }
}


