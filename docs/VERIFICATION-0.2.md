# Ultra Edit 0.2 — acceptance record, 18 September 2026

## Result

The UI and local workflow upgrade is implemented. Twelve protocol/workspace test groups and four editor integration groups pass. Physical tests on the Ultra/Clarett verified native preset transfer, 163 queries across six effects, rename, Amp model change/restore, parameter edit/undo, shunt placement/removal, connections/disconnections, modifier source assignment and damping edit/readback. All temporary hardware changes were restored to the original preset byte-for-byte. Global controls, persistent Store and wider device/firmware coverage remain outside this sign-off.

## Hardware evidence

- Actual Ultra firmware 11.00, Clarett 8Pre MIDI, current sound Tiny Tweed.
- Current session baseline saved before testing: `evidence/v0.2/baseline/probe-3-function-4.syx` and `evidence/v0.2/acceptance/before.syx`.
- The old 128-byte paced upload received a success acknowledgement but failed immediate byte comparison. The separate native recovery sender restored the original exactly (`evidence/v0.2/recovery/restored.syx`). An acknowledgement alone is insufficient.
- The shipping app now uses `MIDISendSysex` for full presets and prevents subsequent transactions for 800 ms after acknowledgement. This combined path passed full 1024-byte readback in `evidence/v0.2/native-acceptance-retry/after-upload.syx`.
- Compressor 1: 15 queries; GraphicEQ 1: 17; Amp 1: 38; Cabinet 1: 17; Reverb 1: 24; Delay 1: 52. Each effect was followed by a full-preset equality check: all unchanged.
- Subsequently no replies or tempo traffic were received. A separate read-only probe also received zero bytes. The timing does not establish whether the cause is firmware, interface or a physical disconnection. The user was asked to check the front panel and MIDI indicator.
- NoiseGate, Output and Controllers currently display values from the preset only; direct control reads and writes are disabled pending diagnosis. Reserved “Spare” controls are also excluded from editing and queries.
- MIDI later recovered. A fresh full read exactly matched the initial baseline. The interrupted session is retained as evidence, not counted as a successful full run.
- `evidence/v0.2/verified-actions/acceptance.txt`: rename via full-preset upload, Amp model change/restore, Drive edit/readback/undo, shunt placement, connect/disconnect and removal all passed. The recovery dump after this run matches the initial baseline.
- An unassigned modifier echoed a value without retaining it. The corrected acceptance assigns source 1 first, verifies it independently, then changes and queries damping. Both pass; every preset byte is restored afterward (`evidence/v0.2/modifier-source-validation/acceptance.json`). The app now requires source assignment and independently verifies modifier writes. The firmware’s modifier display strings did not reliably match field units, so the UI explicitly shows raw values.
- The legacy rename command did not return the expected acknowledgement. Rename now captures a fresh full preset, changes only name bytes, saves a recovery snapshot, uploads and verifies the whole result. This path passed on hardware.
- No persistent preset slots were written. Final physical readback equals the exact original baseline.

Baseline decoded-payload SHA-256: `3857ce90f1e580ab189b88d8fbd9052ee845e95259fb1d90fcebaec2983f12e3`.

## Software tests

`./scripts/test.sh` runs 12 groups covering golden/legacy MIDI, invalid inputs, real-time framing, all 384 original factory presets, checksum failures, queue identity/cancellation/timeouts, snapshot differences, archive round trips, corrupted archive preservation, search, multipart cancellation, native transfer dispatch and the settling interval.

`./scripts/test-editor.sh` compiles the actual EditorModel with an injected in-memory device. Four integration groups cover:

1. Initial preset refresh, live control population, and selector-query exclusion.
2. Named snapshot capture, one-control change comparison, parameter edit and Undo.
3. Rename with UI refresh, snapshot restoration with byte comparison, automatic recovery capture and persistence across model restarts.
4. Global control selections issue no MIDI reads or writes.

The injected device verifies application logic; it is explicitly not physical-hardware evidence. This caught and fixed a callback/activity-state bug that could suppress refresh after a successful command.

## Native UI inspection

Actual SwiftUI window launched and inspected at its restored approximately 1280×900 size. Device illustrations, grid wiring, inspector faceplate, adaptive control modules, dark surfaces and status were visible without clipping. Native menu, search, disabled offline controls, library import, favorite toggle, preset preview, pin toggle, snapshot naming/capture and exact no-change comparison were exercised.

The final native UI also captured “Original Tiny Tweed”, decremented Drive from 151 to 150, showed exactly one comparison row, then restored the snapshot with “all 1024 bytes verified”. A fresh backup exported through the app (`evidence/v0.2/ui-restored.syx`) equals the initial 2060-byte capture byte-for-byte. Its SHA-256 is `e7e9e86eee48f461efbe9ba57b6bedc44d96e77242c6602070eac8293dc52623`.

Factory bank A imported as 128 presets. Searching Tiny Tweed returned one. Its favorite and snapshot are retained locally. The app preserves unknown SysEx data; artwork is original vector drawing representative of effect families, not copied manufacturer assets.

Visual review: slop score 1/10 (repeated control modules serve actual parameters); distinctiveness 8/10 (instrument illustrations, signal path, family colors, macOS controls). Native labels, keyboard sliders and focus rings remain. VoiceOver and all display scales are not comprehensively audited.

## Remaining work

- Diagnose the intermittent MIDI interruption and validate global control access before enabling it. Broader routing and modifier combinations remain to be tested.
- Persistent Store needs a designated expendable slot; it was not tested on the user's saved presets.
- Every effect/model, legacy firmware, other MIDI interfaces and macOS versions require broader acceptance.
- No IR/firmware upload, tuner display or full-bank writes.
- Local ad-hoc signing only; no Developer ID/notarized public release.
