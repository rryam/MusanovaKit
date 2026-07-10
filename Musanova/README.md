# Musanova

Musanova is a sample app for trying MusanovaKit against a signed-in Apple Music account.

## Setup

Use a bundle identifier with MusicKit enabled, then build the app with your Apple Development team. Add the AMP developer token in Settings; the token is not part of the repository.

## Experiences

The macOS sample turns MusanovaKit responses into complete product surfaces:

- a live Concert Hub with artist artwork, dates, venues, details, and ticket links
- a personal Replay timeline with annual playlists and listening milestones
- synchronized lyrics with full playback, clickable line seeking, and centered auto-scroll
- a visual shelf of pinned library items

The Concerts tab can switch between New York, London, Mumbai, Delhi, and Bengaluru. The Lyrics tab currently uses Ed Sheeran's “A Little More” to demonstrate word-timed TTML, artwork-derived color, and icon-only transport controls.
