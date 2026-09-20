# Axe-Edit 1.0.191 parity audit — Ultra Edit 0.5.0

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

| Original capability | 0.5 result | Evidence / remaining gap |
| --- | --- | --- |
| Native editor on current Apple Silicon | Implemented and run | arm64 app, SwiftUI/CoreMIDI; this Mac tested, not every macOS version |
| MIDI port/channel settings | Implemented, hardware-tested | Clarett input/output, program channel selection |
| Legacy pre-10.02 SysEx ID | Implemented, software-tested | Actual unit is 11.00; old firmware untested |
| Firmware identification and connection indication | Hardware-tested | Live 11.00 replies |
| MIDI activity / troubleshooting | Partial | Log, export, bounded timeouts, hotplug; original loopback test absent |
| MIDI Merge / THRU / external controller synchronization | Missing | No controller merge or MIDI learn |
| Select preset / edit buffer | Implemented | Current reads tested; program recall not comprehensively tested across all slots |
| Parameter knobs, lists and switches | Partial hardware coverage | 922 definitions; 163 safe queries on six effects verified; remaining families/controls not all exercised |
| Numeric text entry / original knob interactions | Implemented | Click values for exact raw or explicitly estimated units; native sliders/menus retained |
| Model-dependent defaults | Hardware-tested for Amp | Explicit model SET and whole-preset restore; all model-dependent behavior untested |
| All modifier source/shape controls | Partial | Raw controls; source and damping edit/readback verified; complete source naming and all shapes unverified |
| Modifier overview / saved modifier settings | Implemented, software-tested | Read current sources, save nine fields locally, apply Source first with independent field readback |
| Noise gate / Output / Controllers panels | Implemented with representative hardware tests | Preset records edited through complete verified transfers; system-wide settings excluded |
| Effect/global bypass | Partial, block flags hardware-tested | Dedicated per-block toggle, five present blocks tested; no global bypass |
| Effect initialization / initialize all | Missing | No factory-default reset command |
| Tuner | Implemented, hardware acceptance open | Original protocol decoder and display, configurable CC activation; played-note/remote tests pending |
| Tap tempo | Implemented, outgoing acceptance open | Incoming pulse/BPM verified; configurable CC sender requires matching hardware assignment |
| 4 × 12 grid and cables | Hardware-tested | Placement, shunts, connection/removal on edit buffer |
| Grid move/copy/swap, drag/drop and keyboard editing | Implemented within Ultra topology | Pointer routing plus scoped arrows/Option-arrows/Delete; duplicate-instance copy remains absent |
| Grid undo/redo | Hardware-tested for new interactions | 50-step live history for move/swap/connect/disconnect/reroute with exact readback; older place/remove commands reset history |
| Parameter undo/redo | Implemented, software-tested | Live parameter/model Redo with full fresh-state protection; drafts retain separate history |
| Copy/paste complete effect settings | Partial, clipboard added | Same family/exact record length; parameters only, destination modifiers/routing preserved |
| Effect-setting file library and drag/drop | Partial | Persistent local settings library; original setting-file interchange and drag/drop absent |
| Snapshot/compare | Implemented | Exact payload diff and persistent snapshots; full-preset restore verified |
| Offline editing | Partial, added in 0.3 | Existing non-global ordinary parameters and names; existing grid move/swap and cable editing added in 0.4; no offline model initialization, modifier editing or creation of new effect instances |

## Preset and asset management

| Original capability | 0.5 result | Evidence / remaining gap |
| --- | --- | --- |
| Open/export individual .syx presets | Implemented and hardware-tested | Fresh current-preset backup and checksum checks |
| Read factory bank files | Software-tested | All 384 supplied A/B/C presets parse and round-trip |
| Rename | Hardware-tested | Full-preset mutation/upload/readback, avoids absent legacy rename ACK |
| Persistent Store | Hardware-tested on slot 300 | Explicitly authorized temporary write; all bytes read back; original destination and active buffer exactly restored |
| Full-bank receive / Sync and Backup | Backup implemented and hardware-tested | A/B/C and all384 export; 384 slots checksummed/round-tripped and eight independent slot comparisons; no automatic sync |
| Full-bank send / selected-bank synchronization | Missing | No bulk persistent writes |
| Bank reorder/copy/swap/edit/undo | Implemented locally | Numbered bank manager with 30-step Undo/Redo; export before quitting; no bulk send |
| Bank/folder/edit-buffer source modes | Partial | Device slots, local folders, numbered bank workspace, preview/edit-buffer audition; no full legacy mode equivalence |
| Preset search by name/effect | Implemented | Persistent Mac library with favorites and duplicate detection; device slots support name/number search without deduplication |
| File/folder workspace tree | Partial | Top-level folder import and persistent logical groups; no general-purpose filesystem manager |
| CSV preset import/export | Missing | New Markdown rig sheet is a report, not original CSV interchange |
| Multiple dockable/colorized viewports | Missing | One editor window and a tools sheet |
| MRU/smart startup/automatic source saving | Partial | Recent12 files and persistent library/snapshots/pins/drafts/settings/setlist/folders; no automatic device sync or bank autosave |
| User-cab .syx management and transfer | Implemented experimentally | Q1.31 golden-byte/checksum/round-trip tests; export/upload/original-file re-upload; hardware coefficients/gain/audio unvalidated |
| Cab audition and name cache | Partial | Local convolution and explicit USER selection in Cabinet1; no hardware cab name cache, audio validation pending |
| Firmware updater | Excluded by request | No firmware transfer implemented or tested |
| Original skins/brightness/contrast/window layout | Replaced | Original vector devices and native studio UI, no legacy skin interpreter |
| File-drop / double-click file association | Implemented | File drop and alternate Finder handler import to the Mac library; no automatic hardware load |

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

- All effect/model/mode/modifier combinations, including audible bypass behavior beyond the tested flag readbacks.
- Real remote tap/tuner operation and a played-note stream using confirmed MIDI assignments.
- Expendable User Cab destination and physical gain/audio checks; no validated coefficient backup/readback is available.
- Bulk bank writes/sync, effect initialization, MIDI merge/learn/THRU and remaining legacy interchange/UI gaps listed above. Firmware updating is explicitly excluded.
- Audio listening tests, additional interfaces/firmware, external clean installation, Developer ID signing and notarization.

[0.5 verification](VERIFICATION-0.5.0.md) separates completed acceptance from these remaining limits. No proprietary executable or personal preset dump is distributed.
