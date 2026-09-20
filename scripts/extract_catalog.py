#!/usr/bin/env python3
"""Recover interoperability metadata from the user's own legacy installation.
No executable code, artwork or presets are included in the generated catalog.
"""
import json, sys, hashlib
from pathlib import Path
import xml.etree.ElementTree as ET
base = Path(sys.argv[1] if len(sys.argv)>1 else 'research/original/Axe-Edit.app/Contents/MacOS')
config_path=base/'Configs/Ultra/default.axeml'
profile_path=base/'Profiles/Ultra/default.profile'
config, profile = ET.parse(config_path).getroot(), ET.parse(profile_path).getroot()
profiles={(p.get('effectType'), int(p.get('paramID'))):p.attrib for p in profile.findall('Parameter')}
effects=[]
for group in config.findall('./EffectParameterLists/EffectParameters'):
    typ=group.get('name')
    if typ in ('Dummy','Modifier'): continue
    editor=config.find(f'./EffectLayouts/EditorControls[@name="{typ}"]')
    labels={}; pages={}; order={}; synthetic={}
    if editor is not None:
        for page in editor.findall('.//Page'):
            for control in page.findall('.//EditorControl'):
                name=control.get('parameterName')
                if name and name not in labels:
                    labels[name]=control.get('name', name)
                    pages[name]=page.get('name') or 'Controls'
                    order[name]=len(order)
                    if control.get('toggleGroup'): synthetic[name]=control.attrib
    if editor is not None and editor.get("typeParameter"):
        type_key=editor.get("typeParameter")
        labels[type_key]="Amp model" if typ=="Amp" else "Type"
        pages[type_key]="Basic"
        order[type_key]=-10
    params=[]
    for p in group.findall('EffectParameter'):
        pid=int(p.get('id')); key=p.get('name'); prof=profiles.get((typ,pid))
        # Synthetic switches refer to a bit in a different parameter. They are
        # not queryable IDs and must never be sent as ordinary parameters.
        if key in synthetic: continue
        if prof is None: continue
        choices=[prof.get(f'item{i}',str(i)).strip() for i in range(int(prof.get('numVals','0')))] if prof['paramType']=='INT' else []
        params.append(dict(id=pid,name=labels.get(key,key.split('_',1)[-1].replace('_',' ').title()),key=key,
            page=pages.get(key,'Other'),order=order.get(key,1000+pid),kind=prof['paramType'],
            minimum=float(prof['minimum']),maximum=float(prof['maximum']),precision=int(prof['precision']),
            unit=prof['unit'],defaultValue=int(prof['default']),choices=choices,modifierID=int(p.get('modifierID','0')),
            switches=[dict(name=c.get('name','Switch'),bit=int(c['toggleParameterBit'])) for c in synthetic.values() if c.get('toggleGroup')==key]))
    instances=[dict(id=int(p.get('id')),name=p.get('name')) for p in config.findall('./EffectPool/EffectPoolInstance') if p.get('type')==typ]
    if instances: effects.append(dict(id=typ,name=typ,instances=instances,typeParameterID=next((int(p.get("id")) for p in group.findall("EffectParameter") if editor is not None and p.get("name")==editor.get("typeParameter")),None),parameters=sorted(params,key=lambda p:p['order'])))
result=dict(schemaVersion=1,source='User-supplied Axe-Edit 1.0.191 installer; Ultra XML and profile',configVersion=config.attrib,effects=effects)
Path('Resources/UltraCatalog.json').write_text(json.dumps(result,indent=2)+'\n')
print(f'{len(effects)} effect types, {sum(len(e["instances"]) for e in effects)} instances, {sum(len(e["parameters"]) for e in effects)} parameter definitions')
