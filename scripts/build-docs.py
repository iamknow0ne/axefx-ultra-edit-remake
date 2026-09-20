#!/usr/bin/env python3
"""Build a self-contained, navigable HTML manual from the Markdown sources."""
import html
from pathlib import Path
import re
import shutil
import sys
import markdown

root = Path(__file__).resolve().parent.parent
version = (root/"VERSION").read_text().strip()
out = Path(sys.argv[1]) if len(sys.argv) > 1 else root / '.build/manual'
out.mkdir(parents=True, exist_ok=True)
files = [root / name for name in ['README.md','CONTRIBUTING.md','CHANGELOG.md','SECURITY.md','THIRD_PARTY_NOTICES.md']]
files += sorted((root / 'docs').glob('*.md'))
css = '''
:root{color-scheme:dark;--bg:#191d20;--panel:#24292d;--text:#edf0ed;--muted:#b4bcbf;--accent:#e5ad61}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:16px/1.7 -apple-system,BlinkMacSystemFont,sans-serif}
nav{padding:16px 5vw;background:var(--panel);border-bottom:1px solid #3a4147}nav a{font-weight:600;text-decoration:none;margin-right:24px}
main{max-width:1080px;margin:auto;padding:48px 32px 80px}h1{font-size:42px;line-height:1.15;letter-spacing:-1px}h2{font-size:26px;margin-top:48px;border-top:1px solid #3a4147;padding-top:24px}h3{margin-top:30px}a{color:var(--accent);text-underline-offset:3px}p,li{max-width:90ch}img{max-width:100%;height:auto}table{border-collapse:collapse;width:100%;display:block;overflow:auto;margin:24px 0}th,td{text-align:left;padding:12px 14px;border-bottom:1px solid #3a4147;vertical-align:top}th{background:var(--panel)}code,pre{font-family:ui-monospace,SFMono-Regular,monospace;font-size:.87em}code{background:var(--panel);padding:2px 5px;border-radius:3px}pre{padding:20px;overflow:auto;background:var(--panel)}pre code{padding:0}blockquote{border-left:3px solid var(--accent);margin-left:0;padding-left:20px;color:var(--muted)}footer{margin-top:60px;color:var(--muted);font-size:13px}a:focus-visible{outline:2px solid var(--accent);outline-offset:4px}@media(max-width:600px){main{padding:28px 18px}h1{font-size:32px}nav a{display:inline-block;margin-right:16px}}
'''
for source in files:
    relative = source.relative_to(root)
    target = out / relative.with_suffix('.html')
    target.parent.mkdir(parents=True, exist_ok=True)
    text = source.read_text().replace('<div align="center">','<div align="center" markdown="1">')
    body = markdown.markdown(text, extensions=['extra','toc','sane_lists'])
    # Convert only local document references; retain GitHub/external destinations.
    body = re.sub(r'(href=")([^"#]+\.md)(#[^"]*)?"', lambda m: m[0] if '://' in m[2] else m[1]+m[2][:-3]+'.html'+(m[3] or '')+'"', body)
    # Static badges replace remote badges in the offline manual.
    body = re.sub(r'<img[^>]*src="https://img.shields.io/[^>]+>', '', body)
    base = '../' if relative.parts[0] == 'docs' else ''
    title = next((line.lstrip('# ').strip() for line in source.read_text().splitlines() if line.startswith('# ')), source.stem)
    target.write_text(f'<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(title)} · Ultra Edit</title><style>{css}</style></head><body><nav><a href="{base}README.html">ULTRA EDIT</a><a href="{base}docs/USER-GUIDE.html">User guide</a><a href="{base}docs/INSTALLATION.html">Install</a><a href="{base}docs/TROUBLESHOOTING.html">Troubleshooting</a></nav><main>{body}<footer>Ultra Edit {html.escape(version)} beta · Local documentation · Independent software for Axe-Fx Ultra</footer></main></body></html>')
shutil.copytree(root/'docs/images', out/'docs/images', dirs_exist_ok=True)
(out/'Resources').mkdir(exist_ok=True)
shutil.copyfile(root/'Resources/ThirdPartyNotices.txt', out/'Resources/ThirdPartyNotices.txt')
shutil.copyfile(out/'README.html', out/'index.html')
print(f'Built {len(files)} documentation pages in {out}')
