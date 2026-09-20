# 0.5.2 library navigation verification

## Software coverage

All 25 core checks and 22 editor integration groups passed. Editor checks cover the existing editor plus numbered recall across 127/128 and 255/256, slot 383, filtered forward/back navigation, empty results, list boundaries, rapid duplicate activation, Mac uploads with exact readback and recovery, wrong-preset identity rejection, and disconnect between bank select and program change.

Health-probe regression checks hold a reply open and confirm controls remain available, reject duplicate probes, queue a real user transaction with the normal lock, and verify a missing reply still disconnects.

## Recall verification

Stored-slot recall checks the returned checksum, name, routing and effect instances. Firmware can convert old record lengths, clamp obsolete values or add missing Output/Controllers records. The app displays the actual recalled data. It does not claim byte-for-byte equivalence to the older stored file when firmware converts it. Identical names/routing cannot prove the selected physical address if a custom MIDI program map redirects it. Mac-library uploads retain exact 1024-byte payload comparison.

## Hardware and native UI

Native double-click on slot 130 (RingStiv) returned an exact readback through Clarett 8Pre on firmware 11.00. Testing slot 131 exposed initialization of missing Output and Controllers records; slot 0 (Studio Lead) exposed an old 38-byte Amp record expanding to 39 bytes. The stored and recalled dumps were compared before revising the verification to distinguish recall from file upload. Recovery snapshots capture the actual pre-switch sound. The final native run successfully recalled 0 → 1 → 0 with Next/Previous, double-clicked 130, then used Next/Previous for 130 → 131 → 130. The session ended on RingStiv with exact readback verified. No error remained for the device-converted presets.

The rebuilt native app reconnected to firmware 11.00 and displayed RingStiv. Its MIDI log recorded repeated firmware-query replies at five-second intervals; these no longer contribute to the interface busy state.

No stored presets, firmware or cabinets are written by this change. Switching is not gapless. Coverage is limited to the tested Ultra/interface/firmware.
