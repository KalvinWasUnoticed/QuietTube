#!/usr/bin/env python3
"""Catch incomplete/mixed source uploads. Integrity check, not an authenticity signature."""
import hashlib
import json
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]

def verify(root, manifest):
    errors = []
    for name, expected in manifest['sha256'].items():
        path = root / name
        if not path.is_file(): errors.append(f'{name}: missing')
        elif hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            errors.append(f'{name}: does not match release {manifest["release"]}')
    for name in manifest['forbidden_legacy_files']:
        if (root / name).exists(): errors.append(f'{name}: obsolete file; remove it rather than overlaying old releases')
    return errors

def main():
    record = ROOT / 'release-manifest.json'
    if not record.is_file():
        print('::error::Missing release manifest. Upload the complete repository.', file=sys.stderr)
        return 1
    manifest = json.loads(record.read_text())
    errors = verify(ROOT, manifest)
    if errors:
        print('::error::Incomplete or mixed QuietTube release. Restore the matching files; do not regenerate hashes just to silence this check.', file=sys.stderr)
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print(f'QuietTube {manifest["release"]}: verified {len(manifest["sha256"])} build/source files. Library-only distribution.')
    return 0

if __name__ == '__main__': raise SystemExit(main())
