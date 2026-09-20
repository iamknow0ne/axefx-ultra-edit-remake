# 0.5 implementation and acceptance

Requested scope: remaining editing/library tools and hardware features, excluding firmware updates. Persistent Store acceptance may temporarily overwrite **slot 300 only**, with destination backup and exact restoration. User-cab destination authorization is separate.

## Design direction

Native macOS studio utility. Retain StudioTheme graphite, off-white and amber, original effect artwork, system typography and existing 4 × 12 patch bay. Dense lists/tables for numbered banks; toolbar/menu actions for Undo, file opening and performance tools; no decorative motion or new dashboard styling. Existing spacing 8/12/16/20, small 4–6 point corner radii, functional SF Symbols and clear disabled/error states. Keyboard focus must stay scoped to grid navigation, never intercept text editing.

## Delivery checklist

- [x] Bank export and complete 384-slot backup
- [x] Offline numbered bank manager with reorder/copy/swap/rename/Undo/Redo
- [x] Live parameter/model Redo with stale-state checks
- [x] Numeric entry with explicit estimate/raw distinction
- [x] File drop, Finder open and recent files/folders
- [x] Grid keyboard navigation/movement/removal and compatible settings clipboard
- [x] Bypass flags validated on five blocks; tap/tempo panel implemented
- [ ] Outgoing tap and real tuner-stream acceptance: hardware CC assignments still unconfirmed
- [x] User-cab encoding/export/experimental transfer and Cabinet1 selection implemented
- [ ] Hardware user-cab coefficient/audio validation: expendable User Cab destination still needed; no validated readback backup
- [x] Modifier overview/presets and global-controls diagnosis
- [x] Tuner transport and display
- [x] Store slot 300 backup/write/readback/restore
- [x] Tests, native visual review and updated guide
- [x] Final installer signature, mounted helper and Finder layout checks; release assets prepared

Unverified device behaviors must not be presented as validated features. Firmware transfer is excluded.
