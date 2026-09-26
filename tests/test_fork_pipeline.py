"""Hermetic pipeline tests: synthetic IPA data and mocked HTTP/gh, not a live cloud run."""
import hashlib, io, json, os, plistlib, socket, struct, subprocess, sys, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
R=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(R/'scripts'))
import download_base as d
import publish as pub
import package as pkg
from test_package import fixture
PUBLIC=[(socket.AF_INET,socket.SOCK_STREAM,6,'',('93.184.216.34',443))]
class Response(io.BytesIO):
 def __init__(self,data,url='https://example.org/input.ipa',length=None,status=200):
  super().__init__(data);self.url=url;self.status=status
  self.headers={} if length is None else {'Content-Length':str(length)}
 def geturl(self):return self.url
class Opener:
 def __init__(self,response):self.response=response
 def open(self,*args,**kwargs):return self.response

class DownloaderTests(unittest.TestCase):
 def test_valid_stream_hash_and_atomic_output(self):
  data=b'PK\x03\x04test-data'
  with tempfile.TemporaryDirectory() as t,patch.object(d.socket,'getaddrinfo',return_value=PUBLIC),patch.object(d,'EXPECTED_SHA256',hashlib.sha256(data).hexdigest()):
   path=Path(t)/'base.ipa';self.assertEqual(d.download('https://example.org/base',path,Opener(Response(data,length=len(data)))),len(data));self.assertEqual(path.read_bytes(),data)
 def test_bad_hash_preserves_existing_and_removes_partial(self):
  with tempfile.TemporaryDirectory() as t,patch.object(d.socket,'getaddrinfo',return_value=PUBLIC):
   path=Path(t)/'base.ipa';path.write_bytes(b'previous')
   with self.assertRaises(ValueError):d.download('https://example.org/base',path,Opener(Response(b'PK\x03\x04wrong')))
   self.assertEqual(path.read_bytes(),b'previous');self.assertEqual(len(list(Path(t).iterdir())),1)
 def test_rejects_html_partial_oversized_or_http_error(self):
  cases=[Response(b'<html>'),Response(b'PK\x03\x04x',length=999),Response(b'PK\x03\x04x',length=d.MAX_BYTES+1),Response(b'PK\x03\x04x',status=206)]
  for response in cases:
   with self.subTest(response=response),tempfile.TemporaryDirectory() as t,patch.object(d.socket,'getaddrinfo',return_value=PUBLIC):
    with self.assertRaises(ValueError):d.download('https://example.org/base',Path(t)/'base',Opener(response))
    self.assertEqual(list(Path(t).iterdir()),[])
 def test_rejects_credentials_nonhttps_fragment_and_whitespace(self):
  for url in ['http://example.org/a','file:///tmp/a','https://user:pass@example.org/a','https://example.org/a#fragment','https://example.org/a\n','https://example.org:444/a']:
   with self.subTest(url=url),self.assertRaises(ValueError):d.validate_url(url)
 def test_rejects_private_addresses(self):
  for ip in ['127.0.0.1','169.254.169.254','10.0.0.1','::1']:
   with patch.object(d.socket,'getaddrinfo',return_value=[(2,1,6,'',(ip,443))]),self.assertRaises(ValueError):d.validate_url('https://example.org/a')
 def test_rejects_redirect_downgrade(self):
  with self.assertRaises(ValueError):d.SafeRedirect().redirect_request(None,None,302,'',{},'http://example.org/a')
 def test_redirect_final_destination_checked(self):
  with tempfile.TemporaryDirectory() as t,patch.object(d.socket,'getaddrinfo',return_value=PUBLIC),self.assertRaises(ValueError):
   d.download('https://example.org/a',Path(t)/'base',Opener(Response(b'PK\x03\x04x',url='http://example.org/b')))
 def test_byte_and_time_limits(self):
  for patches in [patch.object(d,'MAX_BYTES',4),patch.object(d.time,'monotonic',side_effect=[0,301])]:
   with patches,tempfile.TemporaryDirectory() as t,patch.object(d.socket,'getaddrinfo',return_value=PUBLIC),self.assertRaises(ValueError):
    d.download('https://example.org/base',Path(t)/'base',Opener(Response(b'PK\x03\x04lots')))

