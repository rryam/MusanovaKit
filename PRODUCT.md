# Musanova Product Direction

## Product register

Musanova is a native macOS sample app that turns MusanovaKit's Apple Music endpoints into complete, understandable product experiences. It should feel like a small music app, not an API console.

## Audience and job

The primary audience is an Apple-platform developer evaluating MusanovaKit against their own signed-in Apple Music account. The app should make each capability immediately legible while still demonstrating production-quality SwiftUI composition.

## Experience principles

- Lead with music, artwork, artists, venues, and personal listening data.
- Keep implementation details and response diagnostics out of primary navigation.
- Prefer native macOS structure, typography, materials, controls, and accessibility behavior.
- Use the existing purple accent sparingly for selection, playback, and emphasis.
- Make loading, missing-token, empty, and API-error states feel intentional.
- Keep credentials local and private; never render or log the AMP token.

## Personality

Editorial, musical, confident, warm, and restrained. The interface should feel at home beside Apple Music without copying it.

## Anti-references

- API dashboards, status grids, and test-lab language
- Repetitive floating cards without meaningful visual content
- Decorative gradients that compete with artwork
- Tiny icon-only actions or low-contrast secondary text
- Custom interaction patterns where a native macOS control is clearer

## Accessibility baseline

Use semantic text styles, VoiceOver labels, sufficient contrast, keyboard-accessible buttons and links, and honor Reduce Motion when automatically following lyrics.
