#!/usr/bin/env python3
"""Download a user-supplied base as data. No built-in app URL or execution."""
import hashlib
import ipaddress
import os
from pathlib import Path
import socket
import sys
import tempfile
import time
import urllib.parse
import urllib.request
from package import EXPECTED_SHA256

MAX_BYTES = 2 * 1024**3
MAX_SECONDS = 300

def validate_url(url):
    if not url or any(c.isspace() or ord(c)<32 for c in url):
        raise ValueError('A direct HTTPS URL is required')
    parsed = urllib.parse.urlsplit(url)
    if parsed.scheme != 'https' or not parsed.hostname or parsed.username or parsed.password or parsed.fragment:
        raise ValueError('HTTPS required; no embedded credentials or fragment')
    if parsed.port not in (None,443):
        raise ValueError('Only the standard HTTPS port is accepted')
    addresses = socket.getaddrinfo(parsed.hostname,443,type=socket.SOCK_STREAM)
    if not addresses or any(not ipaddress.ip_address(a[4][0]).is_global for a in addresses):
        raise ValueError('Only public network destinations are accepted')
    return url

class SafeRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        validate_url(newurl)
        return super().redirect_request(req,fp,code,msg,headers,newurl)

def download(url, output, opener=None):
    validate_url(url)
    output=Path(output)
    output.parent.mkdir(parents=True,exist_ok=True)
    opener=opener or urllib.request.build_opener(urllib.request.ProxyHandler({}),SafeRedirect())
    request=urllib.request.Request(url,headers={'User-Agent':'QuietTube-base-validator/1.2.0'})
    start=time.monotonic(); total=0; digest=hashlib.sha256(); temp=None
    try:
        with opener.open(request,timeout=30) as response:
            validate_url(response.geturl())
            if response.status != 200: raise ValueError('Expected a complete download')
            length=response.headers.get('Content-Length')
            if length is not None and (int(length)<=0 or int(length)>MAX_BYTES):
                raise ValueError('Invalid download size')
            with tempfile.NamedTemporaryFile(dir=output.parent,delete=False) as file:
                temp=Path(file.name)
                while True:
                    chunk=response.read(1024*1024)
                    if time.monotonic()-start>MAX_SECONDS: raise ValueError('Download time limit')
                    if not chunk: break
                    if total==0 and not chunk.startswith(b'PK\x03\x04'): raise ValueError('Expected an IPA ZIP, not a web page')
                    total+=len(chunk)
                    if total>MAX_BYTES: raise ValueError('Download exceeds size limit')
                    digest.update(chunk); file.write(chunk)
            if not total or (length is not None and total!=int(length)): raise ValueError('Incomplete download')
            if digest.hexdigest()!=EXPECTED_SHA256: raise ValueError('Base SHA256 mismatch; exact inspected 21.38.2 required')
            temp.replace(output); temp=None
        return total
    finally:
        if temp is not None:temp.unlink(missing_ok=True)

if __name__=='__main__':
    url=os.environ.get('BASE_IPA_URL','')
    # Workflow inputs are not secrets. Mask our log output as an extra precaution.
    if os.environ.get('GITHUB_ACTIONS')=='true':
        print('::add-mask::'+url.replace('%','%25').replace('\r','%0D').replace('\n','%0A'),flush=True)
    try:
        output=Path(os.environ['RUNNER_TEMP'])/'QuietTube-base.ipa'
        size=download(url,output)
        print(f'Compatible base downloaded and SHA256 verified ({size} bytes). URL not logged.')
    except Exception as error:
        # Do not echo exception text: urllib errors may contain token-bearing URLs.
        print(f'::error::Base download rejected ({type(error).__name__}). Check a public direct HTTPS link, exact required SHA256, size and availability. No URL echoed.',file=sys.stderr)
        raise SystemExit(1)
