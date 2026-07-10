//
//  ReplayView.swift
//  Musanova
//

import MusanovaKit
import MusicKit
import SwiftUI

struct ReplayView: View {
  @State private var viewModel = ReplayViewModel()

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading && viewModel.summaries.isEmpty {
          ProgressView("Revisiting your year in music…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = viewModel.errorMessage, viewModel.summaries.isEmpty {
          ContentUnavailableView {
            Label("Replay Unavailable", systemImage: "clock.arrow.circlepath")
          } description: {
            Text(message)
          } actions: {
            Button("Try Again", systemImage: "arrow.clockwise") {
              Task { await viewModel.checkEligibilityAndLoad() }
            }
            .buttonStyle(.borderedProminent)
          }
        } else if let summary = viewModel.selectedSummary {
          replayContent(summary)
        } else {
          ContentUnavailableView(
            "No Replay Yet",
            systemImage: "sparkles",
            description: Text("Your available Apple Music Replay years will appear here.")
          )
        }
      }
      .navigationTitle("Replay")
      .toolbar {
        if !viewModel.availableYears.isEmpty {
          Picker("Replay year", selection: $viewModel.selectedYear) {
            ForEach(viewModel.availableYears, id: \.self) { year in
              Text(String(year)).tag(Optional(year))
            }
          }
          .pickerStyle(.menu)
          .onChange(of: viewModel.selectedYear) { _, _ in
            Task { await viewModel.loadPlaylistSongs() }
          }
        }
      }
    }
    .task(id: MusicAuthorization.currentStatus) {
      await viewModel.checkEligibilityAndLoad()
    }
  }

  private func replayContent(_ summary: MusicSummarySearch) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 40) {
        replayHero(summary)

        if viewModel.isLoadingMilestones {
          ProgressView("Loading \(String(summary.year)) milestones…")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
        } else if viewModel.milestones.isEmpty {
          ContentUnavailableView(
            "No Milestones for \(String(summary.year))",
            systemImage: "flag.checkered",
            description: Text("The Replay playlist is available, but Apple Music returned no milestones.")
          )
          .frame(maxWidth: .infinity)
        } else {
          VStack(alignment: .leading, spacing: 20) {
            Text("Milestones")
              .font(.title2.bold())
            VStack(spacing: 0) {
              ForEach(Array(viewModel.milestones.enumerated()), id: \.element.id) { index, milestone in
                ReplayMilestoneRow(
                  milestone: milestone,
                  drawsLine: index < viewModel.milestones.count - 1
                )
              }
            }
          }
        }
      }
      .padding(28)
      .frame(maxWidth: 980, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
  }

  private func replayHero(_ summary: MusicSummarySearch) -> some View {
    HStack(alignment: .bottom, spacing: 30) {
      Group {
        if let artwork = summary.playlist.artwork {
          ArtworkImage(artwork, width: 270, height: 270)
        } else {
          LinearGradient(
            colors: [.purple, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .overlay {
            Image(systemName: "clock.arrow.circlepath")
              .font(.system(size: 52, weight: .semibold))
              .foregroundStyle(.white.opacity(0.85))
          }
        }
      }
      .frame(width: 270, height: 270)
      .clipShape(.rect(cornerRadius: 22))
      .shadow(color: .black.opacity(0.22), radius: 24, y: 12)

      VStack(alignment: .leading, spacing: 10) {
        Text("APPLE MUSIC REPLAY")
          .font(.caption.bold())
          .tracking(1.4)
          .foregroundStyle(.purple)
        Text(String(summary.year))
          .font(.system(size: 62, weight: .bold, design: .rounded))
        Text(summary.playlist.name)
          .font(.title2.weight(.semibold))
          .foregroundStyle(.secondary)
          .lineLimit(2)
        if let url = summary.playlist.url {
          Link(destination: url) {
            Label("Open Playlist", systemImage: "arrow.up.right.square")
          }
          .buttonStyle(.borderedProminent)
          .padding(.top, 8)
        }
      }
      .padding(.bottom, 8)
    }
  }
}

private struct ReplayMilestoneRow: View {
  let milestone: MusicSummaryMilestone
  let drawsLine: Bool

  var body: some View {
    HStack(alignment: .top, spacing: 18) {
      VStack(spacing: 0) {
        Image(systemName: iconName)
          .font(.headline)
          .foregroundStyle(.white)
          .frame(width: 38, height: 38)
          .background(.purple.gradient, in: .circle)
        if drawsLine {
          Rectangle()
            .fill(.quaternary)
            .frame(width: 2, height: 54)
        }
      }

      VStack(alignment: .leading, spacing: 5) {
        Text(milestone.value)
          .font(.title3.bold())
        Text(label)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        HStack(spacing: 12) {
          Label("\(milestone.listenTimeInMinutes.formatted()) min", systemImage: "headphones")
          Text(milestone.dateReached)
        }
        .font(.caption)
        .foregroundStyle(.tertiary)
      }
      .padding(.top, 2)

      Spacer()
    }
  }

  private var iconName: String {
    switch milestone.kind {
    case .listenTime: "headphones"
    case .artist: "person.wave.2"
    case .song: "music.note"
    }
  }

  private var label: String {
    switch milestone.kind {
    case .listenTime: "Minutes listened"
    case .artist: "Artists discovered"
    case .song: "Songs played"
    }
  }
}
