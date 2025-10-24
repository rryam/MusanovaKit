//
//  PinsView.swift
//  Musanova
//
//  Created by Rudrank Riyam on 25/10/25.
//

import SwiftUI
import MusadoraKit
import MusanovaKit

struct PinsView: View {
    @State private var pinsResponse: MusicLibraryPinsResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var developerToken: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading pins...")
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Failed to load pins")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            loadPins()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if pinsResponse?.data.isEmpty ?? true {
                    VStack(spacing: 16) {
                        Image(systemName: "pin")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No Pinned Items")
                            .font(.headline)
                        Text("Items you pin in Apple Music will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Refresh") {
                            loadPins()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(pinsResponse!.data, id: \.id) { pinRef in
                            PinRow(pinRef: pinRef, resources: pinsResponse!.resources)
                        }
                    }
                    .refreshable {
                        loadPins()
                    }
                }
            }
            .navigationTitle("Pinned Items")
            .toolbar {
                Button(action: loadPins) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            developerToken = UserDefaults.standard.string(forKey: "developerToken") ?? ""
            loadPins()
        }
    }

    private func loadPins() {
        guard !developerToken.isEmpty else {
            errorMessage = "Developer token is required. Please set it in Settings."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await MLibrary.pins(developerToken: developerToken, limit: 50)
                pinsResponse = response
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}

struct PinRow: View {
    let pinRef: PinReference
    let resources: PinResources?

    private var itemName: String {
        if let album = resources?.libraryAlbums?[pinRef.id] {
            return album.title
        } else if let song = resources?.librarySongs?[pinRef.id] {
            return song.title
        } else if let artist = resources?.libraryArtists?[pinRef.id] {
            return artist.name
        }
        return "Unknown Item"
    }

    private var itemType: String {
        pinRef.type.replacingOccurrences(of: "library-", with: "").capitalized
    }

    private var iconName: String {
        switch pinRef.type {
        case "library-albums": return "square.stack"
        case "library-songs": return "music.note"
        case "library-artists": return "person"
        default: return "music.note"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Artwork - Note: Pins API doesn't include artwork data
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: iconName)
                        .foregroundColor(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(itemName)
                    .font(.headline)
                    .lineLimit(1)

                Text(itemType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "pin.fill")
                .foregroundColor(.orange)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PinsView()
}
