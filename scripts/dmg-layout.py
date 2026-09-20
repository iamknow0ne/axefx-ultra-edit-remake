#!/usr/bin/env python3
"""Write Finder metadata directly; no Finder UI automation is used."""
from pathlib import Path
import sys
import struct
from ds_store import DSStore
from mac_alias import Alias

volume = Path(sys.argv[1])
background = Alias.for_file(str(volume/'.background/background.png')).to_bytes()
with DSStore.open(str(volume/'.DS_Store'), 'w+') as store:
    store['.']['vSrn'] = ('long', 1)
    store['.']['icvl'] = ('type', 'icnv')
    store['.']['fwi0'] = ('blob', struct.pack('>hhhh4s4s', 140, 180, 680, 900, b'icnv', b'\0\0\0\0'))
    store['.']['fwvh'] = ('shor', 540)
    store['.']['fwsw'] = ('long', 0)
    store['.']['bwsp'] = {'ShowStatusBar':False,'ShowToolbar':False,'ShowSidebar':False,'ShowPathbar':False,'ContainerShowSidebar':False,'WindowBounds':'{{180, 140}, {720, 540}}','PreviewPaneVisibility':False}
    store['.']['icvp'] = {'viewOptionsVersion':1,'backgroundType':2,'backgroundImageAlias':background,'backgroundColorRed':1.0,'backgroundColorGreen':1.0,'backgroundColorBlue':1.0,'iconSize':96.0,'textSize':13.0,'gridSpacing':100.0,'gridOffsetX':0.0,'gridOffsetY':0.0,'scrollPositionX':0.0,'scrollPositionY':0.0,'labelOnBottom':True,'showItemInfo':False,'showIconPreview':True,'arrangeBy':'none'}
    store['.']['vstl'] = ('type', 'icnv')
    for name, position in [('Ultra Edit.app',(190,245)),('Applications',(530,245)),('Documentation',(190,420)),('Install Ultra Edit.html',(530,420))]:
        store[name]['Iloc'] = position
print('Wrote Finder window, background and icon positions')
