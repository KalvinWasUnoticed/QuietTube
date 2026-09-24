#!/usr/bin/env python3
"""Reject incomplete/mixed release uploads. Not a security signature or native test."""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

def verify(root, manifest):
    problems = []
    for name, expected in manifest['sha256'].items():
        path = root / name
        if not path.is_file():
            problems.append(f'{name}: missing')
        elif hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            problems.append(f'{name}: does not match {manifest["release"]}')
    return problems

def main():
    record = ROOT / 'RELEASE-SOURCE-MANIFEST.json'
    if not record.is_file():
        print('::error::Release manifest missing. Upload the complete source package.', file=sys.stderr)
        return 1
    manifest = json.loads(record.read_text())
    problems = verify(ROOT, manifest)
    if problems:
        print('::error::Mixed/incomplete QuietTube source update. Upload the COMPLETE package, not just its workflow or release script.', file=sys.stderr)
        for problem in problems:
            print(problem, file=sys.stderr)
        print('Do not regenerate the manifest to hide a mismatch. Restore the matching release files.', file=sys.stderr)
        return 1
    print(f'Verified {manifest["release"]}: {len(manifest["sha256"])} source/build files match the complete package.')
    print('Expected UI: Presets, Ads, Feed, Playback, Appearance, Advanced. Footer: 0.14.0-rc1.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
