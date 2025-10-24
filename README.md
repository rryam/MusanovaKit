# MusanovaKit

MusanovaKit lets you explore Apple Music features that are not exposed through the public MusicKit framework. It includes helpers for private APIs such as privileged lyric endpoints and Music Summaries (Replay) data. **Use this package for research and internal tooling only.**

> ⚠️ MusanovaKit calls Apple Music endpoints that require a **privileged developer token**. Shipping these APIs inside production software is likely to violate Apple’s terms and may break without notice. Proceed at your own risk.

## Table of Contents

- [Exploring MusicKit and Apple Music API Book](#exploring-musickit-and-apple-music-api-book)
- [Requirements](#requirements)
- [Installation](#installation)
- [Authentication](#authentication)
  - [Privileged developer token](#privileged-developer-token)
  - [Music user token](#music-user-token)
- [Lyrics](#lyrics)
  - [Fetching TTML lyrics](#fetching-ttml-lyrics)
  - [Working with timed segments](#working-with-timed-segments)
- [Replay and Summaries](#replay-and-summaries)
  - [Milestones](#milestones)
  - [Searching replay playlists](#searching-replay-playlists)
- [Library Pins](#library-pins)
  - [Fetching pinned items](#fetching-pinned-items)
  - [Custom pin requests](#custom-pin-requests)
- [Disclaimer](#disclaimer)

## Exploring MusicKit and Apple Music API Book

<p align="center">
  <a href="https://academy.rudrank.com/product/musickit" target="_blank">
    <img src="https://img.shields.io/badge/Book-Exploring%20MusicKit%20%26%20Apple%20Music%20API-blue?style=for-the-badge&logo=book&logoColor=white" alt="Exploring MusicKit and Apple Music API Book" />
  </a>
</p>

I wrote [Exploring MusicKit and Apple Music API](https://academy.rudrank.com/product/musickit) to document how I approach Apple Music projects—auth, storefronts, tooling, and the scrappy workflows behind packages like MusanovaKit. If you need a deeper reference, that book is where I keep the details.

## Requirements

- Swift 6.2 or later
- Xcode 16.2 (Swift 6.2 toolchain) or later
- An Apple Developer account with access to Apple Music privileged developer tokens

## Installation

Add MusanovaKit to your project using the Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/rryam/MusanovaKit.git", branch: "main")
]
```

Then add `MusanovaKit` to the target that should use these APIs.

## Authentication

All MusanovaKit calls depend on Apple Music authentication. There are two tokens involved:

### Privileged developer token

Obtain a privileged Apple Music developer token from your internal tooling and provide it to MusanovaKit (for example through the `DEVELOPER_TOKEN` environment variable or by injecting it directly into API calls).

### Music user token

When you call MusanovaKit from a signed-in MusicKit app, the system automatically attaches the Music User Token to privileged requests. If you issue requests from outside MusicKit (for example, using `curl`), include the `Media-User-Token` header manually.

## Lyrics

`MCatalog.lyrics(for:developerToken:)` fetches the syllable-lyrics TTML feed for a given song. The parser extracts both plain text and per-segment timing metadata.

### Fetching TTML lyrics

```swift
let song = try await MCatalog.song(id: "1156786545")
let lyrics = try await MCatalog.lyrics(for: song, developerToken: token)

for paragraph in lyrics {
    if let part = paragraph.songPart {
        print("\n\(part.uppercased()):")
    }
    for line in paragraph.lines {
        print(line.text)
    }
}
```

`lyrics` returns an array of `LyricParagraph` objects. Each paragraph contains:

- `songPart` – optional section labeling (Intro, Verse, Chorus, …)
- `lines` – an array of `LyricLine`

Every `LyricLine` now exposes:

- `text` – aggregated plain text for the line
- `segments` – `[LyricSegment]` representing the timed spans inside the line

Each `LyricSegment` includes the displayed `text` and `startTime` / `endTime` as `TimeInterval` values derived from the TTML `<span begin="…" end="…">` attributes.

### Working with timed segments

```swift
let paragraph = lyrics.first
let line = paragraph?.lines.first

line?.segments.forEach { segment in
    print("\(segment.text) starts at \(segment.startTime)s, ends at \(segment.endTime)s")
}
```

Use the segment timings to drive your own lyric highlighting, karaoke bars, or subtitle cues. Segments default to a `startTime` of `0` if the TTML omits the `begin` attribute.

### Direct lyric requests

If you need the raw TTML, instantiate `MusicLyricsRequest` directly:

```swift
let request = MusicLyricsRequest(songID: MusicItemID("1156786545"), developerToken: token)
let response = try await request.response()
let ttml = response.data.first?.attributes.ttml
```

`MusicLyricsRequest` automatically targets the `/syllable-lyrics` endpoint and decodes the `MusicLyricsResponse` payload.

## Replay and Summaries

MusanovaKit also contains helpers for Replay (Music Summaries) endpoints. These APIs return insights such as top artists, albums, songs, and milestone achievements for a user’s listening history.

### Milestones

```swift
let milestones = try await MSummaries.milestones(forYear: 2023, developerToken: token)

for milestone in milestones {
    print("\(milestone.kind): reached on \(milestone.dateReached)")
    print("Listen time: \(milestone.listenTimeInMinutes) minutes")
}
```

### Searching replay playlists

```swift
let results = try await MSummaries.search(developerToken: token)

for summary in results {
    print("Year: \(summary.year) → playlist: \(summary.playlist)")
}
```

## Library Pins

MusanovaKit provides access to the user's pinned items in their Apple Music library. Pinned items represent content that users have marked as favorites or important, and may appear prominently in the Apple Music interface.

### Fetching pinned items

```swift
let response = try await MLibrary.pins(developerToken: token, limit: 25)

for pinRef in response.data {
    print("Pinned: \(pinRef.id) - Type: \(pinRef.type)")
}

// Access detailed resources
if let albums = response.resources?.libraryAlbums {
    for (id, album) in albums {
        print("Album: \(album.attributes?.name ?? "Unknown") by \(album.attributes?.artistName ?? "Unknown")")
    }
}

if let songs = response.resources?.librarySongs {
    for (id, song) in songs {
        print("Song: \(song.attributes?.name ?? "Unknown") by \(song.attributes?.artistName ?? "Unknown")")
    }
}
```

The `pins()` method returns a `MusicLibraryPinsResponse` containing:
- `data`: Array of pin references with basic information
- `resources`: Detailed information about pinned items organized by type

### Custom pin requests

For full control over the request parameters, create a configuration object and pass it to the method:

```swift
var configuration = MusicLibraryPinsRequest(developerToken: token)
configuration.limit = 50
configuration.language = "es-ES"
configuration.librarySongIncludes = ["albums", "artists"]
configuration.libraryArtistIncludes = ["catalog"]

let response = try await MLibrary.pins(configuration: configuration)

// Access the raw response data
for pinRef in response.data {
    print("Pinned: \(pinRef.id) of type \(pinRef.type)")
}
```

### Creating pins

Pin albums, songs, artists, and playlists to the user's Apple Music library:

```swift
// Pin an album
let album: Album = // ... fetched album
try await MLibrary.createPin(for: album, developerToken: token)
print("Album pinned successfully!")

// Pin a song
let song: Song = // ... fetched song
try await MLibrary.createPin(for: song, developerToken: token)
print("Song pinned successfully!")

// Pin a playlist
let playlist: Playlist = // ... fetched playlist
try await MLibrary.createPin(for: playlist, developerToken: token)
print("Playlist pinned successfully!")

// Pin an artist
let artist: Artist = // ... fetched artist
try await MLibrary.createPin(for: artist, developerToken: token)
print("Artist pinned successfully!")
```

Available configuration options:
- `limit`: Maximum number of pins to return (default: 25)
- `language`: Language/locale for the request (default: "en-GB")
- `librarySongIncludes`: Relationships to include for songs
- `libraryArtistIncludes`: Relationships to include for artists
- `libraryMusicVideoIncludes`: Relationships to include for music videos

## Disclaimer

MusanovaKit is an exploration project. These endpoints are subject to change, can disappear without warning, and may violate Apple’s App Store policies. Do not submit apps that rely on this package to the App Store. Use the code for prototyping, research, or personal experiments only.