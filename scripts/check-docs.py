#!/usr/bin/env python3
"""Check local document links/assets and release version references."""
from pathlib import Path
import re
import sys
from urllib.parse import unquote

root = Path(__file__).resolve().parent.parent
files = list(root.glob('*.md')) + list((root/'docs').rglob('*.md'))
failures = []
for path in files:
    text = path.read_text()
    links = re.findall(r'!?\[[^\]]*\]\(([^)]+)\)', text)
    links += re.findall(r'(?:src|href)="([^"]+)"', text)
    for link in links:
        if re.match(r'^[a-zA-Z]+:', link) or link.startswith('#'):
            continue
        target = unquote(link.split('#')[0].split('?')[0]).strip('<>')
        if target and not (path.parent/target).exists():
            failures.append(f'{path.relative_to(root)}: missing {target}')
version = (root/'VERSION').read_text().strip()
for name in ['README.md','CHANGELOG.md','docs/RELEASING.md','Sources/UltraEdit/EditorView.swift']:
    if version not in (root/name).read_text():
        failures.append(f'{name}: missing current version {version}')
for path in (root/'docs/images').glob('*.png'):
    if path.stat().st_size < 1000:
        failures.append(f'{path}: unexpectedly small image')
if failures:
    print('\n'.join(failures), file=sys.stderr)
    sys.exit(1)
print(f'PASS local documentation links, image assets and version references ({len(files)} documents)')
