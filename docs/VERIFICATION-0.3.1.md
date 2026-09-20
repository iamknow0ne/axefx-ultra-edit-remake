# Ultra Edit 0.3.1 — live control latency

Verified on 20 September 2026 with an Axe-Fx Ultra, firmware 11.00, through Clarett 8Pre MIDI on Apple Silicon / macOS 27.0. This is a development build with the same feature-parity limitations as 0.3.

## Changes

- Sliders feed a live gesture stream during movement. One transaction is outstanding; intermediate pending targets are overwritten rather than accumulating.
- Short transactions have no added 40 ms cooldown. The stream is capped at 50 writes/second and follows the device's slower acknowledgement rate.
- Interactive writes and final verification take priority over queued background control reads. An already active transaction finishes first.
- Every gesture ends with an independent GET, with exact raw-value validation. Undo records its initial value once. Disconnect and transport failure cancel deferred targets; writes are never automatically retried.
- Initial preset values remain editable while formatted control values load. Model selectors and globals retain their existing restrictions.
- MIDI diagnostics have a separate observable model; tempo-only messages no longer invalidate the entire editor. The grid uses a value snapshot; routing menus are created on demand with AppKit, so parameter/log/busy changes do not rebuild thousands of hidden menu elements. Grid mutation methods still check current transaction state when invoked.
- Request timeouts run in common run-loop modes, including mouse tracking. Full-preset transfers retain their 800 ms settling interval and complete readback.

## Native rendering diagnosis

The native window initially showed 0.7–0.9 second reply delivery despite much faster CLI results. Profiling exposed repeated `NSSliderTickMarks._rebuildTickMarkRectCache` work: SwiftUI `step: 1` created up to 255 native tick marks per control. The final native slider has zero tick marks, rounds to integer raw values, and preserves one-unit arrow-key/accessibility increments. It sends continuous mouse actions and marks gesture start/end explicitly. Removing the visual tick marks eliminates that unnecessary geometry. `ui-tickmark-profile.txt` retains the sampled stacks. Earlier grid/log optimizations alone did not resolve this stall; the timing claim must be based on the final window test.

## Physical device timing

`evidence/v0.3.1/transport-comparison/latency.json` records the same one-unit Drive variation, twelve SET/GET cycles per transport, with a fresh backup and full restoration:

| Test | Mean complete SET + GET cycle |
| --- | ---: |
| Previous queue policy (40 ms pauses) | 169.99 ms |
| Current short-message transport, no added pause | 150.69 ms |
| Experimental native SysEx sender for short messages | 144.31 ms |

The small difference in the alternate transport was not sufficient evidence to replace the existing short sender. The dominant usability change is continuous editing and bounded backlog, rather than this cycle-time reduction alone.

A one-second stream of 200 target inputs produced 14 writes, with 13 replies before release. SET acknowledgement round trips averaged 71.55 ms (39.98–82.93 ms). The final target was independently read back 90.29 ms after the last input. A preceding independent run gave 14 writes and 91.68 ms final verification. Both entire preset payloads matched their starting backups.

These timings are MIDI control-path measurements, not recorded audio-onset measurements. They do not establish a hard real-time deadline, and are specific to this firmware/interface. Intermediate values are intentionally skipped. Model changes and full-preset transfers remain slower operations.

The final immediate-dispatch build repeated this benchmark: 14 writes, 13 acknowledged before release, mean SET round trip 72.05 ms, and 133.15 ms to final independent readback. Its SET/GET cycles averaged 147.61 ms (previous pause policy: 170.69 ms). Timing varies with the device response phase; the app does not advertise a guaranteed 90 ms response. See `final-latency/latency.json`.

## Final native-window acceptance

The final app's actual mouse drag submitted SET within 1 ms of its BEGIN marker, before the END marker. The Ultra acknowledged SET in **85 ms**; independent final GET completed **206 ms** after release. A single Undo restored Drive 124 → 151, with a 117 ms SET acknowledgement and 93 ms independent GET. The automated pointer gesture itself lasted only about 1 ms, so this is not a sustained human-drag benchmark; sustained streaming was tested separately on hardware above.

The precision slider also passed a one-unit Left-arrow change (151 → 150) after focus, and direct accessibility value setting. The on-demand right-click menu exposed the expected effect choices and existing input connection. The final independent `.syx` read after native Undo matches the fresh starting file, all 2060 bytes. Evidence: `native-ui-final.txt`, `native-ui-timing.json`, `final-ui-readback/` and `release-verification.json`.

Removing tick marks reduced the previously observed 0.7–0.9 s native acknowledgement stall to tens of milliseconds in the final UI. Audio-onset latency was not measured.

## Regression and recovery

- 19 core test groups: protocol/catalog/preset checks plus priority ordering, retargeting during final readback, failed-stream cancellation and immediate short-message submission.
- 11 editor integration groups: live changes before release, background-read priority, 200-event coalescing, one-gesture Undo, disconnect cancellation, and existing editor/offline/workbench behavior.
- 14 physical-device acceptance checks: native full upload/readback, 163 reads across six effects, rename, model changes, parameter edit/undo, routing and modifiers, followed by complete restoration.
- Hardware test backup and final payload SHA-256: `5bc192d0eac07b3791687667f12a94ab091f7c799c0b0a99215739330829fe53`. This is a fresh backup of the user's current settings, not the older 0.3 development baseline.
- The final immediate-dispatch queue also repeated all seven non-inventory hardware acceptance checks successfully (`final-hardware-suite/`).
- No persistent preset slots were written.

Evidence is under `evidence/v0.3.1/`. The native-window checks and release hashes are recorded alongside the hardware reports.

## What “real time” means here

The editor now sends changes during movement and avoids playing back obsolete cursor positions after you stop. It does not promise zero latency or sample-accurate automation. The Ultra also supports external controllers and modifiers for performance control, described in [Fractal's Ultra/Standard manual, Controllers and Modifiers](https://www.fractalaudio.com/downloads/manuals/axe-fx/User-Manual-Axe-Fx-Ultra-Standard.pdf). This release does not automatically reassign those controllers or change their global MIDI mappings.
