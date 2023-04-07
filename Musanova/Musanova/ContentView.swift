//
//  ContentView.swift
//  Musanova
//
//  Created by Rudrank Riyam on 04/04/23.
//

import SwiftUI
import MusanovaKit

struct MilestoneView: View {
  let milestone: MusicSummaryMilestone

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(milestone.value)
          .font(.title)
          .bold()

        Text("Listen time: \(milestone.listenTimeInMinutes)")
        Text("Date reached: \(milestone.dateReached.formatDate() ?? "")")
      }

      Spacer()
    }
  }
}

struct MilestoneTopArtistsView: View {
  var topArtists: Artists

  var body: some View {
    MilestoneTopItemsView(header: "Top Artists", data: topArtists) { artist in
      VStack {
        AsyncImage(url: artist.artwork?.url(width: 150, height: 150))
          .cornerRadius(16)
          .frame(width: 150, height: 150)

        Text(artist.name)
          .bold()
      }
      .frame(width: 150)
    }
  }
}

struct MilestoneTopAlbumsView: View {
  var topAlbums: Albums

  var body: some View {
    MilestoneTopItemsView(header: "Top Albums", data: topAlbums) { album in
      VStack {
        AsyncImage(url: album.artwork?.url(width: 150, height: 150))
          .cornerRadius(16)
          .frame(width: 150, height: 150)

        Text(album.title)
          .bold()

        Text(album.artistName)
          .font(.caption)
      }
      .frame(width: 150)
    }
  }
}

struct MilestoneTopSongsView: View {
  var topSongs: Songs

  var body: some View {
    MilestoneTopItemsView(header: "Top Songs", data: topSongs) { song in
      VStack {
        AsyncImage(url: song.artwork?.url(width: 150, height: 150))
          .cornerRadius(16)
          .frame(width: 150, height: 150)

        Text(song.title)
          .bold()

        Text(song.artistName)
          .font(.caption)
      }
      .frame(width: 150)
    }
  }
}

struct ContentView: View {
  @State private var milestones: MusicSummaryMilestones = []

  var body: some View {
    NavigationStack {
      ScrollView {
        ForEach(milestones) { milestone in
          VStack {
            MilestoneView(milestone: milestone)


            MilestoneTopAlbumsView(topAlbums: milestone.topAlbums)

            MilestoneTopArtistsView(topArtists: milestone.topArtists)
          }
          .padding(.bottom)
        }
        .padding()
      }
      .navigationTitle("Milestones for 2023")
    }
    .task {
      if await MusicAuthorization.request() == .authorized {
        do {
          milestones = try await MSummaries.milestones(forYear: 2023, musicItemTypes: [.topArtists, .topSongs, .topAlbums], developerToken: "token")
          print(milestones)
        } catch {
          print(error)
        }
      }
    }
  }
}

struct MilestoneTopItemsView<Item, V: View>: View where Item: Identifiable, Item: MusicItem {
  let header: String
  let data: MusicItemCollection<Item>
  let content: (Item) -> V

  var body: some View {
    ScrollView(.horizontal) {
      Text(header)
        .font(.title2)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)

      LazyHStack {
        ForEach(data) { item in
          content(item)
        }
      }
      .padding(.top)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

extension String {
  func formatDate() -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"

    if let date = inputFormatter.date(from: self) {
      let outputFormatter = DateFormatter()
      outputFormatter.dateFormat = "d MMM yyyy"

      let day = Calendar.current.component(.day, from: date)
      let numberSuffix: String
      switch day {
        case 01, 21, 31: numberSuffix = "st"
        case 02, 22: numberSuffix = "nd"
        case 03, 23: numberSuffix = "rd"
        default: numberSuffix = "th"
      }

      outputFormatter.setLocalizedDateFormatFromTemplate("d'\(numberSuffix)' MMM yyyy")
      return outputFormatter.string(from: date)
    } else {
      return nil
    }
  }
}
