# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MusanovaKit is a Swift package providing access to Apple Music's private/privileged APIs (not exposed through public MusicKit). It re-exports MusadoraKit and MusicKit for convenient access.

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run tests with code coverage
swift test --enable-code-coverage

# Run a single test file
swift test --filter "LyricsParserTimedTests"

# Run linting
swiftlint
swiftlint fix  # auto-fix issues
```

## Architecture

Three main feature modules:

- **Lyrics** (`Sources/MusanovaKit/Lyrics/`): TTML lyrics parser with timed segments for karaoke/syncing
- **Music Summaries/Replay** (`Sources/MusanovaKit/Music%20Summaries/`): Year-based listening history, milestones, and search
- **Library Pins** (`Sources/MusanovaKit/Library/Pins/`): Pin/unpin items from user's library

## Dependencies

- **MusadoraKit**: Base library for Apple Music API (`branch: main`)
- **Swift 6.0** minimum, iOS 15+ / macOS 12+
- **Swift Testing** framework for tests

## Key Requirements

- **Privileged developer token** required for API access (set via `DEVELOPER_TOKEN` env var or passed as parameter)
- When called from a signed-in MusicKit app, the Music User Token is automatically attached

## Testing

Tests use Swift Testing framework with `@testable import` and `@Test` attributes. Test fixtures are in `Tests/MusanovaKitTests/Resources/`.

## API Exploration

- Use web inspector on MusicKit web endpoints to discover private API patterns
- Examine JSON responses for request/response structure
- Mock JSON responses in tests for parsing validation
