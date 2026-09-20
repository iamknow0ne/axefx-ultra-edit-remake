"""Package original vector renders as PNG-backed ICNS representations."""
from pathlib import Path
import struct
root = Path(__file__).resolve().parents[1]
variants = [('icp4','16x16'),('icp5','32x32'),('icp6','32x32@2x'),('ic07','128x128'),('ic08','256x256'),('ic09','512x512'),('ic10','512x512@2x')]
chunks = []
for tag, name in variants:
    png = (root/'.build/UltraEdit.iconset'/f'icon_{name}.png').read_bytes()
    chunks.append(tag.encode('ascii') + struct.pack('>I',len(png)+8) + png)
payload = b''.join(chunks)
(root/'Resources/UltraEdit.icns').write_bytes(b'icns' + struct.pack('>I',len(payload)+8) + payload)
