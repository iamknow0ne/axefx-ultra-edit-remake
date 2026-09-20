# Build & contribute

This repository contains the native editor, a developer MIDI probe, the offline NAM helper, dependency source, documentation and synthetic test fixtures. No open-source license has been selected for original project code; contributions do not imply an automatic license change.

## Prerequisites

- Apple Silicon Mac, macOS SDK and Swift 5.9+ (Xcode or Command Line Tools).
- CMake 3.18+, a C++20 compiler, Python 3, Git.
- For DMG Finder layout only: `ds-store==1.3.1` and `mac-alias==2.2.2` in a Python environment (see below).

Scripts default to `/Library/Developer/CommandLineTools`. Set `DEVELOPER_DIR` to your installed Xcode developer directory if needed. Accept any SDK license through your normal installation process; scripts do not accept licenses or install system tools automatically.

## Build and test

From the repository root:

```sh
./scripts/build.sh
./scripts/test.sh
./scripts/test-editor.sh
python3 scripts/test-nam.py
python3 scripts/check-docs.py
```

The build creates `dist/AxeFX Ultra Edit Remake.app` and a versioned arm64 ZIP. `APP_PATH` can choose a different bundle destination, useful when an older copy is running. `SIGN_IDENTITY` defaults to ad-hoc `-`; see [release process](docs/RELEASING.md) for Developer ID signing.

The core suite runs 25 groups using a small assertion adapter, so full Xcode/XCTest is not required. The 18 editor groups use an in-process simulated transport with readback mismatch, stale state and cancellation cases; they also launch the real NAM helper. NAM tests use actual Linear, WaveNet and LSTM inference and an analytical linear response. No test in these three suites opens physical MIDI ports or writes hardware.

Fixtures are committed and reproducible with `python3 scripts/generate-fixtures.py`. They are entirely synthetic and **must never be sent to hardware**. The generated WAV is a decaying tone, not a personal guitar recording. No factory bank/legacy installer is needed to build or test.

## Run and inspect

Open the generated `.app` for bundled resources and the NAM helper. To run without initializing MIDI, launch its executable with `--offline`. The raw Swift package executable needs `Resources/UltraCatalog.json` in the current working directory.

`ultra-probe` is a developer diagnostic tool. Read `Sources/UltraProbe/main.swift` before use: several modes write or restore the edit buffer and are not ordinary unit tests. Hardware testing requires a fresh backup, explicitly chosen ports, and full readback verification. Do not run hardware modes automatically in CI or use synthetic fixtures on a device. The simulator uses virtual MIDI endpoints only.

## Screenshots

```sh
./scripts/render-screenshots.sh
```

This renders production SwiftUI views using synthetic offline data in a temporary workspace. It does not connect MIDI, capture the user's screen, or read their preset archives. Review the generated PNGs visually before committing. `scripts/RenderScreenshots.swift` is also the documentation data fixture.

## DMG

```sh
python3 -m venv .build/packaging-venv
.build/packaging-venv/bin/pip install -r scripts/packaging-requirements.txt
./scripts/package-dmg.sh
```

Packaging creates a Finder-layout DMG with app, Applications shortcut, offline HTML guide and notices, plus SHA-256 checksums. It does not upload, notarize or alter repository visibility. For release acceptance, test a clean checkout without the ignored `evidence/` or `research/` folders.

## Change guidelines

Preserve unknown preset bytes. Never call an ACK a successful write without independent readback. Keep model-selector GETs and unvalidated global controls out of live query paths. Retain coalescing, request identity, cancellation and the post-upload settling interval. Do not place model inference or audio rendering on the MIDI/UI edit path.

Document behavior and evidence limits, not just implemented controls. Add focused tests for protocol/state-machine changes. Do not commit original installers, extracted proprietary binaries, personal presets, captures, keys, logs or generated build products. Keep third-party license notices and pinned source intact.

## Landing page

See [Website & GitHub Pages](docs/WEBSITE.md) for the static site build, local preview and deployment. The website uses the same documentation and original screenshots as the installer.
