# 0.5.0 verification

[Feature status](FEATURES.md) · [Legacy parity audit](PARITY-1.0.191.md)

## Real Ultra: firmware 11.00 through Clarett 8Pre

### Store, authorized slot 300 only

A fresh edit-buffer backup was taken before reading the destination. The original slot was backed up before any write. A temporary renamed preset was stored in slot 300, independently read and compared across all 1,024 payload bytes. The original slot and genuine pre-test active edit buffer were restored and compared byte-for-byte. No other stored slot was written.

During development, an immediate edit-buffer query after a stored read exposed a firmware transfer-buffer transient. Early verification captured that transient as the baseline and was rejected as acceptance evidence. The genuine pre-test backup was restored. The final test reads the active sound first, waits one second after stored reads, and verifies the correct original throughout. The application queue now enforces this settling interval for stored preset/bank reads; ordinary parameter traffic retains its fast path.

### Full banks

Bank A, B and C were read as complete checksummed transfers: all **384 slots**. Each bank was exported and decoded again with exact payload equality. Independent stored-preset reads of **0, 127, 128, 130, 255, 256, 300 and 383** matched the bank data. The active buffer was unchanged after each bank and at completion. These tests issued no hardware writes.

### Preset globals and bypass

One raw step in representative existing Noise Gate, Output and Controllers fields was applied through complete preset uploads. Each full 1,024-byte readback matched, and the original was restored.

Amp 1, Compressor 1, Cabinet 1, Delay 1 and Reverb 1 bypass flag bits were toggled and independently read back. Only the expected flag byte changed; all other bits/data were preserved. Each operation and the final state were restored exactly. This establishes control/readback behavior, not a comprehensive audible test of every bypass mode.

## Software verification

- **25 core groups:** bank addressing/export/checksums, numeric boundaries, Gen-1 cabinet golden bytes and exact Q1.31 extrema, tuner framing, MIDI controller bounds, stored-read settling, preset preservation, routing, scheduler and existing workspace/IR tests.
- **18 editor integration groups:** actual model refresh/edit/history/restore paths, stale front-panel rejection, global transfer safety, modifier source-first SET plus independent GET, bank Undo/Redo, file-import atomicity/folder persistence, and prior draft/grid/library/NAM workflows.
- Real synthetic Linear/WaveNet/LSTM NAM inference and malformed-input checks.
- Production SwiftUI views rendered with invented presets/IR/audio only. Native window inspection verified connection to firmware11.00 and the original sound, incoming tempo display, numeric raw-value prefill and out-of-range rejection, grid arrow navigation, bank B/slot130 import/selection/rename/Undo, and a complete live modifier-source scan (24 entries in the current sound). A stale bank validation message found during this check was fixed and covered by a regression assertion.

Tests and documentation screenshots contain no factory or personal presets. Hardware dumps and detailed traces remain private local evidence, excluded from Git.

## Still unverified

Tuner CC activation, actual played-note stream and outgoing tap behavior require confirmed hardware CC assignments. Incoming Ultra tempo pulses are verified. Cabinet transfer/gain/audio requires an expendable User Cab slot, separate from preset slot 300. Its protocol/codec and UI are implemented, but successful encoding or an ACK is not coefficient readback or an audio match. All effect/model combinations, other interfaces/firmware/OS versions and external clean-machine acceptance remain open.

Firmware updating is deliberately excluded. Distribution is an **ad-hoc signed, unnotarized development beta**, not a Developer ID release.

## Distribution checks

The arm64 application and bundled NAM helper passed strict ad-hoc signature checks. The read-only DMG mounted successfully, its version was 0.5.0, and the helper executed a real synthetic model from inside the mounted bundle. Finder layout inspection found the lower documentation items clipped on this Mac; the installer window height was increased before final packaging. The offline manual uses VERSION for its footer to avoid stale release labels.
