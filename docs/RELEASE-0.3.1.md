# Ultra Edit 0.3.1

Sliders now edit the Ultra during movement. The live stream retains only the most recent target, gives edits priority over background refreshes, verifies the final value, and makes a gesture one Undo step.

A macOS slider-layout bottleneck was identified with a native performance profile: hundreds of tick marks per slider caused large UI stalls. The replacement controls have no tick marks, retain integer MIDI precision, and support one-unit arrow-key steps. MIDI logs are isolated from the main interface and routing menus are built on demand. Short messages are submitted immediately, with no artificial 40 ms pause.

The app remains subject to device/interface latency; it is not sample-accurate automation. Model changes and full-preset transfers retain recovery snapshots and the hardware settling delay.

See [verification](VERIFICATION-0.3.1.md) for measurements, regression checks and hardware preservation evidence. Feature coverage remains as documented in [the Axe-Edit parity audit](PARITY-1.0.191.md).
