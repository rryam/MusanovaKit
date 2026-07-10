//
//  APIExplorerView.swift
//  Musanova
//

import SwiftUI

struct APIExplorerView: View {
  @State private var viewModel = APIExplorerViewModel()

  var body: some View {
    NavigationStack {
      List {
        Section {
          LabeledContent("Apple Music", value: viewModel.isMusicAuthorized ? "Authorized" : "Not authorized")
          LabeledContent("AMP token", value: viewModel.hasDeveloperToken ? "Ready" : "Missing")
          Button("Run All Read APIs", systemImage: "play.fill", action: runAll)
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isRunningAll)
        } footer: {
          Text("Runs safe reads only. Pin, unpin, reorder, and playback mutations stay manual.")
        }

        APIExampleSection(
          title: "Personal",
          examples: APIExample.personal,
          viewModel: viewModel
        )

        APIExampleSection(
          title: "Discovery",
          examples: APIExample.discovery,
          viewModel: viewModel
        )

        APIExampleSection(
          title: "Social",
          examples: APIExample.social,
          viewModel: viewModel
        )
      }
      .navigationTitle("API Lab")
      .toolbar {
        Button("Run All", systemImage: "play.fill", action: runAll)
          .disabled(viewModel.isRunningAll)
      }
    }
    .onAppear(perform: viewModel.refreshCredentials)
  }

  private func runAll() {
    Task {
      await viewModel.runAll()
    }
  }
}
