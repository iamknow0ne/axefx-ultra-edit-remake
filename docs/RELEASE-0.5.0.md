# Ultra Edit 0.5.0 beta

This release adds complete bank backup, a numbered local bank editor, live Redo, numeric value entry, grid keyboard controls and effect clipboard, file opening/folders, modifier overview/presets, preset globals and a performance panel.

Store passed an explicitly authorized slot-300 write/readback/restore test. All384 presets were backed up and round-tripped, with independent checks including slot130. Noise Gate/Output/Controllers and five block bypass flags passed representative device readback tests. Original stored/active data was restored exactly.

Cabinet Lab adds Gen-1 `.syx` export, experimental upload, original-file re-upload and Cabinet1 selection. Tuner/tap commands and cabinet hardware audio still need their separate acceptance checks. NAM extraction remains linear filtering only; it cannot reproduce a capture's distortion/dynamics. Firmware updating is excluded.

**Apple Silicon · macOS13+ target · development prerelease · ad-hoc signed · not Apple-notarized.** Tested hardware: Ultra firmware11.00 via Clarett8Pre. Full legacy parity and every OS/hardware combination are not claimed.

- [Install and first launch](INSTALLATION.md)
- [Complete user guide](USER-GUIDE.md)
- [New workspaces](WORKSPACES-0.5.md)
- [Cabinet Lab](CABINET-LAB.md)
- [Verification and limits](VERIFICATION-0.5.0.md)
- [Legacy parity audit](PARITY-1.0.191.md)
