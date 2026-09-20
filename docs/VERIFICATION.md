# Verification — 17 September 2026

## Confirmed working

- Release binary is a 64-bit **arm64** Mach-O executable, built with Apple Swift 6.1.2 / Command Line Tools. No Rosetta is used.
- Native app launched and visually inspected on this Mac: **macOS 27.0, build 26A428**.
- Connected over **Clarett 8Pre MIDI** to the user's **Axe-Fx Ultra, firmware 11.00**.
- Real preset **Tiny Tweed** read, validated and rendered with its grid: Compressor 1, Amp 1, Cabinet 1, GraphicEQ 1, Delay 1, Reverb 1 and shunts.
- Native UI Drive decrement changed raw 151 → 150 (5.94 → 5.91); Undo returned raw 151 (5.94).
- Firmware query-side effect found, isolated and fixed. The first UI pass queried model ID 0 and triggered seven hardware-side amp changes; the original pre-test dump was restored exactly. The final code reads model/mode selectors from preset records.
- Corrected hardware path read all **38 non-model Amp controls**; all 1024 payload bytes stayed unchanged.
- Final edit/restore test changed Drive, separately queried the new value, restored it, separately queried the original value, and compared a new full preset dump. The **entire 2060-byte SysEx message matches the original pre-test capture**.
- SHA-256 of original and final restored SysEx: `e7e9e86eee48f461efbe9ba57b6bedc44d96e77242c6602070eac8293dc52623`.
- No persistent hardware preset slot was written.

Evidence: `evidence/hardware-verification.json`, `evidence/hardware-final-edit/edit-verification.txt`, `evidence/hardware-safe-reads/edit-verification.txt`, `evidence/recovery-query-type/recovery-log.txt`, and their raw `.syx` captures. The earlier native UI's actual two parameter SET messages are in `evidence/Ultra-Edit-MIDI-log.txt`.

## Software checks

Nine standalone test groups passed:

1. Modern and legacy firmware/name/preset queries.
2. Golden parameter bytes, reply decoding and malformed replies.
3. Original-binary placement format and routing bounds.
4. Fragmented SysEx, realtime interleaving and parser resynchronization.
5. Preset bank/channel boundaries and ASCII name limits.
6. Preset round trips, corruption rejection and incomplete-file rejection.
7. 922 recovered definitions, integer offsets, real acknowledgement envelope and all 384 original factory presets.
8. Request identity matching and cancellation.
9. Timeout behavior without repeating a write.

A separate virtual MIDI device verified CoreMIDI firmware/name/parameter queries and reassembly of a fragmented 2060-byte response. Virtual evidence is labelled separately; it is not used as physical-hardware proof.

## Visual review

The actual native window was inspected in disconnected and hardware-connected states. Amp model, live values, unread/disabled controls, grid, sidebar, menus and status were visible and coherent. Keyboard-accessible slider decrement and Undo were exercised on the real device. Native controls and focus/labels are present; this is not a comprehensive VoiceOver audit.

Design review: AI-slop score 0/10; distinctiveness 8/10. Deliberate system typography, graphite native surfaces, restrained green accent, instrument grid and dense controls. No decorative motion, gradients, glow, emoji icons or generic marketing cards.

## Remaining acceptance work

- Test multiple presets, every effect type, all modifiers and routing operations across firmware versions.
- Validate explicit model-change/whole-preset Undo in the native UI, larger restore sessions, program changes and persistent Store on a designated expendable hardware slot. These are implemented; no persistent slot was used for testing.
- The native recovery test used CoreMIDI's full SysEx sender. The application's paced multipart preset upload path still needs physical-device acceptance testing.
- Legacy firmware, other interfaces, other macOS releases, clean-machine installation and sustained reconnect testing are not established by this session.
- No firmware updater, IR uploader or full-bank writer is implemented.
- Local ad-hoc code signing is present. Developer ID signing, notarization and public distribution are not completed.
