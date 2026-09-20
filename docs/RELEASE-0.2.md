# Ultra Edit 0.2

## New

- Original illustrated amp heads, speaker cabinets, stompboxes, expression pedals, EQs, synths and rack effects in the signal grid, sidebar and inspector.
- Graphite studio layout, copper selection, effect-family colors, dial readouts and responsive control modules.
- Named local snapshots, persistent across launches, with exact parameter/routing/name comparisons. Unknown data changes are explicitly identified rather than silently ignored.
- Restore with automatic recovery snapshot and full-preset readback verification.
- Local preset library persistence, name/effect search, favorites, duplicate detection and individual exports.
- Pin frequently used controls per effect instance.
- Matching application icon.

## Reliability fixes

Full presets use the native CoreMIDI SysEx sender, followed by an 800 ms settling period. Readback equality remains required. Initial/post-command refreshes no longer depend on stale UI activity counts. Undo history is removed only after successful acknowledgement. Slot values are checked before MIDI encoding. Previews clear stale values. Non-zero raw control minima are respected. Model changes retain a persistent recovery snapshot. Rename uses a backed-up, verified full-preset transfer. Modifiers require a source assignment and independent readback. Global controls remain preview-only while their MIDI path is being diagnosed.

## Using snapshots

Open Snapshots in the left sidebar, enter a name, and choose Capture current sound. Compare reads the latest connected edit buffer, or compares an offline file preview. Raw values in the comparison are exact; formatted approximations are marked with ≈. Restore saves a recovery snapshot before changing the hardware edit buffer. Store is a separate operation.

The library is local to this Mac at `~/Library/Application Support/Ultra Edit/`. Imported files remain unchanged. Use Export for portable `.syx` copies. No account or network service is involved.

This is a development release. See VERIFICATION-0.2.md for actual evidence and remaining hardware coverage.
