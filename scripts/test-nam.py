#!/usr/bin/env python3
"""Actual NAM inference acceptance, not a mocked converter."""
import json, subprocess, pathlib, math, tempfile
root = pathlib.Path(__file__).resolve().parent.parent
out = root/'.build/test-artifacts/nam'
out.mkdir(parents=True,exist_ok=True)
summary = {}
for name in ['linear','wavenet','lstm']:
    target = out/(name+'.json')
    subprocess.run([str(root/'.build/nam/nam-ir'),str(root/'Tests/Fixtures'/(name+'.nam')),str(target)],check=True,timeout=90)
    result = json.loads(target.read_text())
    assert result['sampleRate'] == 48000 and len(result['samples']) == 4800
    assert all(math.isfinite(x) for x in result['samples'])
    assert max(abs(x) for x in result['samples']) > 1e-6
    if name == 'linear':
        assert max(abs(a-b) for a,b in zip(result['samples'][:3],[0.25,-0.5,1])) < 1e-5
        assert max(abs(x) for x in result['samples'][3:]) < 1e-5
        assert result['levelSensitivityPercent'] < 0.001
    summary[name] = {'frames':len(result['samples']),'levelSensitivityPercent':result['levelSensitivityPercent']}
    print('PASS actual NAM inference:',name)
with tempfile.TemporaryDirectory() as tmp:
    invalid = pathlib.Path(tmp)/'invalid.nam'; invalid.write_text('{"architecture":"not-a-model"}')
    result = subprocess.run([str(root/'.build/nam/nam-ir'),str(invalid),str(pathlib.Path(tmp)/'out.json')],capture_output=True,timeout=10)
    assert result.returncode != 0
    print('PASS unsupported/malformed NAM rejected')
(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
