# MusanovaKit

MusanovaKit lets you explore Apple Music features that are not exposed through the public MusicKit framework. It includes helpers for private APIs such as privileged lyric endpoints and Music Summaries (Replay) data. **Use this package for research and internal tooling only.**

> ⚠️ MusanovaKit calls Apple Music endpoints that require a **privileged developer token**. Shipping these APIs inside production software is likely to violate Apple’s terms and may break without notice. Proceed at your own risk.

## Table of Contents

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

MusanovaKit can return the original TTML, parsed paragraphs, or a flat list of timed segments. `MCatalog.lyrics(for:developerToken:)` remains available and returns the parsed paragraphs.

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

Fetch the segments directly when paragraph and line grouping isn't needed:

```swift
let segments = try await MCatalog.timedLyrics(for: song, developerToken: token)

for segment in segments {
    print("\(segment.startTime): \(segment.text)")
}
```

`MCatalog.parsedLyrics(for:developerToken:countryCode:)` returns the grouped paragraphs explicitly. Both methods accept an optional storefront country code; without one, MusicKit resolves the current storefront.

### Raw TTML

Use `rawLyrics` when you need Apple Music's original document:

```swift
let ttml = try await MCatalog.rawLyrics(for: song, developerToken: token)
```

To decode the complete resource, including its playback parameters, call `lyricsResponse` instead.

### Direct lyric requests

If you need the raw TTML, instantiate `MusicLyricsRequest` directly:

```swift
let request = MusicLyricsRequest(songID: MusicItemID("1156786545"), developerToken: token)
let response = try await request.response()
let ttml = response.data.first?.attributes.ttml
```

`MusicLyricsRequest` automatically targets the `/syllable-lyrics` endpoint and decodes the `MusicLyricsResponse` payload.

You can also parse TTML obtained elsewhere. `parse` returns an empty array for malformed input, while `parseValidating` throws `MusanovaKitError.invalidResponseFormat`:

```swift
let paragraphs = try LyricsParser().parseValidating(ttml)
let segments = paragraphs.timedSegments
```

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

### Pinning and unpinning items

Pin and unpin albums, songs, artists, and playlists to/from the user's Apple Music library:

```swift
// Pin items
let album: Album = // ... fetched album
try await MLibrary.pin(album, developerToken: token)

let song: Song = // ... fetched song
try await MLibrary.pin(song, developerToken: token)

let playlist: Playlist = // ... fetched playlist
try await MLibrary.pin(playlist, developerToken: token)

let artist: Artist = // ... fetched artist
try await MLibrary.pin(artist, developerToken: token)

// Unpin items
try await MLibrary.unpin(album, developerToken: token)
try await MLibrary.unpin(song, developerToken: token)
try await MLibrary.unpin(playlist, developerToken: token)
try await MLibrary.unpin(artist, developerToken: token)
```

All `Album`, `Song`, `Playlist`, and `Artist` types conform to the `Pinnable` protocol, allowing them to be used with the `pin(_:developerToken:)` and `unpin(_:developerToken:)` methods.

The `Pinnable` protocol is defined as:

```swift
/// A protocol that represents a music item that can be pinned to the user's Apple Music library.
///
/// This protocol includes the requirement that items must be music items that can be identified
/// and pinned through Apple's private API endpoints.
public protocol Pinnable: MusicItem {}
```

Available configuration options:
- `limit`: Maximum number of pins to return (default: 25)
- `language`: Language/locale for the request (default: "en-GB")
- `librarySongIncludes`: Relationships to include for songs
- `libraryArtistIncludes`: Relationships to include for artists
- `libraryMusicVideoIncludes`: Relationships to include for music videos

## Disclaimer

MusanovaKit is an exploration project. These endpoints are subject to change, can disappear without warning, and may violate Apple’s App Store policies. Do not submit apps that rely on this package to the App Store. Use the code for prototyping, research, or personal experiments only.

[![Star History Chart](https://api.star-history.com/svg?repos=rryam/MusanovaKit&type=Date)](https://star-history.com/#rryam/MusanovaKit&Date)
