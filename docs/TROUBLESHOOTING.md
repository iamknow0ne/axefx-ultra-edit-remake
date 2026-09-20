# Troubleshooting

[Documentation index](README.md) · [Install & connect](INSTALLATION.md)

## macOS blocks first launch

This beta is not notarized. Follow [First launch](INSTALLATION.md#first-launch) and Apple's per-app exception flow only if you trust the download. Check `SHA256SUMS.txt`; do not disable system-wide security or override a malware warning. Managed-device policy can prevent installation.

## Tempo light flashes, but Connect times out

An incoming tempo light proves only one MIDI direction. Check **interface OUT → Ultra IN** as well as **Ultra OUT → interface IN**. Select both interface ports in MIDI setup. Use the modern header for firmware 11.00; older firmware requires the correct configured SysEx ID. Close other editors and disable DAW MIDI echo. A cable, MIDI THRU selection, interface SysEx filtering or driver can still block responses.

## Interface missing or connection lost

Disconnect in Ultra Edit, reconnect the interface, then **Refresh ports** and reselect endpoints. Confirm the manufacturer's current driver supports your Mac. Finish/cancel pending activity before reconnecting. A timeout is not proof that an already transmitted write had no effect: read the current buffer afterward.

## Preset 130 or bank C is missing

Open **Library → Ultra**, not **On this Mac**. Clear the name filter or type the numeric address directly. All 384 rows exist, but names only appear after reads. A numeric search ignores the bank filter. A full scan takes several minutes and the cache resets on disconnect. The Mac library contains only imported/copied sounds. Hardware numbering starting at 1 must be translated to zero-based editor addresses.

## Settings feel delayed

Release the slider and wait for final verification. The latest pending value takes priority, so intermediate pointer positions can intentionally be skipped. Avoid simultaneous background scans or traffic from another editor/DAW. Whole-preset actions (routing, restore, paste) include upload, settling and full readback and can take about three seconds; they cannot match the single-control path. There is no zero-latency guarantee over DIN MIDI.

## A control is disabled, approximate, or not updating

Check whether you are previewing a file, in an offline draft, viewing an absent effect, or waiting for a transfer. Noise Gate/Output/Controllers need an existing preset record and apply via whole-preset readback. A value marked ≈ comes from catalog interpretation. Choose the current block and **Read controls** when enabled. Model selectors are intentionally not live-queried on firmware 11.00 because those queries can reset amp values.

## A grid drag is rejected

The Ultra accepts adjacent-column links only. Use shunts to cross gaps. Move vertically to preserve a route, or explicitly **Option-drag** to detach incompatible links. Occupied targets swap effects and keep position wiring. New offline effect instances are unsupported. A stale-grid warning means the hardware changed since the view was read: refresh and review instead of retrying blindly.

## Readback differs / Undo rejected

Stop making changes. Read the actual current buffer, inspect the MIDI log and recovery snapshots, and preserve a backup. An ACK only confirms receipt; the app compares full data after settling. History restoration is blocked if it would overwrite a newer external change. Restore a reviewed snapshot rather than relying on stale Undo history.

## NAM fails or does not sound like the capture

Unsupported architectures, malformed files and timeout/cancellation produce errors. The bundled helper must remain inside the app. A NAM-derived IR only estimates linear filtering near silence; distortion/dynamics cannot survive conversion to an IR. A small sensitivity percentage is not a sound-quality score. See [Cabinet Lab](CABINET-LAB.md).

## Cabinet blend is silent / audition disabled

Check B polarity, delay and mix; identical opposite-polarity responses can cancel. Prepare a non-silent impulse before loading audition audio. Audio must be a non-silent 48 kHz WAV, ≤15 seconds and ≤8 MB. General impulse inputs have a 32 MB limit and stereo uses the left channel. Check the Mac's audio output and volume. This tool does not route audition audio through the Ultra automatically.

## Local library or draft fails to open

Quit, copy `~/Library/Application Support/Ultra Edit/` somewhere safe, then recover a known-good archive or exported `.syx`. Do not delete data just to clear the message. Corrupt files are kept rather than silently overwritten. Setlist import creates a before-import backup in this folder.

## Report a reproducible problem

Use a repository issue with app version, macOS version, Ultra firmware, MIDI interface/driver, exact steps, expected/actual behavior, and relevant log excerpt. State whether it happens offline, through the simulator or on hardware. Review logs for personal preset names/data before sharing. Include a minimal preset only if you have permission to share it. For sensitive reports, follow [SECURITY.md](../SECURITY.md).

## A stored read seems to show the wrong current sound

Gen-1 temporarily reuses transfer data after a stored preset or bank read. Version 0.5 waits one second before the next transaction; this was verified with the active sound unchanged. Wait for the scan to finish, then use Read Ultra. Avoid running another editor concurrently.

## Tap/tuner or cab transfer does not respond

Check Performance CC assignments and the MIDI channel against I/O → CTRL. Incoming tempo proves reception, not that outgoing CCs are mapped. Stale tuner readings are hidden. User-cab upload is experimental; inspect the success/error message, preserve the original file and do not infer success from audio silence or the MIDI light. The app has no validated cabinet coefficient readback.
