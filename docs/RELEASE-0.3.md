# Ultra Edit 0.3

Seven additions to the 0.2 release, available in the native arm64 app:

1. **Offline drafts** — edit ordinary parameters and names, autosave on each change, undo/redo up to 100 steps, recover the latest draft after restarting, and export a new `.syx` copy. Model selectors stay protected because changing only their ID would omit dependent defaults.
2. **Reusable effect settings** — save the selected block's parameter record, then paste it to an existing compatible instance. Family and record size must match. A live paste backs up the previous preset and checks all 1,024 payload bytes after upload. Routing and modifiers stay with the destination.
3. **Portable setlists** — capture sounds as independent preset copies, reorder songs, add notes, and export/import a self-contained `.ultraset`. Loading a song into the Ultra uses recovery capture and full readback; it is not a gapless scene switch.
4. **Cabinet lab** — import PCM 16/24/32-bit or float32 WAV, prepare mono 48 kHz / 1,024-sample impulses, trim leading silence, fade the tail, normalize, blend two impulses, change polarity/delay, and inspect waveform/frequency plots. Stereo inputs use the left channel.
5. **NAM linear approximation** — the bundled native NAM engine probes an actual model with positive/negative impulses at two levels. The result approximates filtering around silence and shows level sensitivity. Distortion, compression and playing dynamics cannot be represented by an IR. No perceptual match is promised.
6. **Cabinet audio audition** — load an amp/no-cab recording at 48 kHz (up to 15 seconds), compare dry/through-cab playback, and export the processed WAV. Playback uses macOS's selected output; wet export attenuates only if needed to prevent clipping. It does not render a full nonlinear NAM amplifier.
7. **Rig sheets** — export readable Markdown with routing, parameter values, exact raw values and a preset fingerprint for session documentation. Keep the `.syx` alongside it to retain modifier/internal data.

Live ordinary parameter writes now make a separate read request before reporting success. This detects an acknowledged value that did not persist.

## Using the new tools

- Read the Ultra, or inspect a library preset. Click **Create offline draft**; edits remain local. **Finish draft** returns to the Ultra and retains the autosaved draft. Export it, import the exported preset into the library, then audition when ready.
- Open **Workbench → Effect settings** to save/paste a block, or **Setlist** to organize captured sounds.
- Open **Workbench → Cabinet lab → Extract from NAM** or **Open WAV**. Prepare/blend, then **Export WAV**. The Ultra cannot read a `.nam` file directly. Direct user-cab transfer is not yet implemented; exported WAV is not a hardware `.syx` cab file.
- Use **Load audition WAV** with a short amp recording without a cabinet, then **Dry** / **Through cab**. Clear or adjust the blend if inverted IRs cancel to silence.

## Release boundaries

See [the original feature parity audit](PARITY-1.0.191.md). This release does not claim full legacy compatibility. Persistent Store, global/input controls, user-cab upload, firmware updating, bank management, tuner/tempo and several original workflow/UI functions remain unverified or missing.

The app is ad-hoc signed for local use, not Developer ID signed or notarized. Tested on this Apple Silicon Mac running macOS 27.0 build 26A428, with an Ultra on firmware 11.00 through Clarett 8Pre MIDI.

NAM dependency: [NeuralAmpModelerCore](https://github.com/sdatkinson/NeuralAmpModelerCore), revision `1f42f88535884450104b8711d7595019afa0495b`, MIT. Eigen and nlohmann notices are bundled in `Contents/Resources/ThirdPartyNotices.txt`.
