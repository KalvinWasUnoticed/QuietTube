"""Reverse explicitly reviewed diagnostics-only deltas against old frozen hashes.
This verifies the untouched underlying runtime rather than regenerating its baseline.
"""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]

def reviewed_source(name):
    text=(ROOT/name).read_text()
    deltas=json.loads((ROOT/'tests/fixtures/diagnostics-delta.json').read_text())
    for delta in reversed(deltas.get(name,[])):
        if text.count(delta['after'])!=1:
            raise AssertionError(f'{name}: reviewed diagnostics delta no longer matches')
        text=text.replace(delta['after'],delta['before'])
    return text
