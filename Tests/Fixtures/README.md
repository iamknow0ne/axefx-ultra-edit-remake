# Synthetic test data

All `.syx`, `.wav`, and `.nam` fixtures in this directory are generated from scratch by `scripts/generate-fixtures.py`. No factory sounds, user presets, recordings, or trained commercial captures are included.

The SysEx files exercise framing, banks, addresses, routing, parameter records and opaque-byte preservation. **They are software fixtures, not validated playable presets. Do not send them to an Axe-Fx.** Their opaque tail deliberately contains invented bytes.

The WAV files contain generated decaying sinusoids. NAM fixtures are tiny deterministic Linear, WaveNet and LSTM networks with invented weights; they do not model any real device. The linear network supplies a known analytical impulse for inference checks.
