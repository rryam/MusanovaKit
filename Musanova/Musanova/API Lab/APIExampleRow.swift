//
//  APIExampleRow.swift
//  Musanova
//

import SwiftUI

struct APIExampleRow: View {
  let example: APIExample
  let result: APIExampleResult
  let run: () -> Void

  var body: some View {
    HStack(alignment: .top) {
      Label {
        VStack(alignment: .leading) {
          Text(example.title)
            .font(.headline)
          Text(example.subtitle)
            .foregroundStyle(.secondary)
          Text(result.detail)
            .font(.subheadline)
            .foregroundStyle(result.phase == .failed ? Color.red : Color.secondary)
            .textSelection(.enabled)
        }
      } icon: {
        Image(systemName: example.systemImage)
          .foregroundStyle(.purple)
          .accessibilityHidden(true)
      }

      Spacer()

      phaseIndicator

      Button("Run", systemImage: "play.fill", action: run)
        .labelStyle(.iconOnly)
        .disabled(result.phase == .running)
        .accessibilityLabel("Run \(example.title)")
    }
    .padding(.vertical, 4)
  }

  @ViewBuilder private var phaseIndicator: some View {
    switch result.phase {
    case .idle:
      Image(systemName: "circle")
        .foregroundStyle(.secondary)
        .accessibilityLabel("Not run")
    case .running:
      ProgressView()
        .controlSize(.small)
        .accessibilityLabel("Running")
    case .succeeded:
      Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(.green)
        .accessibilityLabel("Succeeded")
    case .failed:
      Image(systemName: "xmark.octagon.fill")
        .foregroundStyle(.red)
        .accessibilityLabel("Failed")
    }
  }
}
