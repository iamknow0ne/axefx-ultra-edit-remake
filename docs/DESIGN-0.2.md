# Ultra Edit 0.2 design and acceptance brief

Native macOS instrument editor for a guitarist working on a connected Axe-Fx Ultra. Primary workflow: follow signal → recognize device → adjust sound → compare/recover. Dense and legible at 1120×820, expanding to 1440×960.

Direction: studio rack + native macOS utility. Original vector device illustrations distinguish amp heads, speaker cabinets, stompboxes, expression pedals, EQs, rotary cabinets and rack processors. No borrowed manufacturer artwork. Illustration is representative of effect family, not a claim to depict a specific licensed amp.

Tokens: charcoal #181C20 workspace, #23282D panels, #30363C raised controls, warm white #EEF0EC, secondary #ADB5BB, copper #E4AB6A for selection. Family accents: amp ochre, cab tan, dynamics blue-grey, drive burnt orange, delay teal, reverb blue, modulation sage. SF system 11/12/14/20/24; monospaced values. Spacing 4/8/12/16/24; corners 4 for instruments and 6 for control modules. Hairline separators, no floating shadows or glows. No decorative animation.

Layout: compact connection strip; preset toolbar; 12×4 illustrated signal canvas with wires visible in gutters; sidebar Effects / Library / Snapshots; selected device faceplate and model label; pages, search, pinned controls; responsive control modules. Snapshot comparison lists exact raw changes separately from opaque data. File preview and live hardware states remain explicit.

Features: persistent named snapshots with verified restore and automatic recovery capture; parameter/layout/name differences; searchable persistent preset library with favorites and duplicate detection; pinned frequently used controls. Normal edits remain in hardware edit buffer; persistent Store is explicit.

Acceptance: protocol regression checks, local persistence/diff tests, native UI interaction and visual inspection, real-device current-preset read audit, paced full-preset roundtrip, reversible model/rename/routing/modifier tests with exact final restoration. No persistent slot may be used without a designated test slot. Record unsupported operations instead of assuming success.
