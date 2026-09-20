# 0.5.3 persistent cache verification

## Software coverage

All 23 editor integration groups passed. They cover persistence after actual simulated slot reads, all 384 cache addresses including bank C, offline preview without MIDI, disconnect retention, separation by MIDI channel, refreshed-slot persistence, and isolation/recovery of a damaged cache file. The existing navigation, silent heartbeat, editing and recovery checks remain in the suite.

## Hardware and native UI

On Ultra firmware 11.00 through Clarett 8Pre, slot 130 (RingStiv) was read and cached. After quitting and reopening the app, the disconnected Library showed the cached name and timestamp. Preview restored its grid and controls without connecting or requesting MIDI data. Reconnection retained the cached slot and read the active RingStiv buffer. The 384-slot persistence check uses synthetic fixtures; the hardware restart check used slot 130.

## Boundaries

Cached data is a last-read copy, not a live mirror of front-panel changes. Profile matching uses MIDI endpoint identities, channel and protocol, not a hardware serial number. Live Ultra-slot activation still fetches the stored slot and validates the recalled preset as described in [0.5.2 verification](VERIFICATION-0.5.2.md). Cache storage is independent of the Mac preset library and recovery snapshots. No stored hardware presets need to be overwritten to test caching.
