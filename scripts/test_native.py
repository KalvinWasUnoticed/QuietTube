#!/usr/bin/env python3
"""Compile/run real Foundation modules on macOS; no UIKit/device simulation."""
from pathlib import Path
import json, platform, random, re, subprocess, tempfile, uuid
ROOT=Path(__file__).resolve().parents[1]

def declared_options():
    text=(ROOT/'Sources/QTCore.m').read_text()
    return [{'key':key,'default':value=='YES'} for key,value in
            re.findall(r'@"key":@"(\w+)"[^}]+?@"default":@(YES|NO)',text)]

def main():
    if platform.system()!='Darwin':
        raise SystemExit('Native tests require macOS Foundation; not a Linux pass.')
    with tempfile.TemporaryDirectory(prefix='quiettube-native-') as folder:
        temp=Path(folder)
        schema=temp/'options.json'; options=declared_options()
        assert len(options)==16 and len({o['key'] for o in options})==16
        schema.write_text(json.dumps(options))
        def build(name,sources):
            binary=temp/name
            subprocess.run(['xcrun','clang','-fobjc-arc','-fblocks','-Wall','-Wextra','-Werror',
                            '-framework','Foundation',*sources,'-o',str(binary)],cwd=ROOT,check=True)
            return str(binary)
        basic=build('preferences',['Sources/QTPreferences.m','tests/test_preferences.m'])
        subprocess.run([basic],check=True)
        model=build('settings',['Sources/QTSettingsModel.m','tests/test_settings_native.m'])
        subprocess.run([model,str(schema)],check=True)
        process=build('persistence',['Sources/QTPreferences.m','tests/test_preferences_process.m'])
        suite='QuietTube.audit-tests.'+uuid.uuid4().hex
        def probe(mode,bits=0,fresh=False):
            subprocess.run([process,suite,mode,str(schema),str(bits),str(int(fresh))],check=True,timeout=15)
        rng=random.Random(102)
        masks=[0,(1<<17)-1,0x15555,0xAAAA]+[rng.getrandbits(17) for _ in range(12)]
        try:
            for index,bits in enumerate(masks):
                probe('write',bits,index==0)
                for _ in range(5):probe('read',bits)
        finally:
            probe('clean')
        print('Process persistence: 16 complete 17-setting patterns, 80 separate reader launches; unrelated preference retained. Test flushes explicitly; not an iOS kill/relaunch test.')
if __name__=='__main__':main()
