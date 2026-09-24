#!/usr/bin/env python3
"""Describe only the compiled QuietTube library; never fetch or package an app."""
import hashlib
import json
import os
from pathlib import Path
from package import commands
import struct

ROOT = Path(__file__).resolve().parents[1]

def describe(library, version, commit):
    data = library.read_bytes()
    commands(data)
    if struct.unpack_from('<I', data, 12)[0] != 6:
        raise ValueError('Expected a Mach-O dynamic library')
    return {'quiettube': version, 'source_commit': commit, 'library_sha256': hashlib.sha256(data).hexdigest(),
            'artifact': 'QuietTube library only; not an installable IPA', 'architecture': 'arm64',
            'youtube_base': '21.38.2', 'signing': 'Ad-hoc library; LiveContainer prepares the locally packaged guest'}

if __name__ == '__main__':
    directory = ROOT / 'artifacts'
    info = describe(directory / 'QuietTube.dylib', (ROOT / 'VERSION').read_text().strip(),
                    os.environ.get('GITHUB_SHA', 'local build (commit not supplied)'))
    (directory / 'BUILD-INFO.json').write_text(json.dumps(info, indent=2) + '\n')
    (directory / 'SHA256SUMS').write_text(f'{info["library_sha256"]}  QuietTube.dylib\n')
    print(f'Library SHA256: {info["library_sha256"]}')
