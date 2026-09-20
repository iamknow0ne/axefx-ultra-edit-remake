#!/usr/bin/env python3
"""Publish the recovered catalog as a readable reference, not validation claims."""
from pathlib import Path
import json

root = Path(__file__).resolve().parent.parent
catalog = json.loads((root/'Resources/UltraCatalog.json').read_text())
def clean(value):
    return str(value).replace('|','/').replace('\n',' ')
lines = ['# Effect and control reference','', '[Documentation index](README.md) · [Editing guide](USER-GUIDE.md#editing-an-effect)','',
    'Generated from the shipped interoperability catalog: **36 families, 69 instances, 922 definitions**. This is a control inventory, not proof of all-controls hardware acceptance. Display ranges and units are catalog estimates; raw defaults are bytes, not physical units. Names marked spare may not be editable. Noise Gate, Output and Controllers use complete preset transfers, applied on release; direct live queries remain disabled. Firmware/model-specific meanings can differ.','',
    'The editor pages, filters, menus and modifier availability come from these definitions. Change supported controls in the inspector; do not send raw values from this reference directly to hardware. For model initialization, global controls and offline restrictions, see the user guide.','', '## Families','']
for e in catalog['effects']:
    anchor=e['id'].lower()
    lines.append(f'- [{clean(e["name"])}](#{anchor})')
for e in catalog['effects']:
    lines += ['',f'## {e["id"]}','',f'**{clean(e["name"])}** · Instances: '+', '.join(f'{clean(i["name"])} (ID {i["id"]})' for i in e['instances']), '',
        '| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |', '| --- | --- | --- | --- | --- | --- | --- |']
    for p in e['parameters']:
        lines.append(f'| {p["id"]} | {clean(p["name"])} | {clean(p["page"])} | {p["minimum"]:g}–{p["maximum"]:g} | {clean(p["unit"]) or "—"} | {p["defaultValue"]} | {p["modifierID"] or "—"} |')
    for p in e['parameters']:
        if p['choices']:
            lines += ['',f'**{clean(p["name"])} choices** (catalog order): '+', '.join(clean(x) for x in p['choices'])+'.']
        if p['switches']:
            lines += ['',f'**{clean(p["name"])} switch metadata:** `'+clean(json.dumps(p['switches'],ensure_ascii=False))+'`.']
(root/'docs/CONTROL-REFERENCE.md').write_text('\n'.join(lines)+'\n')
print('Generated complete 922-definition control reference')
