# Feature status — 0.5.0 beta

[Documentation index](README.md) · [Detailed legacy parity audit](PARITY-1.0.191.md)

“Implemented” means code and UI exist. “Hardware-tested” applies only to the described operation on an Ultra firmware 11.00 via Clarett 8Pre. Software tests and catalog counts do not prove every hardware behavior.

| Feature | Status and practical boundary | Guide |
| --- | --- | --- |
| Native Apple Silicon app | arm64, SwiftUI/CoreMIDI; macOS 13 target, locally exercised on macOS 27.0 | [Install](INSTALLATION.md) |
| MIDI connect, firmware, ports/channel | Physical connection tested; pre-10.02 header is software-tested only | [Connect](INSTALLATION.md#connect) |
| Illustrated 36-family / 922-definition inspector | Implemented; only a subset of parameters/models physically exercised | [Effects](USER-GUIDE.md#editing-an-effect) |
| Streaming slider gestures | Priority/coalescing and release readback tested; hardware latency depends on interface | [Controls](USER-GUIDE.md#displayed-values-and-responsiveness) |
| Model changes and live Undo/Redo | Amp model change and whole-preset restoration tested | [Effects](USER-GUIDE.md#editing-an-effect) |
| Modifier panel | Source/damping tested; overview and saved shapes added with source-first field readback; full source naming incomplete | [Modifiers](USER-GUIDE.md#modifiers) |
| Move/swap/socket/cable drag | Native pointer and full-preset readback tested; valid 4 × 12 topology only | [Grid](USER-GUIDE.md#interactive-grid) |
| Routing Undo/Redo | 50 live steps; fresh-state/stale-history and mismatch checks; older place/remove resets history | [Grid](USER-GUIDE.md#interactive-grid) |
| All 384 device slots | Full native scan completed; A/B/C boundary reads and bank-C echo normalization tested | [Libraries](USER-GUIDE.md#preset-libraries) |
| Local `.syx` collection | Single/bank import, checksum validation, deduplication, favorite/search, preview/load/export | [Libraries](USER-GUIDE.md#preset-libraries) |
| Backup, rename, snapshot/restore | Full-byte readback and restoration tested; snapshots persist | [Snapshots](USER-GUIDE.md#snapshots-and-comparison) |
| Persistent Store | Implemented with destination backup/readback; **slot 300 write/readback and exact restoration passed** | [Store](USER-GUIDE.md#store) |
| Autosaved offline draft | Existing controls/name/routing, 100-step Undo/Redo; no new instance/model initialization/modifiers | [Drafts](USER-GUIDE.md#offline-drafts) |
| Effect settings | Same family/layout only; retains destination routing/modifiers; hardware paste tested | [Settings](USER-GUIDE.md#reusable-effect-settings) |
| Portable setlists | Embedded presets, order, notes, import/export; not a gapless live controller | [Setlists](USER-GUIDE.md#portable-setlists) |
| IR preparation/blending | PCM/float WAV, 48 kHz/1,024 samples, polarity/delay, plots/export | [Cabinet Lab](CABINET-LAB.md) |
| NAM linear extraction | Actual synthetic Linear/WaveNet/LSTM inference tested; cannot reproduce nonlinear amp behavior | [NAM](CABINET-LAB.md#extract-a-response-from-nam) |
| Local audio audition | WAV convolution/export tested; uses Mac audio, no live capture | [Audition](CABINET-LAB.md#audition-and-export-audio) |
| Rig sheet | Markdown settings/routing/fingerprint; not an import format | [Rig sheets](USER-GUIDE.md#rig-sheets) |
| MIDI log/export | Diagnostics only, no learn/merge/THRU | [Diagnostics](USER-GUIDE.md#midi-setup-and-diagnostics) |

## New workflows

| Feature | Boundary |
| --- | --- |
| Full bank backup/export | All 384 hardware slots read, checksummed and round-tripped; eight independent boundary/address checks; active buffer unchanged |
| Numbered local bank manager | Move/copy/swap/rename, 30-step Undo/Redo; export before quitting; no bulk hardware writes |
| Numeric entry | Exact raw or explicitly estimated units, bounded and quantized |
| Live Redo | Parameter/model history with fresh-state check; refresh clears history |
| Preset globals | Gate/Output/Controllers changed through verified complete transfers; three representative fields physically tested |
| Block bypass | Dedicated flag toggle; five block families tested for byte preservation/readback |
| Performance panel | Incoming tempo verified; tap CC and tuner decoder/UI implemented, remote/played-note tests pending |
| User cabinets | Q1.31 `.syx` export, experimental transfer, exact original-file re-upload and Cabinet 1 selection; hardware gain/coefficients/audio unverified |
| File workflows | Finder association/drop, recent 12 paths, top-level folder import and persistent logical folders |
| Grid keyboard/clipboard | Scoped arrows, Option-arrows, deletion and compatible parameter clipboard |
| Modifier workspace | Source overview and locally saved shapes, source-first application with independent queries |

Read [all new workflows](WORKSPACES-0.5.md) and [Cabinet Lab](CABINET-LAB.md).

## Not available or not validated

- Firmware updating is excluded. Effect initialization/reset, system-wide I/O/calibration/global EQ and global bypass remain absent.
- Bulk bank writes/sync, original setting-file interchange/CSV, MIDI learn/merge/THRU and external-controller synchronization remain absent.
- Tuner remote control/played-note stream, tap control and user-cab hardware audio need separate acceptance; no full legacy parity claim.
- Multiple dockable viewports, other hardware models, exhaustive VoiceOver, all model/control combinations and broad OS/interface coverage remain open.
- Developer ID signing, Apple notarization and external clean-machine acceptance remain open.

## Evidence

The release uses 25 core groups, 18 editor integration groups, and real NAM inference checks. Public tests use synthetic data; historical factory-preset parsing and user-hardware trials are separate evidence. [0.4 verification](VERIFICATION-0.4.md) describes the physical grid/library tests. [0.4.1 verification](VERIFICATION-0.4.1.md) records release packaging and clean-source checks. Private dumps are not included.

[0.5.0 verification](VERIFICATION-0.5.0.md) records Store, globals, bypass, complete banks and the remaining acceptance limits.
