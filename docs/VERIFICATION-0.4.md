# Ultra Edit 0.4.0 verification — 2026-09-20

Native arm64 on the same Mac, macOS 27.0, Axe-Fx Ultra firmware 11.00 via Clarett 8Pre MIDI. No persistent preset-slot writes were made.

## Software

- `evidence/v0.4/software/core.txt`: 22 passing groups. Grid movement, swaps, cable validation, exact round trips, preservation outside routing bytes, all slot boundaries, checksum handling, absolute imported-bank addresses and bank-C echo normalization. Existing live-edit/request-queue regression groups remain green.
- `evidence/v0.4/software/editor.txt`: 16 passing groups. Fresh-value preservation, recovery snapshots, verified routing Undo/Redo, main Undo integration, stale front-panel edit and grid rejection, mismatched-readback recovery, offline routing with zero MIDI writes, device-library address matching, duplicate-slot retention and cancellation; prior editor/NAM/cabinet checks also pass.

## Physical device

`evidence/v0.4/validated-hardware/grid-verification.json` and `.txt` record stored-slot reads at 0, 127, 128, 129, 130, 255, 256 and 383; a same-column Amp move with attached cables; disconnect/reconnect; swapping effects; exact complete-preset readbacks and baseline restoration.

A full 262,156-byte bank-C dump was independently received and checksum-validated. Individual reads of slots 256 and 383 matched the corresponding bank payloads, despite the hardware echoing addresses 0 and 127. Slot 0 was a different preset (Studio Lead), so treating the truncated C reply as a bank-A slot would be incorrect. `bank-C.syx` and single-slot `.syx` files retain the evidence. Slot 130 is RingStiv.

Fresh baseline payload SHA-256: `d432910f159642b87f1e02df5071b6d49715f5b982fe617601e7a8ad40328be4`. This includes the user's newer routing (shunt at row 2 / column 1; Compressor at row 3 / column 2). Older development baselines were not restored.

## Native UI

Actual pointer-driven actions on the connected app:

- Drag Amp from row 2 to row 1 in column 2; incoming and outgoing cables follow; status confirms verified routing.
- Undo the move.
- Select Cabinet → GraphicEQ cable and press Backspace; drag its output/input sockets to reconnect.
- Drag the shunt → Amp cable onto the Compressor input; Undo restores the previous routes.
- Drop Amp onto Cabinet to swap; Undo, Redo and Undo again restore the baseline.
- Library Ultra search 130, read and display RingStiv without changing Tiny Tweed in the edit buffer.
- Final packaged app: search/read 383 succeeds and displays its unnamed preset.

`evidence/v0.4/native-grid-log.txt` is exported from the native app. A subsequent independent probe (`native-grid-final-readback/probe-3-function-4.syx`) exactly matches the fresh backup, all 2,060 file bytes, not just a command acknowledgement. Pointer automation performs short drags; a long human-held drag is not separately measured here.

The final packaged app completed a **384/384** device-library scan. Slot 130 displays RingStiv; slot 383 reads successfully. Native Edit-menu Redo and Undo were exercised after the scan. The subsequent native backup, `evidence/v0.4/final-after-library-and-grid.syx`, matches every byte of the fresh 2,060-byte baseline. The app remains connected with the full library loaded and slot 130 visible. Hardware reading is deliberately user-triggered and cancellable; unread rows remain visible rather than being removed from the library.

## Visual/accessibility review

Native screenshot inspection at the user's window size confirmed readable artwork, visible amber sockets/cables, selected/empty cells, contextual disconnect action, separate library sources and numbered results. Intentional native system typography, existing graphite/amber tokens, compact patch-bay layout, and no ornamental motion. Keyboard Delete works for a selected cable; Undo/Redo and right-click alternatives exist. This is a basic review, not an exhaustive VoiceOver audit. Self-review: AI-slop score 0/10; distinctiveness 8/10 (rack artwork and actual hardware routing define the interface).

## Limits

Routing uploads use native full-preset transfers and the proven 800 ms settling delay, followed by full readback. A complete transaction takes about three seconds over this MIDI connection; this is separate from the low-latency slider path. Invalid topology is rejected; Option-drag explicitly detaches incompatible links. Copying/creating new effect instances offline, general live parameter Redo, complete legacy bank management and persistent Store acceptance remain outside this increment. The parity audit retains these gaps. No claim of all-firmware/interface coverage, notarization or 100% legacy parity.
