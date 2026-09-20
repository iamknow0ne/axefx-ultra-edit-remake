# 0.3 verification — 20 September 2026

## Build

Native arm64 app and bundled arm64 `nam-ir` helper. Built using Command Line Tools; no Xcode license was accepted. Current machine: macOS 27.0 (26A428). Both binaries target macOS 13+, but earlier operating systems were not exercised. Deep/strict ad-hoc signature verification passed. No claim of notarization or public-distribution readiness.

NAM source pin: `1f42f88535884450104b8711d7595019afa0495b`, copied from an existing clean local checkout of the official NeuralAmpModelerCore repository. All runtime components are packaged in the app; source does not depend on the other local project. Test WaveNet/LSTM fixtures are the upstream example models, not a representative library of commercial/user captures.

## Software

- 15 core groups: previous protocol/framing/bank/checksum/queue/archive coverage plus exact offline parameter mutation, forbidden model/global edits, effect layout rejection, self-contained setlists, WAV parsing/truncation/non-finite rejection, resampling anti-alias suppression, leading silence trim, polarity cancellation, delay, analytic frequency response and convolution.
- 9 editor integration groups: actual EditorModel with an isolated simulated transport and temporary archives; ordinary edit/readback/undo, rename/snapshot restore, protected controls, offline edit/rename/undo/redo/restart recovery with zero MIDI writes, effect-setting and setlist persistence, live paste/song load readback, cabinet model/PCM/convolution/export state, and actual helper launch/NAM extraction.
- 4 native NAM checks: an analytical biased linear model (recovered taps within 1e-5), actual WaveNet inference, actual LSTM inference, and rejection of invalid model data.
- 384 original factory presets and all 922 recovered control definitions are covered by the core catalog/file tests. This does not mean every control is physically tested.

Logs: `evidence/v0.3/software/`; NAM results: `evidence/v0.3/nam/`.

## Physical Ultra

Fresh firmware reply: **11.00**, input/output **Clarett 8Pre MIDI**. Starting preset: **Tiny Tweed**.

`evidence/v0.3/hardware-suite/acceptance.json` records 14 successful acceptance checks:

- Native complete preset upload and readback.
- 163 safe control reads: Compressor 15, Graphic EQ 17, Amp 38, Cabinet 17, Reverb 24, Delay 52. Complete preset comparison after every effect.
- Rename and full restore.
- Amp model change and full restore.
- Drive edit, independent query and undo.
- Shunt placement, cable connect/disconnect, removal and restore.
- Nine modifier reads, source assignment when needed, damping edit/readback and restore.
- Final complete baseline equality.

Native GUI trials additionally covered:

- Create offline draft from the connected preset; decrement Drive 151→150 without a hardware write; Undo/Redo; finish draft and observe the Ultra still at 151.
- Save Amp settings and capture the draft in a setlist with notes.
- Load the setlist sound into the actual Ultra: full 1,024-byte readback verified, Drive 150; restore the pre-load snapshot: full readback verified, Drive 151.
- Paste the saved Amp setting on the actual Ultra: full readback verified. Independent CLI capture showed exactly one changed payload byte: offset 133, 151→150.
- Restore the initial backup and independently compare the entire 2,060-byte SysEx file.

Final `hardware-suite/after.syx` equals `baseline/probe-3-function-4.syx` byte-for-byte. SHA-256 of both complete messages:

`e7e9e86eee48f461efbe9ba57b6bedc44d96e77242c6602070eac8293dc52623`

**Zero stored-preset writes. Zero user-cab writes. No firmware flashing.** Persistent Store remains unverified; no test slot was designated during this run.

## Native cabinet UI and visual review

Reviewed actual editor, setlist, effect-settings and NAM/cabinet screens via native accessibility and screenshots. Draft states, original device illustrations, full-readback statuses and warning text were visible. The 900×760 workbench scrolls its cabinet content without hiding the Done/Cancel footer.

- Actual in-app WaveNet extraction displayed two-level sensitivity (5.5% for the upstream fixture), waveform, logarithmic frequency response, 48 kHz / 1,024 samples and 0.95 peak.
- Native WAV export created `ui-NAM-linear-approximation.wav`, independently parsed as float32 mono, 48 kHz, 1,024 finite samples.
- An initial audition test fixture was accidentally quantized to silence; independent export validation caught this. Its output is retained as `ui-cabinet-audition-silent-fixture.wav` and is not a passing artifact. Corrected fixture, non-silent-input assertions and a silent-clip error were added.
- Final-build cabinet preparation and non-silent audition: macOS playback returned success. Export `ui-cabinet-audition-final.wav` contains 49,023 finite float32 samples at 48 kHz, peak 0.0711006. This is software playback/export evidence, not a subjective listening assessment or a captured physical Ultra cab.
- Automated cabinet model also exports `model-audition.wav` and verifies that a cancelling blend invalidates any stale preview audio.

Design assessment against the established skill: AI-slop risk 2/10, distinctiveness 8/10. Main surfaces retain graphite/copper rack language and original vector gear. Native dialogs and lists are functional rather than custom-skinned. Remaining trade-off: dense tools require scrolling on small windows; full VoiceOver and multiple display-size testing remain uncompleted.

## Limits

The [parity matrix](PARITY-1.0.191.md) is the authoritative gap list. NAM extraction is a central finite difference near silence, not a faithful amp conversion; the two-level disagreement is not an overall fidelity score. IR output remains WAV, with no validated user-cab upload. All models/effects/modes, every modifier field, global controls, additional interfaces and operating systems, and original bank/tuner/tempo/firmware workflows are not established by these results.
