#!/usr/bin/env python3
"""Publish the exact built IPA to the invoking fork; never choose a global latest file."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]

def publish(env, root=ROOT, run=subprocess.run):
    if env.get('IS_FORK')!='true' or env.get('ACKNOWLEDGE_RIGHTS')!='true':
        raise ValueError('A fork and explicit rights/publication acknowledgement are required')
    repo=env['GITHUB_REPOSITORY']; commit=env['GITHUB_SHA']
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+',repo):raise ValueError('Invalid repository')
    if repo.lower()=='kalvinwasunoticed/quiettube':raise ValueError('Build in your own fork')
    if not re.fullmatch(r'[0-9a-fA-F]{40}',commit):raise ValueError('Invalid source commit')
    version=(root/'VERSION').read_text().strip()
    if not re.fullmatch(r'\d+\.\d+\.\d+',version):raise ValueError('Invalid version')
    path=root/'artifacts'/f'QuietTube-{version}-21.38.2.ipa'
    if not path.is_file() or not path.stat().st_size:raise ValueError('Exact expected IPA is missing or empty')
    run_id=env['GITHUB_RUN_ID']; attempt=env['GITHUB_RUN_ATTEMPT']
    if not run_id.isdecimal() or not attempt.isdecimal():raise ValueError('Invalid run identity')
    tag=f'quiettube-{version}-{run_id}-{attempt}'
    server=env.get('GITHUB_SERVER_URL','https://github.com')
    if server!='https://github.com':raise ValueError('This workflow supports github.com')
    page=f'{server}/{repo}/releases/tag/{tag}'
    url=f'{server}/{repo}/releases/download/{tag}/{path.name}'
    with path.open('rb') as file:digest=hashlib.file_digest(file,'sha256').hexdigest()
    info=path.parent/'BUILD-INFO.json'
    info.write_text(json.dumps({'quiettube':version,'youtube':'21.38.2','source_commit':commit,'ipa_sha256':digest,'source_repository':repo,'run':f'{server}/{repo}/actions/runs/{run_id}'},indent=2)+'\n')
    sums=path.parent/'SHA256SUMS';sums.write_text(f'{digest}  {path.name}\n')
    notes=path.parent/'release-notes.md'
    notes.write_text(f'# QuietTube {version} — user-provided base build\n\n[Download IPA]({url})\n\nSource: `{commit}` in `{repo}`.\n\nUser supplied the compatible base and acknowledged publication rights. This is not independent legal clearance. A public fork produces publicly downloadable release assets.\n\nImport into LiveContainer for signing/preparation; no second injection. Preserve your data and known-working backup. Runtime validation is still required for this artifact.\n\nIPA SHA256: `{digest}`\n')
    args=['gh','release','create',tag,str(path),str(info),str(sums),'--repo',repo,'--target',commit,'--prerelease','--title',f'QuietTube {version} — build {run_id}.{attempt}','--notes-file',str(notes)]
    # Build a draft first: failed uploads must not leave a supposedly complete public release.
    run(args+['--draft'],check=True,env=env)
    run(['gh','release','edit',tag,'--repo',repo,'--draft=false'],check=True,env=env)
    with Path(env['GITHUB_STEP_SUMMARY']).open('a') as summary:
        summary.write(f'# [DOWNLOAD IPA — QuietTube {version}]({url})\n\n[Release / assets]({page})\n\nDirect `.ipa`, not an artifact ZIP. Sign into GitHub if your fork requires access.\n\nSource commit: `{commit}`\n\nSHA256: `{digest}`\n\nImport into LiveContainer and fully restart the guest. Successful packaging is not device validation.\n')
    return url

if __name__=='__main__':
    try:publish(dict(os.environ))
    except Exception:
        print('::error::IPA publication not confirmed. Check fork/acknowledgement, exact output, token permissions and gh output. A failed upload may leave a draft release; no success link was written.',file=sys.stderr)
        raise SystemExit(1)
