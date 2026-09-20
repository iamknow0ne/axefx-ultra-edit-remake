# Landing page and GitHub Pages

The landing page is built from `site/` and published at **https://iamknow0ne.github.io/axefx-ultra-edit-remake/**. It includes a browsable HTML copy of the documentation and original screenshots rendered from the production interface with synthetic presets.

## Preview locally

```sh
python3 -m venv .build/site-venv
.build/site-venv/bin/pip install Markdown==3.8.2
.build/site-venv/bin/python scripts/build-site.py
python3 scripts/check-site.py
python3 -m http.server 8765 --bind 127.0.0.1 --directory _site
```

Open `http://127.0.0.1:8765`. No JavaScript framework, external fonts, analytics or account is required. The screenshot buttons work with mouse, touch and keyboard; the signal-grid screenshot and full manual remain accessible with JavaScript disabled.

## Publish

In the repository's **Settings → Pages**, select **GitHub Actions** as the build source. The `GitHub Pages` workflow builds and checks the site on pull requests and pushes; deployment runs from `main` when the repository is public. It also runs when the repository becomes public and can be started manually from **Actions → GitHub Pages → Run workflow**.

Only the `_site` build artifact is deployed. Private evidence, original installers, local preset archives and build output are not copied into it. Repository visibility is managed by the owner separately.

## Update content

- `site/index.html`: copy, semantic layout, metadata and destinations.
- `site/styles.css`: responsive layout and design tokens.
- `site/site.js`: accessible screenshot selector.
- `VERSION`: versioned download links, substituted by `scripts/build-site.py`.
- `docs/`: shared Markdown manuals; run `scripts/build-docs.py` to render them independently.
- `docs/images/`: production interface screenshots; regenerate with `scripts/render-screenshots.sh`.

Publish the matching release assets before pointing the site at a new version. `scripts/check-site.py` checks local links, template substitutions, image alternative text and the release download naming contract.
