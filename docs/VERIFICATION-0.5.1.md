# AxeFX Ultra Edit Remake 0.5.1 verification

This release changes product identity and distribution, not MIDI behavior. The [0.5.0 hardware record](VERIFICATION-0.5.0.md) remains the hardware evidence. No stored presets or cabinets were written for this release.

## Compatibility preserved

The app bundle and executable now use AxeFX Ultra Edit Remake / AxeFXUltraEditRemake. `CFBundleIdentifier` remains `tech.hostin.ultra-edit`; the document UTI, Application Support directory and internal module identifiers remain stable. Existing library, snapshot and preference locations are unchanged.

## Verification

Passed: native arm64 release build and bundle signature verification; 25 core checks; 18 editor integration groups; actual NAM inference for Linear, WaveNet and LSTM, with unsupported/malformed rejection; six regenerated production-view screenshots; documentation links and versions; 41 generated HTML pages with local links and versioned download destinations. The DMG image checksum is valid. Browser review covered 320px, 390px, 768px and 1280px layouts plus screenshot selectors and keyboard activation. These are software/distribution checks, not additional hardware validation.

## Website

The page uses real production-view screenshots with synthetic data. Screenshot selectors use native buttons with pressed state and a live caption; they support keyboard activation. The HTML manual is generated from the same Markdown sources as the offline installer documentation. Only curated site assets and documentation are deployed.

## Packaged application

The read-only mounted DMG contains the renamed app, Applications shortcut, offline Documentation and Installation guide. Finder layout was visually checked. The packaged arm64 executable launched successfully with `--offline`, showing the new window, menu, header and version identity. No MIDI connection was opened. The existing preference pin state was still visible under the preserved bundle identifier.
