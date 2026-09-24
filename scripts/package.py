#!/usr/bin/env python3
"""Package the exact user-supplied IPA with a compiled QuietTube dylib.

No decryption, downloading, execution of input binaries, or account-data handling.
Input is hash-pinned. Output is for LiveContainer to re-sign, not App Store install.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import plistlib
import shutil
import stat
import struct
import tempfile
import zipfile

EXPECTED_SHA256 = 'd0f6f5c9d27f7fea8f040ae59c425b3a8222f67d891937374b21ef8937deba11'
DYLIB_PATH = '@executable_path/Frameworks/QuietTube.dylib'

def commands(data):
    if len(data) < 32 or struct.unpack_from('<I', data)[0] != 0xFEEDFACF:
        raise ValueError('Expected a thin little-endian 64-bit Mach-O')
    if struct.unpack_from('<I', data, 4)[0] != 0x100000C:
        raise ValueError('Expected ARM64')
    count, total = struct.unpack_from('<II', data, 16)
    end = 32 + total
    if end > len(data):
        raise ValueError('Load-command region exceeds file')
    result = []
    pos = 32
    for _ in range(count):
        if pos + 8 > end:
            raise ValueError('Truncated load command')
        cmd, size = struct.unpack_from('<II', data, pos)
        if size < 8 or size % 8 or pos + size > end:
            raise ValueError('Invalid load-command size')
        result.append((cmd, pos, size))
        pos += size
    if pos != end:
        raise ValueError('Load-command size mismatch')
    return result, end

def inject(data, name=DYLIB_PATH):
    data = bytearray(data)
    cmds, end = commands(data)
    first_content = len(data)
    for cmd, pos, size in cmds:
        if cmd in (0x21, 0x2C) and struct.unpack_from('<I', data, pos+16)[0]:
            raise ValueError('Encrypted executable; not supported')
        if cmd in (0xC, 0x80000018, 0x8000001F):
            off = struct.unpack_from('<I',data,pos+8)[0]
            path = bytes(data[pos+off:pos+size]).split(b'\0')[0]
            if path == name.encode():
                raise ValueError('QuietTube is already injected')
        if cmd == 0x19:  # segment_command_64
            if size < 72:
                raise ValueError('Truncated segment')
            nsects = struct.unpack_from('<I',data,pos+64)[0]
            if 72+80*nsects > size:
                raise ValueError('Truncated section list')
            fileoff, filesize = struct.unpack_from('<QQ',data,pos+40)
            if fileoff and filesize:
                first_content = min(first_content,fileoff)
            for i in range(nsects):
                sec = pos+72+i*80
                length = struct.unpack_from('<Q',data,sec+40)[0]
                offset = struct.unpack_from('<I',data,sec+48)[0]
                flags = struct.unpack_from('<I',data,sec+64)[0]
                if length and offset and flags & 0xFF not in (1,12,18):
                    first_content = min(first_content,offset)
    encoded = name.encode()+b'\0'
    size = (24+len(encoded)+7) & ~7
    if first_content < end+size or any(data[end:end+size]):
        raise ValueError('Insufficient verified zero header padding; refusing to shift binary data')
    load = struct.pack('<6I',0xC,size,24,0,0,0)+encoded
    data[end:end+size] = load.ljust(size,b'\0')
    count,total = struct.unpack_from('<II',data,16)
    struct.pack_into('<II',data,16,count+1,total+size)
    commands(data)  # verify structure after editing
    return bytes(data)

def safe_extract(archive, destination):
    for member in archive.infolist():
        path = PurePosixPath(member.filename)
        if path.is_absolute() or '..' in path.parts or '\\' in member.filename:
            raise ValueError('Unsafe archive path')
        mode = member.external_attr >> 16
        if stat.S_ISLNK(mode):
            raise ValueError('Symlink input is not accepted')
        archive.extract(member,destination)
        target = destination.joinpath(*path.parts)
        if target.is_file():
            target.chmod(0o755 if mode & 0o111 else 0o644)

def package(ipa, dylib, output):
    with ipa.open('rb') as f:
        digest = hashlib.file_digest(f,'sha256').hexdigest()
    if digest != EXPECTED_SHA256:
        raise ValueError(f'Input IPA hash mismatch: {digest}. Do not silently update the expected hash.')
    lib = dylib.read_bytes()
    commands(lib)
    if struct.unpack_from('<I',lib,12)[0] != 6:
        raise ValueError('Expected MH_DYLIB for QuietTube')
    with tempfile.TemporaryDirectory(prefix='quiettube-') as temp:
        root = Path(temp)
        with zipfile.ZipFile(ipa) as z:
            bad = z.testzip()
            if bad:
                raise ValueError(f'ZIP checksum failed: {bad}')
            safe_extract(z,root)
        apps = list((root/'Payload').glob('*.app'))
        if len(apps) != 1:
            raise ValueError('Expected exactly one main app')
        app = apps[0]
        info = plistlib.loads((app/'Info.plist').read_bytes())
        if info.get('CFBundleIdentifier') != 'com.google.ios.youtube' or info.get('CFBundleShortVersionString') != '21.38.2':
            raise ValueError('Unexpected app identifier/version')
        executable = app/info['CFBundleExecutable']
        executable.write_bytes(inject(executable.read_bytes()))
        executable.chmod(0o755)
        (app/'Frameworks').mkdir(exist_ok=True)
        shutil.copy2(dylib,app/'Frameworks'/'QuietTube.dylib')
        # Invalidate/remove stale bundle signatures. LiveContainer must re-sign.
        for path in list(app.rglob('_CodeSignature')):
            if path.is_dir(): shutil.rmtree(path)
        for path in list(app.rglob('embedded.mobileprovision')): path.unlink()
        # Guest app extensions cannot be assumed to work in this install route.
        if (app/'PlugIns').exists(): shutil.rmtree(app/'PlugIns')
        (app/'QuietTube-build.json').write_text(json.dumps({
            'prototype':'0.12-feed-controls','base_sha256':digest,'youtube':'21.38.2',
            'status':'experimental; not device-verified',
            'signing':'LiveContainer must sign this guest app',
            'extensions_removed':True,
        },indent=2))
        # Ship attribution with the packaged app as well as the source archive.
        notices = Path(__file__).resolve().parents[1]/'Notices'
        if notices.exists(): shutil.copytree(notices,app/'QuietTube-Notices')
        output.parent.mkdir(parents=True,exist_ok=True)
        with zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
            for path in sorted((root/'Payload').rglob('*')):
                if path.is_file(): z.write(path,path.relative_to(root).as_posix())
        with zipfile.ZipFile(output) as z:
            if z.testzip(): raise ValueError('Output CRC failure')
    print(f'Created {output}; import into LiveContainer for re-signing. NOT a verified playback fix.')

if __name__ == '__main__':
    p=argparse.ArgumentParser()
    p.add_argument('ipa',type=Path)
    p.add_argument('dylib',type=Path)
    p.add_argument('output',type=Path)
    a=p.parse_args()
    package(a.ipa,a.dylib,a.output)
