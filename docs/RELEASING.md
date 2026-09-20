# Release process

[Documentation index](README.md) · [Build prerequisites](../CONTRIBUTING.md)

## Version and scope

The current release is **0.4.1 beta**. Update `VERSION`, the editor footer, bundle build number, changelog, badges/download links and release notes together. Do not claim complete legacy parity or notarization unless the relevant acceptance gate passes.

The repository is private. Publishing a release does not change that visibility. Only source, original artwork, synthetic fixtures, vendor source/notices, build scripts and documentation belong in Git. Legacy installers/binaries, personal device dumps, recordings, logs and build output remain excluded.

## Verify a clean source tree

Run `scripts/build.sh`, `scripts/test.sh`, `scripts/test-editor.sh`, `python3 scripts/test-nam.py` and `python3 scripts/check-docs.py` from a fresh checkout. The checkout must work without `research/` or `evidence/`. Regenerate screenshots when visible behavior changes and inspect the actual images.

Hardware tests are deliberate, separate operations: preserve a fresh preset backup and compare complete readback. Do not make persistent writes without an expendable destination explicitly designated for testing. Do not restore historical fixtures over a newer user preset.

## Sign

By default the build ad-hoc signs the helper and application, then checks both. A valid local Developer ID certificate can be selected explicitly:

```sh
SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' ./scripts/build.sh
```

That path enables hardened runtime and secure timestamps. A certificate name is not a secret, but private keys, credentials and provisioning material must never enter the repository. Signing with Developer ID alone is not notarization.

## Package

Install the pinned packaging requirements in `.build/packaging-venv`, then run `scripts/package-dmg.sh`. `APP_PATH` selects a nondefault bundle when needed. The script verifies the bundle, generates the offline HTML manual, creates a read-only compressed DMG with Finder layout, verifies its image checksum, archives corresponding third-party source, and writes release SHA-256 hashes. It does not publish automatically.

Mount the result read-only, validate both binaries, check the app version/arm64 architecture and inspect the Finder layout/manual. Copy out and launch the packaged app in offline mode; keep downloaded Gatekeeper behavior separate from an unquarantined local launch. Test the bundled NAM helper from the mounted/copied app.

## Notarization gate

The 0.4.1 release has **no Developer ID identity and no Apple notarization ticket**. It must be labeled as a development prerelease with explicit first-launch instructions.

For a future notarized release, submit the Developer ID-signed DMG using an authorized `notarytool` Keychain profile, wait for acceptance, staple the ticket, validate stapling and Gatekeeper assessment, then regenerate checksums. Never label an ad-hoc build as notarized. Test a quarantined download on a separate Mac as a separate acceptance step.

## Publish

Push reviewed source to `iamknow0ne/axeedit_remake`. Tag the matching commit, create the GitHub prerelease, and attach:

- `Ultra-Edit-VERSION-arm64.dmg`
- `Ultra-Edit-VERSION-arm64.zip`
- `Ultra-Edit-VERSION-third-party-source.tar.gz`
- `SHA256SUMS.txt`

Release notes must link installation, the guide, changes and known limits. Verify the release is published, the tag resolves to the intended commit, all assets exist, and a downloaded asset matches its local SHA-256. Keep source-license choice and repository visibility unchanged unless the owner requests otherwise.
