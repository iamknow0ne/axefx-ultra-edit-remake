#!/usr/bin/env python3
"""Build only the public landing page and documentation for GitHub Pages."""
from pathlib import Path
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
out = root / '_site'
version = (root / 'VERSION').read_text().strip()
repo = 'https://github.com/iamknow0ne/axefx-ultra-edit-remake'
site = 'https://iamknow0ne.github.io/axefx-ultra-edit-remake/'
values = {'VERSION': version, 'REPO_URL': repo, 'SITE_URL': site,
          'DOWNLOAD_URL': f'{repo}/releases/download/v{version}/AxeFX-Ultra-Edit-Remake-{version}-arm64.dmg'}
if out.exists():
    shutil.rmtree(out)
out.mkdir()
for source in (root / 'site').iterdir():
    if source.suffix in {'.html', '.css', '.js'}:
        text = source.read_text()
        for key, value in values.items():
            text = text.replace(f'@@{key}@@', value)
        (out / source.name).write_text(text)
(out / 'images').mkdir()
for name in ['icon.png', 'editor.png', 'library.png', 'bank-workspace.png', 'cabinet-lab.png']:
    shutil.copyfile(root / 'docs/images' / name, out / 'images' / name)
subprocess.run([sys.executable, str(root / 'scripts/build-docs.py'), str(out / 'manual')], check=True)
(out / '.nojekyll').touch()
(out / 'robots.txt').write_text(f'User-agent: *\nAllow: /\nSitemap: {site}sitemap.xml\n')
(out / 'sitemap.xml').write_text(f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>{site}</loc></url><url><loc>{site}manual/docs/USER-GUIDE.html</loc></url></urlset>\n')
print(f'Built landing page for {site} (v{version})')
