# Install & connect

[Documentation index](README.md) · [User guide](USER-GUIDE.md)

## Requirements

| Item | Requirement |
| --- | --- |
| Mac | Apple Silicon; native arm64, no Rosetta required |
| macOS | 13+ deployment target; local hardware testing on macOS 27.0 |
| Processor | First-generation Axe-Fx **Ultra**; validated hardware runs used firmware 11.00 |
| MIDI | macOS-compatible interface supporting bidirectional SysEx, plus two MIDI cables |
| Internet | Download only; editing and Cabinet Lab run locally |

Install any driver required by your interface. AxeFX Ultra Edit Remake installs no driver, kernel extension, service, or system-wide MIDI router. Intel Macs and other Axe-Fx/FM models are outside this release's target.

## Install

1. Visit the [0.5.2 release](https://github.com/iamknow0ne/axefx-ultra-edit-remake/releases/tag/v0.5.2).
2. Download `AxeFX-Ultra-Edit-Remake-0.5.2-arm64.dmg`. A ZIP contains the same app if preferred.
3. Open the disk image and drag **AxeFX Ultra Edit Remake.app** to **Applications**.
4. Open the copy in Applications and eject the image.

The DMG includes offline documentation. `SHA256SUMS.txt` on the release page covers all distributable files. Developers can verify with `shasum -a 256 -c SHA256SUMS.txt` in a directory containing all the listed assets.

## First launch

**This beta is ad-hoc signed, not Apple-notarized.** Ad-hoc signing checks bundle integrity; it does not establish a Developer ID identity. A downloaded copy may be blocked on first launch.

After attempting to open it, if you trust this release, go to **System Settings → Privacy & Security**, find the AxeFX Ultra Edit Remake message, choose **Open Anyway**, and confirm. See [Apple's official instructions](https://support.apple.com/en-gb/102445). Managed Macs may prevent exceptions. Do not disable Gatekeeper globally. Do not override a malware warning or use a download whose checksum fails.

There is no microphone/audio-input capture workflow. Cabinet audition plays imported files through the Mac's current audio output.

## Wire both directions

```text
Mac ← USB / Thunderbolt → MIDI interface

Interface MIDI OUT ─────────→ Axe-Fx Ultra MIDI IN
Interface MIDI IN  ←───────── Axe-Fx Ultra MIDI OUT
```

Use OUT, not an unconfigured THRU port. A flashing incoming tempo light proves only Ultra → interface traffic.

## Connect

1. Power on the Ultra and connect the interface.
2. Open **MIDI setup** and select **Input** and **Output**. Use **Refresh ports** if necessary.
3. Set **Channel** to match the Ultra's channel for program recall.
4. Leave **Firmware before 10.02** off for firmware 11.00. Older firmware may need that option and a matching SysEx ID; the older-firmware path has not been tested on a physical unit.
5. Choose **Connect**. The firmware appears and the current edit buffer is read.
6. Choose **Back up** to save a `.syx` copy; capture a named snapshot before experimenting.

Disconnect to change port settings. Stop MIDI echo/routing from other editors or DAWs if they interfere. Never route the developer simulator into a physical Ultra.

## Read stored sounds

Open **Library → Ultra**. All **0–383** addresses exist immediately. Choose **Read all 384**, a bank filter, or an individual row. A full scan can take several minutes; **Stop** cancels it. Reads do not change the playing sound.

The device cache lasts for the current connection. Copy wanted sounds to **On this Mac** to retain them. If the front panel displays 1-based numbers, subtract one for the editor's zero-based slot address.

## Update or remove

Finish any gesture/transfer, back up the sound, and quit before replacing the app with a new release. Local data lives separately in `~/Library/Application Support/Ultra Edit/`. Back up that folder before beta updates; there is no automatic updater or guaranteed future experimental-format migration.

To uninstall, quit and move AxeFX Ultra Edit Remake.app to the Trash. Local data remains. Delete Application Support records only if you intend to remove your library, snapshots and drafts. Preferences use `tech.hostin.ultra-edit`. Removing the app does not change hardware presets.

### Upgrading from Ultra Edit

Version 0.5.2 renames the application to **AxeFX Ultra Edit Remake**. Quit the old app, install the new one, then remove the old **Ultra Edit.app** to avoid opening the wrong version. Your library, snapshots and preferences remain in their existing locations; no data migration is required.
