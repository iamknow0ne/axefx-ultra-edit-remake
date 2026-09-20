#!/usr/bin/env python3
"""Deterministic, invented test data. These are NOT playable hardware presets."""
import functools
import json
import math
from pathlib import Path
import struct
import wave

root = Path(__file__).resolve().parent.parent
out = root / 'Tests/Fixtures'
out.mkdir(parents=True, exist_ok=True)
catalog = json.loads((root / 'Resources/UltraCatalog.json').read_text())
header = bytes([0xF0, 0, 1, 0x74, 1])

def nibbles(data):
    return bytes(n for b in data for n in (b & 15, b >> 4))

def payload(name):
    data = bytearray(1024)
    data[0] = 53
    data[2:22] = name.encode('ascii').ljust(20, b' ')
    # Row 2, columns 1–12: shunt, amp, cab, EQ, delay, reverb, shunts.
    for col, effect in enumerate([200, 106, 108, 102, 112, 110] + [200]*6):
        cell = col*4+1
        data[34+cell*2:36+cell*2] = bytes([effect, 2])
    offset = 130
    for effect in [106, 108, 102, 112, 110]:
        definition = next(e for e in catalog['effects'] if any(i['id'] == effect for i in e['instances']))
        values = bytearray(max(p['id'] for p in definition['parameters'])+1)
        for p in definition['parameters']:
            values[p['id']] = max(0, min(254, int(p['defaultValue'])))
        if effect == 106:
            values[1] = 151
        record = bytes([effect, len(values)]) + values
        data[offset:offset+len(record)] = record
        offset += len(record)
    # Deliberate opaque tail to test preservation; no real modifier encoding.
    data[900:916] = bytes(range(16))
    return data

def message(data, address):
    return header + bytes([4, *address]) + nibbles(data) + nibbles([functools.reduce(int.__xor__, data)]) + b'\xf7'

(out / 'synthetic-preset.syx').write_bytes(message(payload('Demo studio rig'), [1, 0, 0]))
for bank in range(3):
    data = b''.join(payload(f'Synthetic slot {bank*128+i:03}') for i in range(128))
    (out / f'Synthetic_Bank{"ABC"[bank]}.syx').write_bytes(message(data, [bank+2, 0, 0]))

for name in ['cab-a', 'cab-b', 'audition']:
    count = 48000 if name == 'audition' else 2048
    if name == 'audition':
        values = [0.2*math.exp(-i/16000)*sum(math.sin(2*math.pi*f*i/48000)/j for j,f in enumerate([110,220,330,440],1)) for i in range(count)]
    else:
        frequency = 1800 if name == 'cab-a' else 2600
        values = [0.65*math.exp(-i/90)*math.cos(2*math.pi*frequency*i/48000) for i in range(count)]
    with wave.open(str(out / f'{name}.wav'), 'wb') as f:
        f.setparams((1, 2, 48000, count, 'NONE', 'not compressed'))
        f.writeframes(b''.join(struct.pack('<h', round(max(-1, min(1, x))*32767)) for x in values))

configs = {
    'linear': ('Linear', {'receptive_field':3,'bias':True}, [0.25,-0.5,1.0,0.1]),
    'lstm': ('LSTM', {'input_size':1,'hidden_size':3,'num_layers':1}, [0.15*math.sin(i+1) for i in range(70)]),
    'wavenet': ('WaveNet', {'layers':[
        {'input_size':1,'condition_size':1,'head_size':2,'channels':3,'kernel_size':3,'dilations':[1,2],'activation':'Tanh','gated':False,'head_bias':False},
        {'input_size':3,'condition_size':1,'head_size':1,'channels':2,'kernel_size':3,'dilations':[8],'activation':'Tanh','gated':False,'head_bias':True}],
        'head':None,'head_scale':0.02}, [0.2*math.sin(i+1) for i in range(131)])
}
for name, (architecture, config, weights) in configs.items():
    model = {'version':'0.5.4','architecture':architecture,'config':config,'weights':weights,'sample_rate':48000,'metadata':{'name':'Synthetic test network'}}
    (out / f'{name}.nam').write_text(json.dumps(model, indent=2)+'\n')
print('Generated synthetic SysEx banks, audio and NAM fixtures; never send them to hardware.')