class PublishTests(unittest.TestCase):
 def setup_tree(self,t):
  root=Path(t);(root/'artifacts').mkdir();(root/'VERSION').write_text('1.1.0\n')
  path=root/'artifacts/QuietTube-1.1.0-21.38.2.ipa';path.write_bytes(b'fixture')
  import shutil
  shutil.copy2(R/'LICENSE',root/'LICENSE');shutil.copytree(R/'Notices',root/'Notices')
  lib=bytearray(fixture());struct.pack_into('<I',lib,12,6)
  (root/'artifacts/QuietTube.dylib').write_bytes(lib)
  env=dict(os.environ,IS_FORK='true',ACKNOWLEDGE_RIGHTS='true',GITHUB_REPOSITORY='tester/QuietTube',GITHUB_SHA='a'*40,GITHUB_RUN_ID='123',GITHUB_RUN_ATTEMPT='2',GITHUB_STEP_SUMMARY=str(root/'summary'),GITHUB_SERVER_URL='https://github.com')
  return root,path,env
 def test_exact_fork_upload_draft_then_publish_and_hash(self):
  with tempfile.TemporaryDirectory() as t:
   root,path,env=self.setup_tree(t);calls=[]
   def run(args,**kwargs):calls.append(args)
   url=pub.publish(env,root,run)
   self.assertIn('/tester/QuietTube/releases/download/',url)
   self.assertIn(str(path),calls[0]);self.assertIn('--draft',calls[0]);self.assertIn('--draft=false',calls[1])
   self.assertIn(url,(root/'summary').read_text())
   self.assertEqual(json.loads((root/'artifacts/BUILD-INFO.json').read_text())['ipa_sha256'],hashlib.sha256(b'fixture').hexdigest())
 def test_ack_fork_and_upstream_guards(self):
  for key,value in [('IS_FORK','false'),('ACKNOWLEDGE_RIGHTS','false'),('GITHUB_REPOSITORY','KalvinWasUnoticed/QuietTube')]:
   with tempfile.TemporaryDirectory() as t:
    root,path,env=self.setup_tree(t);env[key]=value
    with self.assertRaises(ValueError):pub.publish(env,root,lambda *a,**k:self.fail('must not upload'))
 def test_missing_empty_wrong_filename(self):
  for mode in ['missing','empty','wrong']:
   with tempfile.TemporaryDirectory() as t:
    root,path,env=self.setup_tree(t)
    if mode=='empty':path.write_bytes(b'')
    elif mode=='wrong':path.rename(path.with_name('old.ipa'))
    else:path.unlink()
    with self.assertRaises(ValueError):pub.publish(env,root,lambda *a,**k:self.fail('must not upload'))
 def test_upload_or_publish_failure_never_writes_success(self):
  for fail_at in [1,2]:
   with tempfile.TemporaryDirectory() as t:
    root,path,env=self.setup_tree(t);count=0
    def fail(args,**kwargs):
     nonlocal count
     count+=1
     if count==fail_at:raise subprocess.CalledProcessError(7,args)
    with self.assertRaises(subprocess.CalledProcessError):pub.publish(env,root,fail)
    self.assertFalse((root/'summary').exists())
 def test_synthetic_download_package_release_round_trip(self):
  import zipfile
  with tempfile.TemporaryDirectory() as t:
   root,path,env=self.setup_tree(t);buffer=io.BytesIO()
   with zipfile.ZipFile(buffer,'w') as z:
    z.writestr('Payload/YouTube.app/Info.plist',plistlib.dumps({'CFBundleIdentifier':'com.google.ios.youtube','CFBundleShortVersionString':'21.38.2','CFBundleExecutable':'YouTube'}))
    z.writestr('Payload/YouTube.app/YouTube',fixture())
   data=buffer.getvalue();digest=hashlib.sha256(data).hexdigest()
   lib=root/'artifacts/QuietTube.dylib';native=bytearray(fixture());struct.pack_into('<I',native,12,6);lib.write_bytes(native)
   base=root/'base.ipa'
   with patch.object(d.socket,'getaddrinfo',return_value=PUBLIC),patch.object(d,'EXPECTED_SHA256',digest),patch.object(pkg,'EXPECTED_SHA256',digest):
    d.download('https://example.org/private-token-not-logged',base,Opener(Response(data)))
    pkg.package(base,lib,path)
   calls=[];pub.publish(env,root,lambda args,**kw:calls.append(args))
   with zipfile.ZipFile(path) as z:self.assertIsNone(z.testzip());self.assertIn('Payload/YouTube.app/Frameworks/QuietTube.dylib',z.namelist())
   self.assertEqual(len(calls),2);self.assertIn(str(path),calls[0])
 def test_publisher_cli_with_fake_gh_process(self):
  # Exercise the real CLI/env/argv/file path handling; gh itself is deliberately mocked.
  for fail in ['none','create','edit']:
   with self.subTest(fail=fail),tempfile.TemporaryDirectory() as t:
    root,path,env=self.setup_tree(t);(root/'scripts').mkdir();(root/'bin').mkdir()
    (root/'scripts/publish.py').write_bytes((R/'scripts/publish.py').read_bytes())
    gh=root/'bin/gh'
    gh.write_text('#!/usr/bin/env python3\nimport json,os,sys\nwith open(os.environ["CALL_LOG"],"a") as f:f.write(json.dumps(sys.argv[1:])+"\\n")\nsys.exit(7 if sys.argv[2]==os.environ["FAIL_STAGE"] else 0)\n')
    gh.chmod(0o755)
    env.update(PATH=str(root/'bin')+os.pathsep+os.environ['PATH'],CALL_LOG=str(root/'calls'),FAIL_STAGE=fail,GH_TOKEN='test-only')
    result=subprocess.run([sys.executable,str(root/'scripts/publish.py')],env=env,capture_output=True,text=True)
    if fail=='none':
     self.assertEqual(result.returncode,0,result.stderr);self.assertIn('DOWNLOAD IPA',(root/'summary').read_text())
    else:self.assertNotEqual(result.returncode,0);self.assertFalse((root/'summary').exists())
    self.assertNotIn('test-only',result.stdout+result.stderr)
