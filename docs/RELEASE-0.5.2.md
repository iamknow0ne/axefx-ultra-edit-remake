# AxeFX Ultra Edit Remake 0.5.2 beta

Double-clicking a library preset now loads it on the connected Ultra. Previous and Next buttons browse the visible results, with selected-row highlighting and automatic scrolling.

- Connection health checks now run silently, without periodically greying out the editor or flashing a pending-work indicator. Actual transfers and lost-connection detection keep their safeguards.
- **Ultra:** recalls the actual numbered device slot using bank select/program change, including unread slots.
- **On this Mac:** loads the selected preset copy into the temporary edit buffer.
- Single-click remains an offline preview. Search, bank, folder and favorites filters determine navigation order.
- A recovery snapshot captures the current hardware sound before every activation. No stored presets are overwritten.
- Overlapping switches and delayed program changes after disconnect are blocked. Checksummed readback checks recalled name, routing and effect instances while allowing the Ultra to upgrade old preset records and initialize blank slots. Mac-library transfers retain exact payload comparison.

Apple Silicon development beta; ad-hoc signed, not Apple-notarized. See the [installation guide](INSTALLATION.md), [user guide](USER-GUIDE.md) and [verification record](VERIFICATION-0.5.2.md).
