# Reverse engineering notes

## Supplied artifact

- `Axe-Edit_Setup_1_0_191.dmg`
- SHA-256: `db0d5919b11ab7021d505f5d602c3995137fb73a364cab3ead2acfe72be3fab9`
- Mounted read-only, package payload extracted without executing its installer/preinstall script.
- Original executable: Mach-O universal **i386 + ppc_7400**, both 32-bit; JUCE 1.52 symbols. No arm64 or x86_64 slice. A new implementation is necessary for current macOS.
- XML `Configs/Ultra/default.axeml` contains effect identities, parameters, modifier associations, page labels and synthetic bit switches.
- XML `Profiles/Ultra/default.profile` contains parameter scaling, enumerations and default values. Both declare firmware 10.1. The vendor distributed this installer for Ultra firmware 11.
- Metadata importer intentionally omits synthetic switch IDs 205–208 as normal parameter addresses. Bright and Boost update bits 1 and 3 of Amp parameter 28 while preserving other bits.
- Integer enumeration minimum is a **raw offset**. Example: pitch semitones use 103–151 with zero at 127. A menu item index alone is not the MIDI value.

## Binary-confirmed details (i386 virtual addresses)

The original binary retains C++ symbol names. Targeted disassembly is retained locally in `research/`.

| Routine | Address | Finding |
|---|---|---|
| `AxeFxMIDIProtocol::getVersion` | `0x2058f0` | Fractal ID, model 1, function 8, two zero bytes. |
| `AxeFxMIDIProtocol::getParameter` | `0x203680` | Effect, parameter and value in low/high nibbles; final query flag 0. |
| `AxeFxMIDIProtocol::placeEffect` | `0x2042d0` | Eight bytes inside SysEx framing: manufacturer, model, function, two effect nibbles, position. **No set/query byte**, contrary to the older community document. |
| `AxeFxMIDIProtocol::storePresetToBuffer` | `0x202c40` | Nine-byte header, 2048 encoded payload nibbles, XOR of decoded payload, checksum nibbles, F7. |
| `AxeFxMIDIProtocol::storePreset` | `0x202590` | 2060-byte transfer; edit-buffer/persistent destination flag in byte 6. For bank C the low address byte retains seven bits. |
| `AssetUtilities::updateAssetChecksumInSysex` | `0x188380` | XOR decoded payload bytes, excluding transfer header. |
| `AxeFxToggleButton::setToggleGroup` | `0x71380` | Bit selector is converted with 2^bit; it is a bit index, not a literal mask. |

## Implemented wire formats

Modern Ultra header: `F0 00 01 74 01`. Before firmware 10.02: `F0 00 00 <configured SysEx ID> 01`. Small Gen-1 command frames do **not** use the later Axe-Fx II/III trailing XOR checksum convention.

- Firmware: header + `08 00 00 F7`.
- Parameter: header + `02 effectLo effectHi paramLo paramHi valueLo valueHi setFlag F7`.
- Parameter reply: same address and value followed by a NUL-terminated display string.
- Current edit buffer: header + `03 01 00 00 F7`.
- Preset transfer: header + `04 destination addressLo addressHi`, then 1024 payload bytes encoded as 2048 nibbles, two checksum nibbles, F7.
- Payload contains version fields at 0–1, name at 2–21, grid at 34–129. Grid entries are effect ID and incoming-row mask; positions are column-major, `4 * column + row`.
- Full bank files contain 128 concatenated 1024-byte payloads in one SysEx frame. Destination byte 2/3/4 identifies banks A/B/C. All 384 presets in the supplied banks pass XOR and extraction/reassembly checks.
- Payload not needed for name/grid inspection remains opaque and is preserved byte-for-byte.

## Transport

CoreMIDI MIDI 1.0 ports; MIDI packets are traversed using their native offsets, and SysEx is reassembled across packet boundaries. Interleaved MIDI realtime bytes do not break assembly. Corrupt status bytes reset the frame; memory growth is capped. One queued transaction at a time, address-specific response matching, bounded timeouts, no automatic write retries, and generation tokens invalidate cancelled sends.

Version 0.2 uses native `MIDISendSysex` for full-preset transfers and an 800 ms post-acknowledgement settling interval. The older paced chunk path failed immediate readback during acceptance; native transfer plus settling passed. Small messages still use the ordinary MIDI output port. The alternate native `MIDISendSysex` sender was also checked while diagnosing the physical connection. The missing return-direction cable was resolved by the user; the standard sender then received real firmware, preset and parameter responses.

## External references

