# 0.5.4 import verification

## Coverage

All 25 core checks and 24 editor integration groups passed.

Core regression checks exercise Standard-tagged file imports while rejecting those headers in live-response parsing, 512-to-1024 coefficient preservation, checksum failures, and wrong-generation rejection. Editor checks cover mixed supported/unsupported selections, cabinet persistence and deduplication, filter reset, local cabinet preparation, and zero MIDI sends while importing.

A read-only audit of 12 top-level files in a private user collection accepted six tone files and five cabinet files; one Axe-Fx II file was correctly rejected. A sampled legacy 512-sample archive cabinet also parsed. A nonstandard 2064-byte preset remained unsupported. The entire nested collection was not content-audited; Google Drive placeholder downloads made broad reading slow. Private files are not included in the repository or public screenshots.

Native UI checks imported a Standard-tagged tone into On this Mac and a cabinet into Cabinet lab, where its 1024-sample waveform and frequency response rendered. Hardware playback and cabinet storage were not exercised by these import checks; no stored presets or user cabinets were overwritten.

The final build reopened the persisted tone and cabinet library and reconnected to firmware 11.00 through Clarett 8Pre. The original tone file appeared under its embedded preset name, and cabinet persistence was visible after restart.
