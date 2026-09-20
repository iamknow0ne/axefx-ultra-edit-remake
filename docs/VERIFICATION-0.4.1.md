# 0.4.1 release verification

Release preparation on 2026-09-20. This patch changes distribution, documentation, test fixtures and Cabinet Lab cancellation; it does not add new hardware-protocol behavior.

## Software

- 22 core groups passed with generated SysEx fixtures, including 384 synthetic bank entries, routing preservation, queue timing/identity/cancellation and checksum rejection.
- 16 editor integration groups passed with simulated MIDI, including real helper launch, recovery, stale state, readback mismatch, offline drafts, setlists and IR processing.
- Actual NAM inference passed for synthetic Linear, WaveNet and LSTM networks; the known linear impulse matched its analytical result. Malformed/unsupported input was rejected.
- A clean source export without build caches, `research/` or `evidence/` built the complete application and helper, then passed the same 22 core, 16 editor and NAM inference checks.
- Local Markdown links, image assets and version references passed. Generated offline HTML links and anchors were checked; landing page and user-guide layout were inspected in the browser.

## Images and provenance

Four screenshots render production SwiftUI views with synthetic offline data. Editor, library, Cabinet Lab and setlist renders were visually inspected. Original app artwork/icon are used. Tests no longer need private hardware backups, original bank files or the legacy executable. Historical factory parsing remains historical evidence, not the source of current public test data.

## Hardware scope

The [0.4 hardware report](VERIFICATION-0.4.md) covers live grid edits and a 384/384 scan with exact restoration. No hardware preset writes are needed for this distribution patch. No stored slot has been overwritten for acceptance; persistent Store remains unvalidated. Broader firmware/interface/OS coverage and audio listening validation remain open.

## Distribution scope

The available signing identity list is empty. The release is ad-hoc signed and is published as a development prerelease, not Apple-notarized. A successful local bundle launch is not proof of Gatekeeper acceptance for a quarantined download or clean installation on another Mac.

- `hdiutil verify` accepted the compressed image checksum.
- Mounted app and helper are native arm64; strict/deep signature verification passed and their bytes matched the packaged build.
- The helper ran from the mounted image and matched the analytical synthetic linear impulse.
- A copy extracted to a temporary installation folder remained running in an offline startup smoke check from an empty working directory. The connected editor was left running separately.
- Finder displayed the original installer background, app → Applications arrow and icons. Window chrome can reflect the local Finder's navigation preferences.
- The DMG includes the offline HTML manual and complete catalog reference. The release also carries a ZIP, third-party source archive and SHA-256 manifest.