- [Fractal's Gen-1 downloads](https://www.fractalaudio.com/axe-fx-gen-1/) — confirms this legacy editor is incompatible with Catalina and newer.
- [Fractal-hosted Gen-1 SysEx documentation](https://wiki.fractalaudio.com/gen1/index.php?title=Axe-Fx_SysEx_Documentation) — starting protocol reference; it contains historical inaccuracies, so wire format claims above were checked against the supplied binary or actual hardware where stated.

No original executable code or skin artwork is used by the new app. This work is a local interoperability implementation for the user's supplied software and hardware, not a public release of Fractal's installer assets.

## Hardware findings that override older documentation

Firmware 11.00 was positively identified on the user's Ultra through Clarett 8Pre MIDI. The original Tiny Tweed dump is 2060 bytes and has a valid XOR checksum.

**Query-side effect:** `F0 00 01 74 01 02 0A 06 00 00 00 00 00 F7` queries Amp 1 model, but also resets seven amp fields on this firmware. It was isolated with before/query/after/restore dumps. Payload offsets 139, 145, 156, 157, 160, 161 and 162 changed. The hardware returned DELUXE VERB. No parameter set was sent during that isolated test. The original preset was restored and verified byte-for-byte.

The replacement avoids querying each effect's declared `typeParameterID` and reads its value from the preset record. Other Amp queries (38 controls) were tested together and did not change the preset. Explicit model changes still use SET and retain a whole-preset undo snapshot; the editor refreshes all dependent values afterward.

**Acknowledgement format:** the real Ultra acknowledged edit-buffer upload with `F0 00 01 74 01 0B 04 01 F7`: function 0B, original command 04, success 01. The implementation accepts this actual envelope as well as the older short status form. Edit-buffer recovery via the dedicated CoreMIDI SysEx API and full readback was verified twice.

**Parameter payload records:** offset 130 begins effect records of `[effectID, count, count parameter bytes]`, ending at a zero marker. Tiny Tweed includes Amp 1 count 39, Cabinet 1 count 18, Compressor 1 count 16, Delay 1 count 53, GEQ 1 count 17, Reverb 1 count 25, plus NoiseGate, Output and Controllers. The older factory bank Amp record has 38 bytes. The app uses the actual record length and avoids querying parameters absent from it. The remainder is preserved, not rewritten from guesses.

## 0.2 hardware acceptance findings

- Rename (function 09) did not acknowledge as expected on this device. Shipping rename instead changes only bytes 2–21 of a freshly captured payload, preserves all other bytes, recomputes XOR, uploads through the native sender and verifies readback.
- Routing placement/removal and connect/disconnect return the short function-specific status form; these all passed reversible hardware tests.
- Modifier writes can echo the supplied value without persisting it when no source is assigned. Assign source first, then query to confirm. Source assignment followed by damping change passed separate query verification. This agrees with the assignment order in [Fractal’s Gen-1 SysEx specification](https://wiki.fractalaudio.com/gen1/index.php?title=Axe-Fx_SysEx_Documentation). The app verifies every modifier write and uses raw values because returned formatting strings were inconsistent on the tested firmware.
- A MIDI outage occurred when querying global/input parameters; causality is unresolved. Global control access is preview-only pending further diagnosis. Preset reads still preserve those bytes.


## 0.4 stored slots and grid mutation

Original `recallPreset` at `0x203490` requests stored presets as header + `03 00 (slot & 0x0F) (slot >> 4) F7`, using a zero-based slot after the original UI's one-based conversion. Its `getName` overload is a stub; the new browser reads full stored payloads without program changes. All 384 addresses are represented, independent of local imported-bank contents.

On the connected firmware 11.00, bank-C single-preset replies truncate the echoed address to eight bits even though the returned payload is from bank C. Reads at 256/383 echo 0/127. This was compared with an independently received bank C (`03 04 00 00 F7`, response 262,156 bytes, destination flag 4): corresponding payloads match. Only the outstanding addressed read may normalize such a reply back to its requested C-bank slot; ordinary stored-file parsing does not guess addresses. Slot 130 was independently read as RingStiv. Bank-file extraction now retains `(bankFlag - 2) * 128 + index` in individual transfer headers.

Moves and swaps alter only payload bytes 34–129. Effect parameter records, modifiers and opaque bytes retain their original positions/content. Same-column moves remap incoming-row bits and outgoing edges; swaps retain position wiring. Cross-column moves reject nonadjacent edges unless explicitly told to detach them. Grid readback compares the whole 1,024-byte payload after native upload and settling. These operations passed on physical hardware; no persistent Store write was used.
