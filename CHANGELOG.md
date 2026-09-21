# Changelog

## 0.5.4 — Gen-1 SysEx import compatibility

- Accept Standard-tagged Gen-1 preset and bank files for the Ultra while keeping live MIDI reply validation strict.
- Recognize cabinet impulses separately, including legacy 512-sample and 1024-sample SysEx; save an imported-cabinet library accessible in Cabinet lab.
- Open WAV or cabinet SysEx directly in Cabinet lab.
- Keep compatible files when mixed imports contain unsupported formats; explain skipped files individually.
- Reveal imported tones in On this Mac and reset filters that could hide them.
- Increase top-level folder import capacity to 4096 files.

## 0.5.3 — Persistent Ultra library

- Cache every successfully read stored preset on the Mac, including partial scans and complete bank backups.
- Restore names and offline previews at startup; keep them after disconnecting.
- Separate caches by MIDI endpoints, channel and protocol; show the last cache time and an explicit Refresh action.
- Refresh the cached slot after live recall or verified Store. Corrupt cache entries are isolated and can be re-read.

## 0.5.2 — Library preset navigation

- Connection health checks now run silently, without periodically greying out the editor or flashing a pending-work indicator. Actual transfers and lost-connection detection keep their safeguards.

- Double-click a library preset to load it on the Ultra; single-click remains an offline preview.
- Previous/Next follows the visible search, bank, folder and favorites results, with selection highlighting and automatic scrolling.
- Ultra entries recall their actual numbered slot with bank select/program change and full-preset readback. Mac entries load the edit buffer.
- Save a recovery snapshot before each activation and block overlapping switches, drafts and disconnected MIDI.

## 0.5.1 — AxeFX Ultra Edit Remake

- Renamed the application, Swift package, release assets and repository to AxeFX Ultra Edit Remake.
- Added a responsive GitHub Pages landing page with real interface screenshots, direct downloads and a browsable HTML manual.
- Kept the bundle identifier and Application Support location so existing settings, libraries and snapshots carry forward.
- Refreshed the installer, documentation and screenshots. Hardware behavior and the 0.5.0 verification limits are unchanged.

## 0.5.0 — Bank and performance workspaces

- Complete bank A/B/C and all-384 backup/export; local numbered move/copy/swap/rename and 30-step Undo/Redo.
- Live parameter/model Redo with fresh-state checks, numeric raw/estimated-unit entry, grid keyboard editing and effect clipboard.
- File drop/Finder `.syx` opening, recent files, folder import and persistent local folder organization.
- Modifier assignment overview and persistent source-first modifier presets with individual field readback.
- Block bypass and verified preset Noise Gate/Output/Controllers edits. Tap tempo and tuner panel with explicit MIDI assignment confirmation.
- Gen-1 user-cab Q1.31 encoding/export, experimental upload, exact original `.syx` re-upload and Cabinet 1 selection for audition. Hardware coefficient/audio validation remains pending.
- Store validated on authorized slot 300, with destination and original edit buffer restored byte-for-byte.
- One-second settling after stored reads prevents a temporary transfer buffer being mistaken for the active sound; normal live controls keep their fast path.
- Firmware updating remains excluded. Ad-hoc signed development beta; not notarized.


## 0.4.1 — 2026-09-20

Distribution and documentation beta.

- Branded README with actual app-view screenshots and complete user/developer guides.
- Drag-to-Applications DMG, offline HTML documentation, source/notices archive and SHA-256 checksums.
- Self-contained synthetic SysEx banks, WAVs and NAM networks; tests and simulator no longer require user backups or the legacy installer.
- Reproducible screenshot/packaging scripts, optional Developer ID build signing and automated source checks.
- Fixed Cabinet Lab's inline Cancel button being disabled while NAM extraction ran.
- Expanded third-party license notices.

Still ad-hoc signed and not Apple-notarized. Persistent Store and complete legacy parity remain unvalidated/incomplete.

## 0.4.0 — 2026-09-20

- Interactive block move/swap, socket connections, cable reroute/delete, Option-drag detachment and routing Undo/Redo.
- Fresh hardware state, recovery snapshots and full readback for routing changes.
- All 384 device slots, bank filters, direct slot search, cancellable reads and copy to Mac library.
- Bank-C reply-address normalization validated against full-bank readback.

## 0.3.1

- Live slider streaming, newest-value coalescing, foreground priority and final readback.
- One Undo entry per gesture; MIDI activity isolated from full-editor redraw.

## 0.3.0

- Autosaved offline drafts, reusable effect settings and portable setlists.
- Cabinet WAV preparation/blending, local NAM linear extraction, local audio audition and Markdown rig sheets.
- Explicit feature-parity audit and hardware evidence limits.

## 0.2.0

- Native SwiftUI/CoreMIDI editor, illustrated effects, recovered catalog and initial hardware validation.
- Local preset library, snapshots, comparison, recovery and backup/export.

Historical verification and release notes remain under `docs/`.
