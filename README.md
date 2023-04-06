# MusanovaKit

Explore and experiment with private Apple Music API endpoints. 

Note: Do NOT ship with this package. If you do, you are responsible for any backlash from Apple. This uses private Apple Music API endpoints that requires a privileged developer token.

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
