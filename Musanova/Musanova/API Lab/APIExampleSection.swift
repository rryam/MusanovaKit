//
//  APIExampleSection.swift
//  Musanova
//

import SwiftUI

struct APIExampleSection: View {
  let title: String
  let examples: [APIExample]
  let viewModel: APIExplorerViewModel

  var body: some View {
    Section(title) {
      ForEach(examples) { example in
        APIExampleRow(
          example: example,
          result: viewModel.result(for: example),
          run: { run(example) }
        )
      }
    }
  }

  private func run(_ example: APIExample) {
    Task {
      await viewModel.run(example)
    }
  }
}
