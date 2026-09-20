# Axe-Edit 1.0.191 parity audit — Ultra Edit 0.4

**Verdict: not 100% parity, and not every hardware function is validated.** This is an inventory of identifiable features, not a percentage computed from an invented denominator. Ultra support is the target. Axe-Fx II-only features are separated. A recovered control definition is not proof of working behavior.

## Evidence and method

- Supplied original installer, SHA-256 `db0d5919b11ab7021d505f5d602c3995137fb73a364cab3ead2acfe72be3fab9`.
- Original `EditorReadme.txt`: release notes, known limitations and bug list, especially build 191/188 and 1.0 public beta.
- Original `Configs/Ultra/default.axeml` and `Profiles/Ultra/default.profile`: complete extracted catalog (36 families, 69 instances, 922 control definitions).
- `research/legacy-feature-strings.txt`: extracted original i386 UTF-32 UI labels, including hidden/unfinished commands. Strings prove a named feature existed in the binary, not that it worked.
- Original `Axe-Edit_Guide.pdf` contains only a quick-start placeholder link. `Axe-Manage_Guide.pdf` cannot be parsed as a complete PDF. Neither is treated as an exhaustive manual.
- Original protocol implementation and disassembly, native source review, automated tests, and actual Ultra firmware 11.00 / Clarett 8Pre trials.
- [Manufacturer's Gen-1 support page](https://www.fractalaudio.com/axe-fx-gen-1/) confirms the supplied editor supported Ultra firmware 11 and is incompatible with macOS 10.15 onward.

Status: **implemented** describes available code/UI; **hardware-tested** is limited to named operations on the connected unit; **partial** has specific gaps; **missing** is unavailable. Original known bugs are not presumed solved.

## Connection and editing

| Original capability | 0.4 result | Evidence / remaining gap |
| --- | --- | --- |
| Native editor on current Apple Silicon | Implemented and run | arm64 app, SwiftUI/CoreMIDI; this Mac tested, not every macOS version |
| MIDI port/channel settings | Implemented, hardware-tested | Clarett input/output, program channel selection |
| Legacy pre-10.02 SysEx ID | Implemented, software-tested | Actual unit is 11.00; old firmware untested |
| Firmware identification and connection indication | Hardware-tested | Live 11.00 replies |
| MIDI activity / troubleshooting | Partial | Log, export, bounded timeouts, hotplug; original loopback test absent |
| MIDI Merge / THRU / external controller synchronization | Missing | No controller merge or MIDI learn |
| Select preset / edit buffer | Implemented | Current reads tested; program recall not comprehensively tested across all slots |
| Parameter knobs, lists and switches | Partial hardware coverage | 922 definitions; 163 safe queries on six effects verified; remaining families/controls not all exercised |
| Numeric text entry / original knob interactions | Partial | Native sliders and menus; direct numeric entry not generally available |
| Model-dependent defaults | Hardware-tested for Amp | Explicit model SET and whole-preset restore; all model-dependent behavior untested |
| All modifier source/shape controls | Partial | Raw controls; source and damping edit/readback verified; complete source naming and all shapes unverified |
| Modifier overview / saved modifier settings | Missing | Individual modifier panel only |
| Noise gate / Output / Controllers panels | Preview only | Protected after unresolved MIDI interruption during prior tests |
| Effect/global bypass | Partial | Bypass-mode parameter exists; dedicated per-block toggle/global bypass absent |
| Effect initialization / initialize all | Missing | No factory-default reset command |
| Tuner | Missing | No tuner screen or remote activation in 0.3 |
| Tap tempo | Missing | Receives tempo beats for diagnostics; no tap or tempo UI |
| 4 × 12 grid and cables | Hardware-tested | Placement, shunts, connection/removal on edit buffer |
| Grid move/copy/swap, drag/drop and keyboard editing | Partial, added in 0.4 | Drag move/swap, socket/cable routing, Delete and context-menu alternatives tested; duplicate-instance copy and full legacy keyboard navigation absent |
| Grid undo/redo | Hardware-tested for new interactions | 50-step live history for move/swap/connect/disconnect/reroute with exact readback; older place/remove commands reset history |
| Parameter undo/redo | Partial | Live parameter undo; full offline-draft undo/redo; no general live redo |
| Copy/paste complete effect settings | Partial, added in 0.3 | Same family and exact record length; parameter bytes only, destination modifiers/routing preserved |
| Effect-setting file library and drag/drop | Partial | Persistent local settings library; original setting-file interchange and drag/drop absent |
| Snapshot/compare | Implemented | Exact payload diff and persistent snapshots; full-preset restore verified |
| Offline editing | Partial, added in 0.3 | Existing non-global ordinary parameters and names; existing grid move/swap and cable editing added in 0.4; no offline model initialization, modifier editing or creation of new effect instances |

## Preset and asset management

| Original capability | 0.4 result | Evidence / remaining gap |
| --- | --- | --- |
| Open/export individual .syx presets | Implemented and hardware-tested | Fresh current-preset backup and checksum checks |
| Read factory bank files | Software-tested | All 384 supplied A/B/C presets parse and round-trip |
| Rename | Hardware-tested | Full-preset mutation/upload/readback, avoids absent legacy rename ACK |
| Persistent Store | Implemented, unverified on hardware | Destination backup and readback path; requires an explicitly designated test slot |
| Full-bank receive / Sync and Backup | Partial | All 384 device slots can be read individually with bank filters and progress; separate full-bank C dump verified by probe; no full-bank backup UI or automatic synchronization |
| Full-bank send / selected-bank synchronization | Missing | No bulk persistent writes |
| Bank reorder/copy/swap/edit/undo | Missing | Library is a collection, not a numbered bank editor |
| Bank/folder/edit-buffer source modes | Partial | Device slots, imported Mac library, preview and edit-buffer audition; no full source-mode equivalence |
| Preset search by name/effect | Implemented | Persistent Mac library with favorites and duplicate detection; device slots support name/number search without deduplication |
| File/folder workspace tree | Missing | No general-purpose filesystem manager |
| CSV preset import/export | Missing | New Markdown rig sheet is a report, not original CSV interchange |
| Multiple dockable/colorized viewports | Missing | One editor window and a tools sheet |
| MRU/smart startup/automatic source saving | Partial | Library/snapshots/pins/draft/settings/setlist persist; no original automatic source synchronization |
| User-cab .syx management and transfer | Missing | WAV preparation/export is separate; user-cab protocol/gain/readback not validated |
| Cab audition and name cache | Missing | New local WAV convolution audition is not hardware user-cab audition |
| Firmware updater | Missing | Not tested by reflashing the user's working Ultra |
| Original skins/brightness/contrast/window layout | Replaced | Original vector devices and native studio UI, no legacy skin interpreter |
| File-drop / double-click file association | Missing | Open dialog provided; no document association or drag/drop |

## Not applicable to an Ultra replacement

Axe-Fx II X/Y states, II-specific parameter/CPU polling, II global blocks, II cab naming, USB transport assumptions, and II-specific model/control definitions are not Ultra capabilities. Standard/II editing and mixed-model workspace translation are outside this app's target. Original release notes also state that Standard/Ultra and II formats are incompatible.

## New tools beyond the 0.2 release

1. Autosaved offline drafts with 100-step undo/redo and recovery after restart.
2. Persistent compatible effect settings, with verified hardware paste.
3. Portable setlists embedding preset copies, ordered songs and notes.
4. Cabinet WAV preparation and two-IR blending, including polarity and sample delay.
5. Local NAM small-signal extraction with a two-level sensitivity measurement.
6. Local dry/through-cab audio audition and processed WAV export.
7. Readable rig sheets with routing, raw parameter values and preset fingerprint.

Effect settings also close a legacy gap. Rig sheets overlap the purpose of the original CSV report, but do not claim format compatibility. The NAM tool, cabinet processing/blending, local convolution audition, portable self-contained setlists and autosaved offline editing are substantive new workflows; none are substitutes for missing hardware parity.

## Acceptance gates still open

- Designate a disposable stored-preset slot for save/readback/restore acceptance.
- Diagnose global controls and test every effect family/model/mode/modifier field without changing the restored baseline.
- Reverse-engineer and verify user-cab scaling/encoding and a safe restore path before hardware upload.
- Implement and test the missing bank-management, tuner/tempo, initialization, controller and grid workflows above.
- Audio listening tests, additional MIDI interfaces/firmware, clean installation, Developer ID signing and notarization remain separate gates.
