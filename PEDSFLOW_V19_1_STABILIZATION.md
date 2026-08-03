# PedsFlow v19.1.0 — Stabilization Release

Implemented August 2, 2026.

## Changes

- Search normalization extracted into a tested service.
- Added aliases for common misspellings, abbreviations, and brand names.
- Search now requires all query terms and ranks exact/prefix matches first.
- Search corpus is cached when the screen opens instead of rebuilt on each keystroke.
- Empty result groups are hidden and a clear no-results state was added.
- Added accessibility semantics and clear-search controls.
- Numeric calculator parsing now rejects non-finite input.
- Numeric fields use improved keyboard actions and accessibility labels.
- Added PWA scope, app ID, language, categories, viewport, and theme metadata.
- Added automated tests for search aliases, matching, and ranking.
