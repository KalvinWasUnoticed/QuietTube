#!/usr/bin/env python3
"""Explicit assets only: fork IPA+dylib, or upstream/fork dylib-only release."""
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
UPSTREAM='kalvinwasunoticed/quiettube'

def publish(env, root=ROOT, run=subprocess.run):
    kind=env.get('RELEASE_KIND','ipa')
    if kind not in ('ipa','dylib'):raise ValueError('Invalid release kind')
    if env.get('ACKNOWLEDGE_RIGHTS')!='true':raise ValueError('Publication acknowledgement required')
    repo=env['GITHUB_REPOSITORY']; commit=env['GITHUB_SHA']
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+',repo):raise ValueError('Invalid repository')
    if kind=='ipa':
        if env.get('IS_FORK')!='true' or repo.lower()==UPSTREAM:raise ValueError('IPA releases require your own fork')
        prerelease=True
    else:
        if repo.lower()!=UPSTREAM and env.get('IS_FORK')!='true':raise ValueError('Dylib release requires upstream or a fork')
        choice=env.get('PRERELEASE','true')
        if choice not in ('true','false'):raise ValueError('Invalid prerelease choice')
        prerelease=choice=='true'
    if not re.fullmatch(r'[0-9a-fA-F]{40}',commit):raise ValueError('Invalid source commit')
    version=(root/'VERSION').read_text().strip()
    if not re.fullmatch(r'\d+\.\d+\.\d+',version):raise ValueError('Invalid version')
    directory=root/'artifacts'
    lib=directory/'QuietTube.dylib'
    if not lib.is_file() or lib.is_symlink():raise ValueError('Expected compiled dylib missing')
    with lib.open('rb') as file:header=file.read(32)
    if len(header)!=32 or struct.unpack_from('<I',header)[0]!=0xFEEDFACF or struct.unpack_from('<I',header,4)[0]!=0x100000C or struct.unpack_from('<I',header,12)[0]!=6:
        raise ValueError('Expected a thin ARM64 MH_DYLIB')
    binaries=[lib]
    if kind=='ipa':
        ipa=directory/f'QuietTube-{version}-21.38.2.ipa'
        if not ipa.is_file() or ipa.is_symlink() or not ipa.stat().st_size:raise ValueError('Exact expected IPA is missing or empty')
        binaries.insert(0,ipa)
    run_id=env['GITHUB_RUN_ID']; attempt=env['GITHUB_RUN_ATTEMPT']
    if not run_id.isdecimal() or not attempt.isdecimal():raise ValueError('Invalid run identity')
    prefix='quiettube' if kind=='ipa' else 'quiettube-dylib'
    tag=f'{prefix}-{version}-{run_id}-{attempt}'
    server=env.get('GITHUB_SERVER_URL','https://github.com')
    if server!='https://github.com':raise ValueError('This workflow supports github.com')
    page=f'{server}/{repo}/releases/tag/{tag}'
    def url(path):return f'{server}/{repo}/releases/download/{tag}/{path.name}'
    # Ship source notices with the standalone binary as well as the packaged IPA.
    notice_sources=[root/'LICENSE',*(root/'Notices'/name for name in ['REFERENCES.md','YTKACE-MIT.txt','YouPiP-LICENSE.txt','YouTube-X-MIT.txt'])]
    if any(not p.is_file() for p in notice_sources):raise ValueError('Required license notices missing')
    notices=directory/'QuietTube-NOTICES.txt'
    notices.write_text('\n\n'.join(f'===== {p.name} =====\n{p.read_text()}' for p in notice_sources))
    assets=[*binaries,notices]
    digests={}
    for path in assets:
        with path.open('rb') as file:digests[path.name]=hashlib.file_digest(file,'sha256').hexdigest()
    metadata={'quiettube':version,'youtube':'21.38.2','release_kind':kind,'prerelease':prerelease,
              'source_commit':commit,'source_repository':repo,'run':f'{server}/{repo}/actions/runs/{run_id}',
              'dylib_sha256':digests[lib.name],'asset_sha256':dict(digests)}
    if kind=='ipa':metadata['ipa_sha256']=digests[binaries[0].name]
    info=directory/'BUILD-INFO.json';info.write_text(json.dumps(metadata,indent=2)+'\n')
    digests[info.name]=hashlib.sha256(info.read_bytes()).hexdigest()
    sums=directory/'SHA256SUMS';sums.write_text(''.join(f'{digest}  {name}\n' for name,digest in digests.items()))
    assets.extend([info,sums])
    title=f'QuietTube {version} — '+('IPA + dylib' if kind=='ipa' else 'dylib only')
    links='\n'.join(f'- [Download {"IPA" if path.suffix==".ipa" else "dylib"}]({url(path)})' for path in binaries)
    if kind=='ipa':
        guidance='User supplied the compatible base and acknowledged publication rights. This is not independent legal clearance. Public repositories publish public assets. The IPA already includes QuietTube: do not inject the standalone dylib into it again. Only LiveContainer has been tested; follow your installer’s signing instructions.'
    else:
        guidance='Standalone QuietTube library only. No YouTube IPA was downloaded or included in this release. This is not an installable app: it requires a compatible, lawfully obtained YouTube 21.38.2 build and appropriate injection/signing tooling. The workflow does not validate a host app. Do not inject twice. No universal installer compatibility is claimed.'
    text=f'# {title}\n\n{links}\n\nSource: `{commit}` in `{repo}`.\n\n{guidance}\n\nChecksums, build metadata and license notices are attached. Successful compilation/publication is not device validation.\n'
    notes=directory/'release-notes.md';notes.write_text(text)
    args=['gh','release','create',tag,*map(str,assets),'--repo',repo,'--target',commit,'--title',f'{title} — build {run_id}.{attempt}','--notes-file',str(notes),'--draft']
    if prerelease:args.append('--prerelease')
    # No glob uploads. Failed create/upload must not expose a completed release.
    run(args,check=True,env=env)
    run(['gh','release','edit',tag,'--repo',repo,'--draft=false'],check=True,env=env)
    with Path(env['GITHUB_STEP_SUMMARY']).open('a') as summary:
        for path in binaries:
            label='IPA' if path.suffix=='.ipa' else 'DYLIB'
            summary.write(f'# [DOWNLOAD {label} — QuietTube {version}]({url(path)})\n\n')
        summary.write(f'[Release / assets]({page})\n\n{text}\nSign into GitHub if repository access requires it.\n')
    return url(binaries[0])

if __name__=='__main__':
    try:publish(dict(os.environ))
    except Exception:
        print('::error::Publication not confirmed. Check mode/repository/acknowledgement, expected assets, token permissions and gh output. A failed upload may leave a draft; no success link was written.',file=sys.stderr)
        raise SystemExit(1)
