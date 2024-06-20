# MusanovaKit

Explore and experiment with private Apple Music API endpoints. 

Note: Do NOT ship with this package. If you do, you are responsible for any backlash from Apple. This uses private Apple Music API endpoints that requires a privileged developer token.

# Lyrics

The `lyrics(for:developerToken:)` method allows you to fetch lyrics for a specific song. This feature requires a privileged developer token.

**Important:** This feature is experimental and should not be used in production environments.

Here's an example of how to use it:

```swift
do {
    let id = MusicItemID("1156786545")
    let song = try await MCatalog.song(id: id)
    let lyrics = try await MCatalog.lyrics(for: song, developerToken: MusanovaKit.priviledgedDeveloperToken!)
    
    print("Lyrics for \(song.title):")
    for paragraph in lyrics {
        if let songPart = paragraph.songPart {
            print("\n\(songPart.uppercased()):")
        }
        for line in paragraph.lines {
            print(line.text)
        }
    }
} catch {
    print("Error fetching lyrics: \(error)")
}
```

To use this feature:
1. Obtain a privileged developer token from the Apple Music website.
2. Set the token as an environment variable named "DEVELOPER_TOKEN".

**Warning:** Usage of this feature may be subject to Apple's terms and conditions. I assume no liability for any issues arising from its use.

# Replay and Summaries

## Milestones

The `milestones(forYear:musicItemTypes:developerToken:)` method is used to retrieve milestones data for a given year.

Here is an example of how to use it:

```swift
do {
  let milestones = try await MSummaries.milestones(forYear: 2023, developerToken: "your_developer_token")
  
  for milestone in milestones {
    print("ID: \(milestone.id), Listen Time: \(milestone.listenTimeInMinutes)")
    print("Date Reached: \(milestone.dateReached), Value: \(milestone.value)")
    print("Kind: \(milestone.kind)")
    print("Top Songs: \(milestone.topSongs)")
    print("Top Artists: \(milestone.topArtists)")
    print("Top Albums: \(milestone.topAlbums)")
  }
} catch {
  print(error)
}
```

## Search Replay Playlists

The `search(developerToken:)` method allows you to search music summary data for the user's library like the replay playlists over the years. To use this method, you will need a privileged developer token.

Here's an example of how to use it:

```swift
do {
  let summaries = try await MSummaries.search(developerToken: "developer_token")
    
  for summary in summaries {
    print("Year: \(summary.year), playlist: \(summary.playlist)")
  }
} catch {
  print(error)
}
```
