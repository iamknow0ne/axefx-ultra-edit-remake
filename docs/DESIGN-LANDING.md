# Landing page and product naming

Product: **AxeFX Ultra Edit Remake**. Repository slug: `axefx-ultra-edit-remake`.

Audience: owners of the original Axe-Fx Ultra looking for a native Apple Silicon editor. Primary action: download the macOS installer. Secondary: see actual interface, read the guide and inspect development status.

Direction: Minimal Editorial Product, borrowing the native editor's graphite and amber. A quiet equipment-manual cover, not a generic software dashboard. Real screenshots carry the visual story. Independent development beta; no invented testimonials or all-controls validation claims.

Tokens, before implementation: paper #f1eee7; ink #20272a; muted #59615e; line #c9cec5; dark surface #191e20; amber #e6ae61 on dark and #765024 on paper. Apple system sans connects to the Mac app; Georgia italic is reserved for a short editorial phrase; mono labels identify versions/slots. Space 4/8/12/20/32/48/80; 4px button radius, 8px screenshot frame; no card shadows; a single subtle screenshot shadow. Inline SVG strokes and the existing original app icon. No decorative motion, no external fonts, no analytics.

Layout: compact masthead → asymmetrical title and download introduction → full-width production screenshot with four view selectors → numbered workflow ledger → two-column compatibility/installation notes → documentation/source footer. One column on small screens, 44px touch targets, visible keyboard focus, semantic headings and accessible view selectors. No fixed mobile navigation overlay.

Implementation: static HTML/CSS with a tiny screenshot switcher; built to `_site` by `scripts/build-site.py`, with generated local HTML manuals and selected original screenshots. GitHub Pages artifact contains only site files, not the whole checkout. Deployment uses GitHub Actions, with explicit Pages permissions. The repository visibility remains the owner's choice.

Naming: app display name, package/product name, installer/assets, current docs and repository links change together. Retain the existing bundle identifier and Application Support directory so settings, snapshots and library data survive the rename. Internal module names remain compatibility identifiers, not user-facing branding. Historical release filenames are retained as historical evidence.

Review gate: inspect desktop/mobile renders, all screenshot selectors, local documentation links, download destination and keyboard focus. Target slop score ≤2/10; distinctiveness ≥8/10. Final scores follow actual review.

## Reviewed result

Desktop (1280px), tablet (768px), phone (390px) and narrow-phone (320px) layouts were checked in the browser. No horizontal overflow at 320px or 390px. The mobile headline was reduced to keep its intended three-line rhythm, and the four screenshot selectors now form an even two-column control on phones. Signal grid, library, bank workspace and Cabinet Lab selectors were exercised; keyboard Enter selects a view and visibly retains its focus ring. Images, captions and full-size destinations update together. Static site checks cover every local document/image destination and current download naming.

Self-review: slop **1/10**, distinctiveness **8/10**, implementation readiness **9/10**. The actual rack interface and two-direction MIDI wiring make this specific to the product. Deliberate restraint: no generic card grid, gradients, invented social proof, external typography or animation. Public URL verification depends on the repository owner making it public and GitHub Pages being activated.
