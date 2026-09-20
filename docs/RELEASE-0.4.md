# Ultra Edit 0.4.0

The signal grid now supports direct manipulation, with effect settings preserved and every live change verified against the Ultra:

- Drag a block into an empty cell. Moves within a column carry incoming and outgoing cables.
- Drop onto another occupied cell to swap the effects, keeping wiring at each position.
- To move across columns when attached cables would become invalid, hold Option while dragging to explicitly detach incompatible cables. The target outline and instruction line preview validity. The Ultra remains a 4 × 12 grid: cables run to the next column, with shunts spanning longer paths.
- Drag an output socket to an input socket, or work backwards from an input.
- Drag an existing cable to a different destination, or click it and press Delete/Backspace to disconnect. There is also a visible Disconnect cable button.
- Escape cancels an active drag. Right-click menus provide movement and input-routing alternatives.
- Routing Undo/Redo supports 50 live edits; offline draft routing uses the existing 100-step local history. Command-Z and Shift-Command-Z integrate with the main history commands. Placement/removal through the legacy context menu still uses the prior hardware workflow and resets routing history.

Live grid edits take a fresh recovery snapshot, preserve all effect/modifier/opaque bytes, transfer the edit buffer and verify all 1,024 payload bytes. This takes a few seconds over DIN MIDI; slider editing retains the separate low-latency path from 0.3.1. A newer front-panel change invalidates routing history rather than being overwritten by Undo.

The Library now separates **Ultra** from **On this Mac**. The Ultra browser includes all **384 slots, 0–383**, bank filters, slot-number/name search, progress/Stop, preview, edit-buffer audition and copy to the Mac library. Use **Read all 384**, read a bank, or search a number and read that slot. Stored reads do not select a program or change the current sound. Duplicate and unnamed presets retain separate numbered entries. Names are read for the current connection; imported files remain persistently saved on the Mac.

The user's slot **130: RingStiv** was confirmed by hardware and native UI. The previously displayed 128 entries came from an imported Bank A file. Firmware 11 also truncates bank-C reply addresses; the new reader accounts for this, verified against an independent full-bank dump. Imported B/C bank files now retain absolute slot addresses.

See [verification](VERIFICATION-0.4.md) and [the updated parity audit](PARITY-1.0.191.md). This release remains an ad-hoc signed local build, not a notarized public distribution.
