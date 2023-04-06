# MusanovaKit

Explore and experiment with private Apple Music API endpoints. 

Note: Do NOT ship with this package. If you do, you are responsible for any backlash from Apple. This uses private Apple Music API endpoints that requires a privileged developer token.

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
