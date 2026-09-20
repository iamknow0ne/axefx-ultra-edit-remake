#!/usr/bin/env python3
"""Check the generated Pages artifact, local links and download contract."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit, unquote
import sys

root = Path(__file__).resolve().parent.parent
out = root / '_site'
errors = []
class Page(HTMLParser):
    def __init__(self, text):
        super().__init__(convert_charrefs=True)
        self.links = []
        self.ids = set()
        self.feed(text)
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs: self.ids.add(attrs['id'])
        for key in ('href', 'src'):
            if key in attrs: self.links.append(attrs[key])
        if tag == 'img' and 'alt' not in attrs: errors.append('Image without alt text')
pages = {p.resolve(): Page(p.read_text()) for p in out.rglob('*.html')}
for path, page in pages.items():
    if '@@' in path.read_text(): errors.append(f'Unresolved template: {path.name}')
    for link in page.links:
        url = urlsplit(link)
        if url.scheme or url.netloc: continue
        target = (path.parent / unquote(url.path)).resolve() if url.path else path
        if target.is_dir(): target = target / 'index.html'
        if not target.is_relative_to(out.resolve()) or not target.exists():
            errors.append(f'{path.relative_to(out)}: missing local link {link}')
        elif url.fragment and target in pages and unquote(url.fragment) not in pages[target].ids:
            # Legacy Markdown anchors do not all follow Python-Markdown's slug rules.
            # The landing page's public links must all resolve exactly.
            if path == out / 'index.html': errors.append(f'Landing page: missing anchor {link}')
version = (root / 'VERSION').read_text().strip()
index = (out / 'index.html').read_text()
expected = f'https://github.com/iamknow0ne/axefx-ultra-edit-remake/releases/download/v{version}/AxeFX-Ultra-Edit-Remake-{version}-arm64.dmg'
if index.count(expected) != 2: errors.append('Download buttons do not match current release asset')
allowed = {'.html', '.css', '.js', '.png', '.txt', '.xml', ''}
for path in out.rglob('*'):
    if path.is_symlink(): errors.append(f'Symlink in Pages artifact: {path}')
    if path.is_file() and path.suffix not in allowed: errors.append(f'Unexpected public file: {path}')
if errors:
    print('\n'.join(errors), file=sys.stderr)
    sys.exit(1)
print(f'PASS Pages artifact: {len(pages)} HTML pages, local links, images and versioned download buttons')
